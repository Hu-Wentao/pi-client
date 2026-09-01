import { createHash, randomUUID } from "node:crypto";
import { createReadStream } from "node:fs";
import {
  chmod,
  mkdtemp,
  open,
  realpath,
  rm,
  stat,
  writeFile,
  type FileHandle,
} from "node:fs/promises";
import { tmpdir } from "node:os";
import { isAbsolute, join, relative } from "node:path";

import { create, type MessageInitShape } from "@bufbuild/protobuf";
import {
  Capability,
  ErrorCode,
  MAX_FRAME_BYTES,
  MAX_TRANSFER_CHUNK_BYTES,
  PiTransportFrameSchema,
  SessionAdminOperation,
  SessionExportFormat,
  SessionEventStreamEnvelopeSchema,
  SessionTreeMutationOperation,
  TransferDirection,
  TransferPurpose,
  decodeTransportFrame,
  encodeTransportFrame,
  type MessageContentBinding,
  type PiTransportFrame,
  type ProtocolVersion,
  type StableError,
} from "@pi-client/protocol";

import {
  PiNodeDomainError,
  type PiNodeMessageContentBinding,
  type PiNodeProjectSnapshot,
  type PiNodeSessionEvent,
  type PiNodeSessionHistoryPage,
  type PiNodeSessionSnapshot,
} from "../pi-node-domain.js";
import {
  mapCommandFailure,
  mapDomainError,
  stableError,
  toProtocolConversationEntry,
  toProtocolConversationMetrics,
  toProtocolConversationPage,
  toProtocolDirectoryListing,
  toProtocolKnownProjectSnapshot,
  toProtocolMessageContentBinding,
  toProtocolProjectSnapshot,
  toProtocolSessionDetail,
  toProtocolSessionStats,
  toProtocolSessionSummary,
  toProtocolSessionTree,
  toProtocolToolActivity,
} from "./protobuf-domain-adapter.js";
import type { PiNodeProtocolDomain } from "./pi-node-protocol-domain-port.js";

const MAX_TRACKED_IDENTIFIERS = 65_536;
const DEFAULT_HISTORY_PAGE_MESSAGES = 50;
const MAX_HISTORY_PAGE_MESSAGES = 200;
const EXPORT_TRANSFER_CHUNK_BYTES = 64 * 1024;
const MAX_TRANSFER_CREDIT_BYTES = 8 * 1024 * 1024;
const MAX_OUTSTANDING_TRANSFER_CHUNKS = 16;

export const PI_NODE_PROTOCOL_IMPLEMENTATION_NAME = "Pi Client Node";
export const SUPPORTED_UNPUBLISHED_PROTOCOL_VERSIONS = Object.freeze([
  Object.freeze({ major: 0, minor: 2, patch: 0 }),
] as const);
export const SUPPORTED_PROTOCOL_CAPABILITIES = Object.freeze([
  Capability.SESSION_READ,
  Capability.SESSION_CREATE,
  Capability.PROMPT_COMMAND,
  Capability.ABORT_COMMAND,
  Capability.SESSION_EVENTS,
  Capability.PROJECT_DISCOVERY,
  Capability.PROJECT_TRUST,
  Capability.SESSION_ADMIN,
  Capability.SESSION_TREE,
  Capability.SESSION_HISTORY,
  Capability.SESSION_STATS,
  Capability.SESSION_EXPORT,
  Capability.CANCELLATION,
  Capability.FLOW_CONTROL,
  Capability.TRANSFER,
  Capability.RICH_CONVERSATION,
  Capability.MESSAGE_CONTENT,
] as const);

export interface PiNodeProtocolLogger {
  info(code: PiNodeProtocolLogCode): void;
  error(code: PiNodeProtocolLogCode): void;
}

export type PiNodeProtocolLogCode =
  | "handshake-accepted"
  | "handshake-rejected"
  | "protocol-violation"
  | "domain-operation-failed"
  | "stream-closed"
  | "output-failed";

export interface PiNodeProtocolConnectionOptions {
  readonly domain: PiNodeProtocolDomain;
  readonly nodeInstanceId?: string;
  readonly implementationVersion: string;
  readonly writeFrame: (payload: Uint8Array) => void | Promise<void>;
  readonly logger?: PiNodeProtocolLogger;
  readonly streamIdFactory?: (sessionId: string, ordinal: number) => string;
}

export interface PiNodeProtocolReceiveResult {
  readonly close: boolean;
  readonly reason?: "handshake-rejected" | "protocol-error";
}

type FrameOperationInit = NonNullable<MessageInitShape<typeof PiTransportFrameSchema>["operation"]>;

interface ObservedSession {
  readonly sessionId: string;
  readonly streamId: string;
  unsubscribe: () => void;
  lastDomainSequence: number;
  eventSequence: bigint;
  eventTail: Promise<void>;
  closed: boolean;
}

interface PendingAdmission {
  readonly events: PiNodeSessionEvent[];
}

interface OutboundTransfer {
  readonly requestId: bigint;
  readonly transferId: string;
  readonly tempDirectory: string;
  readonly filePath: string;
  readonly fileName: string;
  readonly contentType: string;
  readonly totalBytes: bigint;
  readonly chunkBytes: number;
  readonly sha256: Uint8Array;
  readonly sentEndOffsets: Map<bigint, bigint>;
  handle: FileHandle | undefined;
  nextSequence: bigint;
  nextOffset: bigint;
  acknowledgedSequence: bigint;
  committedBytes: bigint;
  creditBytes: bigint;
  pumpTail: Promise<void>;
  closed: boolean;
}

class OutboundFrameLimitError extends Error {
  constructor() {
    super("The outbound frame exceeds the negotiated frame limit.");
    this.name = "OutboundFrameLimitError";
  }
}

export class PiNodeProtobufConnection {
  readonly #domain: PiNodeProtocolDomain;
  readonly #nodeInstanceId: string;
  readonly #implementationVersion: string;
  readonly #writeFrame: (payload: Uint8Array) => void | Promise<void>;
  readonly #logger: PiNodeProtocolLogger | undefined;
  readonly #streamIdFactory: (sessionId: string, ordinal: number) => string;
  readonly #supportedCapabilities = new Set<Capability>(SUPPORTED_PROTOCOL_CAPABILITIES);
  readonly #negotiatedCapabilities = new Set<Capability>();
  readonly #requestIds = new Set<bigint>();
  readonly #commandIds = new Set<string>();
  readonly #observations = new Map<string, ObservedSession>();
  readonly #pendingAdmissions = new Map<string, PendingAdmission>();
  readonly #projectWorkingDirectories = new Map<string, string>();
  readonly #adminAbortControllers = new Map<bigint, AbortController>();
  readonly #outboundTransfers = new Map<string, OutboundTransfer>();

  #handshake: "awaiting" | "accepted" | "rejected" = "awaiting";
  #lastClientFrameSequence = 0n;
  #lastServerFrameSequence = 0n;
  #maxOutboundFrameBytes = MAX_FRAME_BYTES;
  #maxTransferChunkBytes = MAX_TRANSFER_CHUNK_BYTES;
  #streamOrdinal = 0;
  #terminal = false;
  #inputTail: Promise<void> = Promise.resolve();
  #writeTail: Promise<void> = Promise.resolve();

  constructor(options: PiNodeProtocolConnectionOptions) {
    this.#domain = options.domain;
    this.#nodeInstanceId = options.nodeInstanceId ?? randomUUID();
    this.#implementationVersion = options.implementationVersion;
    this.#writeFrame = options.writeFrame;
    this.#logger = options.logger;
    this.#streamIdFactory =
      options.streamIdFactory ??
      ((_sessionId, ordinal) => `session-stream-${ordinal}-${randomUUID()}`);
  }

  receive(payload: Uint8Array): Promise<PiNodeProtocolReceiveResult> {
    let result: PiNodeProtocolReceiveResult = { close: this.#terminal };
    const operation = this.#inputTail.then(async () => {
      result = await this.#receiveOnce(payload);
    });
    this.#inputTail = operation.catch(() => undefined);
    return operation.then(() => result);
  }

  rejectMalformedTransport(): Promise<PiNodeProtocolReceiveResult> {
    let result: PiNodeProtocolReceiveResult = { close: true, reason: "protocol-error" };
    const operation = this.#inputTail.then(async () => {
      result = await this.#failProtocol("Malformed stdio IPC framing.");
    });
    this.#inputTail = operation.catch(() => undefined);
    return operation.then(() => result);
  }

  async dispose(): Promise<void> {
    this.#terminal = true;
    for (const controller of this.#adminAbortControllers.values()) {
      controller.abort();
    }
    this.#adminAbortControllers.clear();
    await this.#releaseObservations();
    await this.#releaseTransfers();
    await this.#writeTail.catch(() => undefined);
  }

  async #receiveOnce(payload: Uint8Array): Promise<PiNodeProtocolReceiveResult> {
    if (this.#terminal) {
      return { close: true };
    }

    let frame: PiTransportFrame;
    try {
      frame = decodeTransportFrame(payload);
    } catch {
      return this.#failProtocol("Malformed Protobuf transport frame.");
    }

    const expectedSequence = this.#lastClientFrameSequence + 1n;
    if (frame.frameSequence !== expectedSequence) {
      return this.#failProtocol("Client frame_sequence is not contiguous and ordered.");
    }
    this.#lastClientFrameSequence = frame.frameSequence;

    if (this.#handshake === "accepted" && payload.length > this.#maxOutboundFrameBytes) {
      return this.#failProtocol("Client frame exceeds the negotiated frame limit.");
    }

    if (this.#handshake === "awaiting") {
      if (frame.operation.case !== "clientProtocolOffer") {
        return this.#failProtocol("The first client frame must be a protocol offer.");
      }
      return this.#handleHandshake(frame.operation.value);
    }

    if (frame.operation.case === "clientProtocolOffer") {
      return this.#failProtocol("The protocol handshake cannot be repeated.");
    }
    if (this.#handshake !== "accepted") {
      return { close: true, reason: "handshake-rejected" };
    }

    try {
      await this.#routeOperation(frame);
      return { close: this.#terminal };
    } catch (error) {
      if (error instanceof OutboundFrameLimitError) {
        return this.#failProtocol("A server frame exceeds the negotiated frame limit.");
      }
      this.#logger?.error("domain-operation-failed");
      return this.#failProtocol("The protocol coordinator failed.");
    }
  }

  async #handleHandshake(
    offer: Extract<PiTransportFrame["operation"], { case: "clientProtocolOffer" }>["value"],
  ): Promise<PiNodeProtocolReceiveResult> {
    const selected = offer.protocolVersions.find((candidate) =>
      SUPPORTED_UNPUBLISHED_PROTOCOL_VERSIONS.some((supported) =>
        sameProtocolVersion(candidate, supported),
      ),
    );
    if (!selected) {
      this.#handshake = "rejected";
      await this.#sendOperation({
        case: "serverHandshakeRejected",
        value: {
          error: stableError(
            ErrorCode.PROTOCOL_VERSION_UNSUPPORTED,
            "No offered unpublished v0 protocol version is supported.",
          ),
          supportedProtocolVersions: [...SUPPORTED_UNPUBLISHED_PROTOCOL_VERSIONS],
        },
      });
      this.#logger?.info("handshake-rejected");
      this.#terminal = true;
      return { close: true, reason: "handshake-rejected" };
    }

    const capabilities = offer.capabilities.filter((capability) =>
      this.#supportedCapabilities.has(capability),
    );
    for (const capability of capabilities) {
      this.#negotiatedCapabilities.add(capability);
    }
    this.#maxOutboundFrameBytes = Math.min(MAX_FRAME_BYTES, offer.maxFrameBytes);
    this.#maxTransferChunkBytes = Math.min(MAX_TRANSFER_CHUNK_BYTES, offer.maxTransferChunkBytes);
    this.#handshake = "accepted";

    await this.#sendOperation({
      case: "serverHandshakeAccepted",
      value: {
        selectedProtocolVersion: selected,
        capabilities,
        nodeInstanceId: this.#nodeInstanceId,
        implementationName: PI_NODE_PROTOCOL_IMPLEMENTATION_NAME,
        implementationVersion: this.#implementationVersion,
        maxFrameBytes: this.#maxOutboundFrameBytes,
        maxTransferChunkBytes: this.#maxTransferChunkBytes,
      },
    });
    this.#logger?.info("handshake-accepted");
    return { close: false };
  }

  async #routeOperation(frame: PiTransportFrame): Promise<void> {
    switch (frame.operation.case) {
      case "getProjectBootstrapRequest":
        await this.#handleProjectBootstrap(frame.operation.value.requestId);
        return;
      case "browseDirectoryRequest":
        await this.#handleBrowseDirectory(
          frame.operation.value.requestId,
          frame.operation.value.directory,
          frame.operation.value.maxChildren,
        );
        return;
      case "validateProjectRequest":
        await this.#handleValidateProject(
          frame.operation.value.requestId,
          frame.operation.value.candidateDirectory,
        );
        return;
      case "listKnownProjectsRequest":
        await this.#handleListKnownProjects(
          frame.operation.value.requestId,
          frame.operation.value.maxProjects,
        );
        return;
      case "approveProjectTrustRequest":
        await this.#handleApproveProjectTrust(
          frame.operation.value.requestId,
          frame.operation.value.projectId,
          frame.operation.value.trustRevision,
        );
        return;
      case "listSessionsRequest":
        await this.#handleListSessions(
          frame.operation.value.requestId,
          frame.operation.value.projectId,
        );
        return;
      case "getSessionRequest":
        await this.#handleGetSession(
          frame.operation.value.requestId,
          frame.operation.value.sessionId,
          frame.operation.value.projectId,
        );
        return;
      case "createSessionRequest":
        await this.#handleCreateSession(
          frame.operation.value.requestId,
          frame.operation.value.projectId,
        );
        return;
      case "getSessionTreeRequest":
        await this.#handleGetSessionTree(
          frame.operation.value.requestId,
          frame.operation.value.projectId,
          frame.operation.value.sessionId,
        );
        return;
      case "getSessionHistoryRequest":
        await this.#handleGetSessionHistory(
          frame.operation.value.requestId,
          frame.operation.value.projectId,
          frame.operation.value.sessionId,
          frame.operation.value.cursor,
          frame.operation.value.limit,
          frame.operation.value.expectedActiveBranchRevision,
          frame.operation.value.expectedTreeRevision,
        );
        return;
      case "getMessageContentRequest":
        await this.#handleGetMessageContent(
          frame.operation.value.requestId,
          frame.operation.value.projectId,
          frame.operation.value.binding,
          frame.operation.value.expectedMimeType,
          frame.operation.value.expectedTotalBytes,
          frame.operation.value.expectedSha256,
        );
        return;
      case "getSessionStatsRequest":
        await this.#handleGetSessionStats(
          frame.operation.value.requestId,
          frame.operation.value.projectId,
          frame.operation.value.sessionId,
        );
        return;
      case "navigateSessionTreeCommand":
        await this.#handleNavigateSessionTree(
          frame.operation.value.requestId,
          frame.operation.value.commandId,
          frame.operation.value.projectId,
          frame.operation.value.sessionId,
          frame.operation.value.entryId,
          frame.operation.value.expectedAdminRevision,
        );
        return;
      case "forkSessionCommand":
        await this.#handleForkSession(
          frame.operation.value.requestId,
          frame.operation.value.commandId,
          frame.operation.value.projectId,
          frame.operation.value.sessionId,
          frame.operation.value.userEntryId,
          frame.operation.value.expectedAdminRevision,
        );
        return;
      case "cloneSessionCommand":
        await this.#handleCloneSession(
          frame.operation.value.requestId,
          frame.operation.value.commandId,
          frame.operation.value.projectId,
          frame.operation.value.sessionId,
          frame.operation.value.expectedAdminRevision,
        );
        return;
      case "promptCommand":
        await this.#handlePrompt(
          frame.operation.value.requestId,
          frame.operation.value.commandId,
          frame.operation.value.sessionId,
          frame.operation.value.prompt,
        );
        return;
      case "abortCommand":
        await this.#handleAbort(
          frame.operation.value.requestId,
          frame.operation.value.commandId,
          frame.operation.value.sessionId,
        );
        return;
      case "renameSessionCommand":
        await this.#handleRenameSession(
          frame.operation.value.requestId,
          frame.operation.value.commandId,
          frame.operation.value.projectId,
          frame.operation.value.sessionId,
          frame.operation.value.name,
        );
        return;
      case "clearSessionNameCommand":
        await this.#handleClearSessionName(
          frame.operation.value.requestId,
          frame.operation.value.commandId,
          frame.operation.value.projectId,
          frame.operation.value.sessionId,
        );
        return;
      case "autoNameSessionCommand":
        await this.#handleAutoNameSession(
          frame.operation.value.requestId,
          frame.operation.value.commandId,
          frame.operation.value.projectId,
          frame.operation.value.sessionId,
          frame.operation.value.timeoutMillis,
        );
        return;
      case "deleteSessionCommand":
        await this.#handleDeleteSession(
          frame.operation.value.requestId,
          frame.operation.value.commandId,
          frame.operation.value.projectId,
          frame.operation.value.sessionId,
          frame.operation.value.confirmation,
        );
        return;
      case "exportSessionRequest":
        await this.#handleExportSession(
          frame.operation.value.requestId,
          frame.operation.value.projectId,
          frame.operation.value.sessionId,
          frame.operation.value.format,
          frame.operation.value.expectedActiveBranchRevision,
          frame.operation.value.expectedTreeRevision,
        );
        return;
      case "cancel":
        await this.#handleCancel(frame.operation.value);
        return;
      case "windowUpdate":
        await this.#handleWindowUpdate(frame.operation.value);
        return;
      case "transferAck":
        await this.#handleTransferAck(frame.operation.value);
        return;
      case "healthRequest":
        await this.#handleUnsupportedRequest(frame.operation.value.requestId);
        return;
      case "serverHandshakeAccepted":
      case "serverHandshakeRejected":
      case "healthResponse":
      case "getProjectBootstrapResponse":
      case "browseDirectoryResponse":
      case "validateProjectResponse":
      case "listKnownProjectsResponse":
      case "approveProjectTrustResponse":
      case "listSessionsResponse":
      case "getSessionResponse":
      case "createSessionResponse":
      case "getSessionTreeResponse":
      case "getSessionHistoryResponse":
      case "getSessionStatsResponse":
      case "sessionAdminCommandOutcome":
      case "sessionTreeMutationOutcome":
      case "requestRejected":
      case "commandAccepted":
      case "commandRejected":
      case "sessionEventStream":
      case "eventStream":
      case "transferOpen":
      case "transferChunk":
      case "transferComplete":
      case "transferAbort":
      case "error":
        await this.#failProtocol("The client sent a server-only operation.");
        return;
      case "clientProtocolOffer":
      case undefined:
        await this.#failProtocol("The client sent an invalid operation.");
    }
  }

  async #handleProjectBootstrap(requestId: bigint): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.PROJECT_DISCOVERY, false))) {
      return;
    }
    try {
      const bootstrap = await this.#domain.getProjectBootstrap();
      this.#registerProject(bootstrap.defaultProject);
      await this.#sendRequestOperation(
        requestId,
        {
          case: "getProjectBootstrapResponse",
          value: {
            requestId,
            homeDirectory: bootstrap.homeDirectory,
            defaultProject: toProtocolProjectSnapshot(bootstrap.defaultProject),
          },
        },
        false,
      );
    } catch (error) {
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    }
  }

  async #handleBrowseDirectory(
    requestId: bigint,
    directory: string,
    maxChildren: number,
  ): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.PROJECT_DISCOVERY, false))) {
      return;
    }
    try {
      const listing = await this.#domain.browseDirectory({ directory, maxChildren });
      await this.#sendRequestOperation(
        requestId,
        {
          case: "browseDirectoryResponse",
          value: { requestId, directory: toProtocolDirectoryListing(listing) },
        },
        false,
      );
    } catch (error) {
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    }
  }

  async #handleValidateProject(requestId: bigint, candidateDirectory: string): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.PROJECT_DISCOVERY, false))) {
      return;
    }
    try {
      const project = await this.#domain.validateProject({ candidateDirectory });
      this.#registerProject(project);
      await this.#sendRequestOperation(
        requestId,
        {
          case: "validateProjectResponse",
          value: { requestId, project: toProtocolProjectSnapshot(project) },
        },
        false,
      );
    } catch (error) {
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    }
  }

  async #handleListKnownProjects(requestId: bigint, maxProjects: number): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.PROJECT_DISCOVERY, false))) {
      return;
    }
    try {
      const projects = await this.#domain.listKnownProjects({ maxProjects });
      for (const known of projects) {
        this.#registerProject(known.project);
      }
      await this.#sendRequestOperation(
        requestId,
        {
          case: "listKnownProjectsResponse",
          value: { requestId, projects: projects.map(toProtocolKnownProjectSnapshot) },
        },
        false,
      );
    } catch (error) {
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    }
  }

  async #handleApproveProjectTrust(
    requestId: bigint,
    projectId: string,
    trustRevision: string,
  ): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.PROJECT_TRUST, false))) {
      return;
    }
    try {
      const project = await this.#domain.approveProjectTrust({
        canonicalCwd: this.#requireRegisteredProject(projectId),
        trustRevision,
      });
      this.#registerProject(project);
      await this.#sendRequestOperation(
        requestId,
        {
          case: "approveProjectTrustResponse",
          value: { requestId, project: toProtocolProjectSnapshot(project) },
        },
        false,
      );
    } catch (error) {
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    }
  }

  async #handleListSessions(requestId: bigint, projectId: string): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.SESSION_READ, false))) {
      return;
    }

    try {
      const sessions = await this.#domain.listSessions({
        cwd: this.#requireRegisteredProject(projectId),
      });
      await this.#sendRequestOperation(
        requestId,
        {
          case: "listSessionsResponse",
          value: { requestId, sessions: sessions.map(toProtocolSessionSummary) },
        },
        false,
      );
    } catch (error) {
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    }
  }

  async #handleGetSession(requestId: bigint, sessionId: string, projectId: string): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.SESSION_READ, false))) {
      return;
    }

    let observationPending: PendingAdmission | undefined;
    try {
      const snapshot = await this.#domain.getSession({
        cwd: this.#requireRegisteredProject(projectId),
        sessionId,
      });
      const observed = this.#negotiatedCapabilities.has(Capability.SESSION_EVENTS)
        ? this.#ensureObservation(snapshot)
        : undefined;
      observationPending = observed?.pending;
      await this.#sendRequestOperation(
        requestId,
        {
          case: "getSessionResponse",
          value: {
            requestId,
            session: toProtocolSessionDetail(observed?.snapshot ?? snapshot),
          },
        },
        false,
      );
    } catch (error) {
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    } finally {
      await this.#flushAdmission(sessionId, observationPending);
    }
  }

  async #handleGetSessionHistory(
    requestId: bigint,
    projectId: string,
    sessionId: string,
    cursor: string,
    limit: number,
    expectedActiveBranchRevision: string,
    expectedTreeRevision: string,
  ): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) return;
    if (!(await this.#requireCapability(requestId, Capability.SESSION_HISTORY, false))) return;
    const pageLimit = limit === 0 ? DEFAULT_HISTORY_PAGE_MESSAGES : limit;
    if (pageLimit < 1 || pageLimit > MAX_HISTORY_PAGE_MESSAGES) {
      await this.#sendRequestRejected(
        requestId,
        stableError(ErrorCode.INVALID_REQUEST, "The session history limit is invalid."),
      );
      return;
    }

    let observationPending: PendingAdmission | undefined;
    try {
      const page = await this.#domain.getSessionHistory({
        cwd: this.#requireRegisteredProject(projectId),
        sessionId,
        ...(cursor.length === 0 ? {} : { cursor }),
        limit: pageLimit,
        ...(expectedActiveBranchRevision.length === 0 ? {} : { expectedActiveBranchRevision }),
        ...(expectedTreeRevision.length === 0 ? {} : { expectedTreeRevision }),
      });
      const observed = this.#negotiatedCapabilities.has(Capability.SESSION_EVENTS)
        ? this.#ensureObservation(sessionHistoryPageToSnapshot(page))
        : undefined;
      observationPending = observed?.pending;
      await this.#sendRequestOperation(
        requestId,
        {
          case: "getSessionHistoryResponse",
          value: {
            requestId,
            summary: toProtocolSessionSummary(page.summary),
            conversation: toProtocolConversationPage(page.conversation),
          },
        },
        false,
      );
    } catch (error) {
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    } finally {
      await this.#flushAdmission(sessionId, observationPending);
    }
  }

  async #handleGetMessageContent(
    requestId: bigint,
    projectId: string,
    binding: MessageContentBinding | undefined,
    expectedMimeType: string,
    expectedTotalBytes: bigint,
    expectedSha256: Uint8Array,
  ): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) return;
    for (const capability of [
      Capability.MESSAGE_CONTENT,
      Capability.RICH_CONVERSATION,
      Capability.TRANSFER,
      Capability.FLOW_CONTROL,
      Capability.CANCELLATION,
    ]) {
      if (!(await this.#requireCapability(requestId, capability, false))) return;
    }
    if (binding === undefined || expectedTotalBytes > BigInt(Number.MAX_SAFE_INTEGER)) {
      await this.#sendRequestRejected(
        requestId,
        stableError(ErrorCode.INVALID_REQUEST, "The message content reference is invalid."),
      );
      return;
    }
    if (this.#outboundTransfers.size >= 8) {
      await this.#sendRequestRejected(
        requestId,
        stableError(ErrorCode.RESOURCE_EXHAUSTED, "Too many downloads are active."),
      );
      return;
    }

    let tempDirectory: string | undefined;
    try {
      const domainBinding: PiNodeMessageContentBinding = Object.freeze({
        sessionId: binding.sessionId,
        entryId: binding.entryId,
        partId: binding.partId,
        entryRevision: safeUint64Number(binding.entryRevision, "entry revision"),
        partRevision: safeUint64Number(binding.partRevision, "part revision"),
        contentId: binding.contentId,
      });
      const expectedLength = safeUint64Number(expectedTotalBytes, "content length");
      const content = await this.#domain.getMessageContent({
        cwd: this.#requireRegisteredProject(projectId),
        request: Object.freeze({
          binding: domainBinding,
          expectedMimeType,
          expectedTotalBytes: expectedLength,
          expectedSha256: Uint8Array.from(expectedSha256),
        }),
      });
      if (
        !sameMessageContentBinding(content.binding, domainBinding) ||
        content.reference.contentId !== domainBinding.contentId ||
        content.reference.mimeType !== expectedMimeType ||
        content.reference.totalBytes !== expectedLength ||
        content.bytes.length !== expectedLength ||
        !sameDigest(content.reference.sha256, expectedSha256)
      ) {
        throw new PiNodeDomainError(
          "session-content-invalid",
          "The message content no longer matches its requested binding.",
        );
      }
      tempDirectory = await mkdtemp(join(tmpdir(), "pi-client-message-content-"));
      await chmod(tempDirectory, 0o700);
      tempDirectory = await realpath(tempDirectory);
      const filePath = join(tempDirectory, "content.bin");
      assertContainedTransferPath(tempDirectory, filePath, "message content");
      await writeFile(filePath, content.bytes, { flag: "wx", mode: 0o600 });
      const canonicalFile = await realpath(filePath);
      assertContainedTransferPath(tempDirectory, canonicalFile, "message content");
      const metadata = await stat(canonicalFile, { bigint: true });
      if (!metadata.isFile() || metadata.size !== BigInt(content.reference.totalBytes)) {
        throw new PiNodeDomainError(
          "session-content-invalid",
          "The message content file is invalid.",
        );
      }
      const sha256 = await sha256File(canonicalFile);
      if (!sameDigest(sha256, content.reference.sha256)) {
        throw new PiNodeDomainError(
          "session-content-invalid",
          "The message content digest is invalid.",
        );
      }
      const transferId = `message-content-${randomUUID()}`;
      const chunkBytes = Math.min(EXPORT_TRANSFER_CHUNK_BYTES, this.#maxTransferChunkBytes);
      const transfer: OutboundTransfer = {
        requestId,
        transferId,
        tempDirectory,
        filePath: canonicalFile,
        fileName: content.reference.displayName,
        contentType: content.reference.mimeType,
        totalBytes: BigInt(content.reference.totalBytes),
        chunkBytes,
        sha256,
        sentEndOffsets: new Map(),
        handle: undefined,
        nextSequence: 1n,
        nextOffset: 0n,
        acknowledgedSequence: 0n,
        committedBytes: 0n,
        creditBytes: 0n,
        pumpTail: Promise.resolve(),
        closed: false,
      };
      this.#outboundTransfers.set(transferId, transfer);
      tempDirectory = undefined;
      await this.#sendOperation({
        case: "transferOpen",
        value: {
          requestId,
          transferId,
          direction: TransferDirection.DOWNLOAD,
          purpose: TransferPurpose.MESSAGE_CONTENT,
          contentType: transfer.contentType,
          fileName: transfer.fileName,
          totalBytes: transfer.totalBytes,
          chunkBytes,
          sha256,
          messageContentBinding: toProtocolMessageContentBinding(content.binding),
        },
      });
    } catch (error) {
      if (tempDirectory !== undefined) await removePrivateTempDirectory(tempDirectory);
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    }
  }

  async #handleGetSessionStats(
    requestId: bigint,
    projectId: string,
    sessionId: string,
  ): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) return;
    if (!(await this.#requireCapability(requestId, Capability.SESSION_STATS, false))) return;
    try {
      const stats = await this.#domain.getSessionStats({
        cwd: this.#requireRegisteredProject(projectId),
        sessionId,
      });
      await this.#sendRequestOperation(
        requestId,
        {
          case: "getSessionStatsResponse",
          value: { requestId, stats: toProtocolSessionStats(stats) },
        },
        false,
      );
    } catch (error) {
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    }
  }

  async #handleCreateSession(requestId: bigint, projectId: string): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.SESSION_CREATE, false))) {
      return;
    }

    let sessionId: string | undefined;
    let observationPending: PendingAdmission | undefined;
    try {
      const snapshot = await this.#domain.createSession({
        cwd: this.#requireRegisteredProject(projectId),
      });
      sessionId = snapshot.sessionId;
      const observed = this.#negotiatedCapabilities.has(Capability.SESSION_EVENTS)
        ? this.#ensureObservation(snapshot)
        : undefined;
      observationPending = observed?.pending;
      await this.#sendRequestOperation(
        requestId,
        {
          case: "createSessionResponse",
          value: {
            requestId,
            session: toProtocolSessionDetail(observed?.snapshot ?? snapshot),
          },
        },
        false,
      );
    } catch (error) {
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    } finally {
      if (sessionId) {
        await this.#flushAdmission(sessionId, observationPending);
      }
    }
  }

  async #handleGetSessionTree(
    requestId: bigint,
    projectId: string,
    sessionId: string,
  ): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) return;
    if (!(await this.#requireCapability(requestId, Capability.SESSION_TREE, false))) return;
    try {
      const tree = await this.#domain.getSessionTree({
        cwd: this.#requireRegisteredProject(projectId),
        sessionId,
      });
      await this.#sendRequestOperation(
        requestId,
        {
          case: "getSessionTreeResponse",
          value: { requestId, tree: toProtocolSessionTree(tree) },
        },
        false,
      );
    } catch (error) {
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    }
  }

  async #handleNavigateSessionTree(
    requestId: bigint,
    commandId: string,
    projectId: string,
    sessionId: string,
    entryId: string,
    expectedAdminRevision: string,
  ): Promise<void> {
    await this.#handleSessionTreeMutation(
      requestId,
      commandId,
      projectId,
      sessionId,
      SessionTreeMutationOperation.NAVIGATE,
      () =>
        this.#domain.navigateSessionTree({
          cwd: this.#requireRegisteredProject(projectId),
          sessionId,
          entryId,
          expectedAdminRevision,
        }),
    );
  }

  async #handleForkSession(
    requestId: bigint,
    commandId: string,
    projectId: string,
    sessionId: string,
    userEntryId: string,
    expectedAdminRevision: string,
  ): Promise<void> {
    await this.#handleSessionTreeMutation(
      requestId,
      commandId,
      projectId,
      sessionId,
      SessionTreeMutationOperation.FORK,
      () =>
        this.#domain.forkSession({
          cwd: this.#requireRegisteredProject(projectId),
          sessionId,
          userEntryId,
          expectedAdminRevision,
        }),
    );
  }

  async #handleCloneSession(
    requestId: bigint,
    commandId: string,
    projectId: string,
    sessionId: string,
    expectedAdminRevision: string,
  ): Promise<void> {
    await this.#handleSessionTreeMutation(
      requestId,
      commandId,
      projectId,
      sessionId,
      SessionTreeMutationOperation.CLONE,
      () =>
        this.#domain.cloneSession({
          cwd: this.#requireRegisteredProject(projectId),
          sessionId,
          expectedAdminRevision,
        }),
    );
  }

  async #handleSessionTreeMutation(
    requestId: bigint,
    commandId: string,
    projectId: string,
    sessionId: string,
    operation: SessionTreeMutationOperation,
    mutate: () => ReturnType<PiNodeProtocolDomain["navigateSessionTree"]>,
  ): Promise<void> {
    if (!(await this.#claimRequest(requestId, true, commandId))) return;
    if (!(await this.#claimCommand(requestId, commandId))) return;
    if (!(await this.#requireCapability(requestId, Capability.SESSION_TREE, true, commandId))) {
      return;
    }
    try {
      this.#requireRegisteredProject(projectId);
      this.#dropObservation(sessionId);
      const result = await mutate();
      await this.#sendSessionTreeMutationOutcome(requestId, commandId, operation, {
        case: "result",
        value: {
          session: toProtocolSessionDetail(result.session),
          tree: toProtocolSessionTree(result.tree),
          editorText: result.editorText ?? "",
        },
      });
    } catch (error) {
      await this.#sendSessionTreeMutationOutcome(requestId, commandId, operation, {
        case: "error",
        value: mapDomainError(error),
      });
    }
  }

  async #sendSessionTreeMutationOutcome(
    requestId: bigint,
    commandId: string,
    operation: SessionTreeMutationOperation,
    outcome:
      | {
          readonly case: "result";
          readonly value: {
            readonly session: ReturnType<typeof toProtocolSessionDetail>;
            readonly tree: ReturnType<typeof toProtocolSessionTree>;
            readonly editorText: string;
          };
        }
      | { readonly case: "error"; readonly value: StableError },
  ): Promise<void> {
    await this.#sendRequestOperation(
      requestId,
      {
        case: "sessionTreeMutationOutcome",
        value: { requestId, commandId, operation, outcome },
      },
      true,
      commandId,
    );
  }

  #registerProject(project: PiNodeProjectSnapshot): void {
    this.#projectWorkingDirectories.set(project.identity.projectId, project.identity.canonicalCwd);
  }

  #requireRegisteredProject(projectId: string): string {
    const cwd = this.#projectWorkingDirectories.get(projectId);
    if (!cwd) {
      throw new PiNodeDomainError(
        "project-not-registered",
        "The project must be validated on this connection before use.",
      );
    }
    return cwd;
  }

  async #handlePrompt(
    requestId: bigint,
    commandId: string,
    sessionId: string,
    prompt: string,
  ): Promise<void> {
    if (!(await this.#claimRequest(requestId, true, commandId))) {
      return;
    }
    if (!(await this.#claimCommand(requestId, commandId))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.PROMPT_COMMAND, true, commandId))) {
      return;
    }

    const pending = this.#beginAdmission(sessionId);
    try {
      const admission = await this.#domain.submitPrompt({ sessionId, commandId, text: prompt });
      if (admission.status === "rejected") {
        await this.#sendCommandRejected(
          requestId,
          commandId,
          mapCommandFailure(
            admission.failure ?? {
              code: "prompt-rejected",
              message: "The prompt was rejected.",
            },
          ),
        );
      } else if (admission.status === "uncertain") {
        await this.#sendOperation({
          case: "error",
          value: {
            correlation: { case: "requestId", value: requestId },
            error: mapCommandFailure(
              admission.failure ?? {
                code: "runtime-failed",
                message: "Prompt admission could not be confirmed.",
              },
            ),
          },
        });
      } else {
        await this.#sendOperation({
          case: "commandAccepted",
          value: { requestId, commandId },
        });
      }
    } catch (error) {
      await this.#sendCommandRejected(requestId, commandId, mapDomainError(error));
    } finally {
      await this.#flushAdmission(sessionId, pending);
    }
  }

  async #handleAbort(requestId: bigint, commandId: string, sessionId: string): Promise<void> {
    if (!(await this.#claimRequest(requestId, true, commandId))) {
      return;
    }
    if (!(await this.#claimCommand(requestId, commandId))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.ABORT_COMMAND, true, commandId))) {
      return;
    }

    const pending = this.#beginAdmission(sessionId);
    try {
      const result = await this.#domain.abort({ sessionId });
      if (result.status === "not-running") {
        await this.#sendCommandRejected(
          requestId,
          commandId,
          stableError(ErrorCode.FAILED_PRECONDITION, "The session has no active command."),
        );
      } else {
        await this.#sendOperation({
          case: "commandAccepted",
          value: { requestId, commandId },
        });
      }
    } catch (error) {
      await this.#sendCommandRejected(requestId, commandId, mapDomainError(error));
    } finally {
      await this.#flushAdmission(sessionId, pending);
    }
  }

  async #handleRenameSession(
    requestId: bigint,
    commandId: string,
    projectId: string,
    sessionId: string,
    name: string,
  ): Promise<void> {
    if (!(await this.#claimAdminCommand(requestId, commandId))) return;
    try {
      const cwd = this.#requireRegisteredProject(projectId);
      this.#dropObservation(sessionId);
      const session = await this.#domain.renameSession({
        cwd,
        sessionId,
        name,
      });
      await this.#sendSessionAdminOutcome(requestId, commandId, SessionAdminOperation.RENAME, {
        case: "session",
        value: toProtocolSessionSummary(session),
      });
    } catch (error) {
      await this.#sendSessionAdminOutcome(requestId, commandId, SessionAdminOperation.RENAME, {
        case: "error",
        value: mapDomainError(error),
      });
    }
  }

  async #handleClearSessionName(
    requestId: bigint,
    commandId: string,
    projectId: string,
    sessionId: string,
  ): Promise<void> {
    if (!(await this.#claimAdminCommand(requestId, commandId))) return;
    try {
      const cwd = this.#requireRegisteredProject(projectId);
      this.#dropObservation(sessionId);
      const session = await this.#domain.clearSessionName({
        cwd,
        sessionId,
      });
      await this.#sendSessionAdminOutcome(requestId, commandId, SessionAdminOperation.CLEAR_NAME, {
        case: "session",
        value: toProtocolSessionSummary(session),
      });
    } catch (error) {
      await this.#sendSessionAdminOutcome(requestId, commandId, SessionAdminOperation.CLEAR_NAME, {
        case: "error",
        value: mapDomainError(error),
      });
    }
  }

  async #handleAutoNameSession(
    requestId: bigint,
    commandId: string,
    projectId: string,
    sessionId: string,
    timeoutMillis: number,
  ): Promise<void> {
    if (!(await this.#claimAdminCommand(requestId, commandId))) return;
    const controller = new AbortController();
    this.#adminAbortControllers.set(requestId, controller);
    try {
      const cwd = this.#requireRegisteredProject(projectId);
      this.#dropObservation(sessionId);
      const session = await this.#domain.autoNameSession({
        cwd,
        sessionId,
        timeoutMillis,
        signal: controller.signal,
      });
      await this.#sendSessionAdminOutcome(requestId, commandId, SessionAdminOperation.AUTO_NAME, {
        case: "session",
        value: toProtocolSessionSummary(session),
      });
    } catch (error) {
      await this.#sendSessionAdminOutcome(requestId, commandId, SessionAdminOperation.AUTO_NAME, {
        case: "error",
        value: mapDomainError(error),
      });
    } finally {
      this.#adminAbortControllers.delete(requestId);
    }
  }

  async #handleDeleteSession(
    requestId: bigint,
    commandId: string,
    projectId: string,
    sessionId: string,
    confirmation:
      | {
          readonly sessionId: string;
          readonly adminRevision: string;
          readonly displayedTitle: string;
          readonly destructiveActionAcknowledged: boolean;
        }
      | undefined,
  ): Promise<void> {
    if (!(await this.#claimAdminCommand(requestId, commandId))) return;
    try {
      const cwd = this.#requireRegisteredProject(projectId);
      this.#dropObservation(sessionId);
      const deletion = await this.#domain.deleteSession({
        cwd,
        sessionId,
        confirmation: confirmation ?? {
          sessionId: "",
          adminRevision: "",
          displayedTitle: "",
          destructiveActionAcknowledged: false,
        },
      });
      await this.#sendSessionAdminOutcome(requestId, commandId, SessionAdminOperation.DELETE, {
        case: "deletion",
        value: {
          sessionId: deletion.sessionId,
          reparentedChildCount: deletion.reparentedChildCount,
        },
      });
    } catch (error) {
      await this.#sendSessionAdminOutcome(requestId, commandId, SessionAdminOperation.DELETE, {
        case: "error",
        value: mapDomainError(error),
      });
    }
  }

  async #handleExportSession(
    requestId: bigint,
    projectId: string,
    sessionId: string,
    format: SessionExportFormat,
    expectedActiveBranchRevision: string,
    expectedTreeRevision: string,
  ): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) return;
    for (const capability of [
      Capability.SESSION_EXPORT,
      Capability.TRANSFER,
      Capability.FLOW_CONTROL,
      Capability.CANCELLATION,
    ]) {
      if (!(await this.#requireCapability(requestId, capability, false))) return;
    }
    if (this.#outboundTransfers.size >= 8) {
      await this.#sendRequestRejected(
        requestId,
        stableError(ErrorCode.RESOURCE_EXHAUSTED, "Too many exports are active."),
      );
      return;
    }

    const exportFormat =
      format === SessionExportFormat.HTML
        ? "html"
        : format === SessionExportFormat.JSONL
          ? "jsonl"
          : undefined;
    if (exportFormat === undefined) {
      await this.#sendRequestRejected(
        requestId,
        stableError(ErrorCode.INVALID_REQUEST, "The export format is invalid."),
      );
      return;
    }

    let tempDirectory: string | undefined;
    try {
      const cwd = this.#requireRegisteredProject(projectId);
      tempDirectory = await mkdtemp(join(tmpdir(), "pi-client-export-"));
      await chmod(tempDirectory, 0o700);
      tempDirectory = await realpath(tempDirectory);
      const fileName =
        exportFormat === "html" ? "Pi-Client-session.html" : "Pi-Client-session.jsonl";
      const filePath = join(tempDirectory, fileName);
      assertContainedExportPath(tempDirectory, filePath);
      await this.#domain.exportSession({
        cwd,
        sessionId,
        format: exportFormat,
        outputPath: filePath,
        ...(expectedActiveBranchRevision.length === 0 ? {} : { expectedActiveBranchRevision }),
        ...(expectedTreeRevision.length === 0 ? {} : { expectedTreeRevision }),
      });
      const canonicalFile = await realpath(filePath);
      assertContainedExportPath(tempDirectory, canonicalFile);
      const metadata = await stat(canonicalFile, { bigint: true });
      if (
        !metadata.isFile() ||
        metadata.size <= 0n ||
        metadata.size > BigInt(Number.MAX_SAFE_INTEGER)
      ) {
        throw new PiNodeDomainError("session-export-failed", "The generated export is invalid.");
      }
      await chmod(canonicalFile, 0o600);
      const transferId = `export-${randomUUID()}`;
      const chunkBytes = Math.min(EXPORT_TRANSFER_CHUNK_BYTES, this.#maxTransferChunkBytes);
      const sha256 = await sha256File(canonicalFile);
      const transfer: OutboundTransfer = {
        requestId,
        transferId,
        tempDirectory,
        filePath: canonicalFile,
        fileName,
        contentType: exportFormat === "html" ? "text/html; charset=utf-8" : "application/x-ndjson",
        totalBytes: metadata.size,
        chunkBytes,
        sha256,
        sentEndOffsets: new Map(),
        handle: undefined,
        nextSequence: 1n,
        nextOffset: 0n,
        acknowledgedSequence: 0n,
        committedBytes: 0n,
        creditBytes: 0n,
        pumpTail: Promise.resolve(),
        closed: false,
      };
      this.#outboundTransfers.set(transferId, transfer);
      tempDirectory = undefined;
      await this.#sendOperation({
        case: "transferOpen",
        value: {
          requestId,
          transferId,
          direction: TransferDirection.DOWNLOAD,
          purpose: TransferPurpose.EXPORT,
          contentType: transfer.contentType,
          fileName,
          totalBytes: transfer.totalBytes,
          chunkBytes,
          sha256,
        },
      });
    } catch (error) {
      if (tempDirectory !== undefined) await removePrivateTempDirectory(tempDirectory);
      await this.#sendRequestRejected(requestId, mapDomainError(error));
    }
  }

  async #handleCancel(cancel: {
    readonly target:
      | { readonly case: "requestId"; readonly value: bigint }
      | { readonly case: "streamId"; readonly value: string }
      | { readonly case: "transferId"; readonly value: string }
      | { readonly case: undefined; readonly value?: undefined };
  }): Promise<void> {
    if (!this.#negotiatedCapabilities.has(Capability.CANCELLATION)) {
      await this.#failProtocol("Cancellation was not negotiated.");
      return;
    }
    switch (cancel.target.case) {
      case "requestId":
        this.#adminAbortControllers.get(cancel.target.value)?.abort();
        return;
      case "transferId": {
        const transfer = this.#outboundTransfers.get(cancel.target.value);
        if (transfer !== undefined) {
          await this.#abortTransfer(
            transfer,
            stableError(ErrorCode.CANCELLED, "The export was cancelled."),
            true,
          );
        }
        return;
      }
      case "streamId": {
        const observed = [...this.#observations.values()].find(
          (entry) => entry.streamId === cancel.target.value,
        );
        if (observed !== undefined) this.#dropObservation(observed.sessionId);
        return;
      }
      case undefined:
        await this.#failProtocol("Cancellation target is missing.");
    }
  }

  async #handleWindowUpdate(update: {
    readonly target:
      | { readonly case: "streamId"; readonly value: string }
      | { readonly case: "transferId"; readonly value: string }
      | { readonly case: undefined; readonly value?: undefined };
    readonly creditMessages: number;
    readonly creditBytes: bigint;
  }): Promise<void> {
    if (!this.#negotiatedCapabilities.has(Capability.FLOW_CONTROL)) {
      await this.#failProtocol("Flow control was not negotiated.");
      return;
    }
    if (update.target.case !== "transferId" || update.creditMessages !== 0) {
      await this.#failProtocol("Only byte credit for an export transfer is supported.");
      return;
    }
    const transfer = this.#outboundTransfers.get(update.target.value);
    if (transfer === undefined || transfer.closed) return;
    if (update.creditBytes <= 0n) {
      await this.#abortTransfer(
        transfer,
        stableError(ErrorCode.PROTOCOL_VIOLATION, "Export byte credit is invalid."),
        true,
      );
      return;
    }
    const nextCredit = transfer.creditBytes + update.creditBytes;
    if (nextCredit > BigInt(MAX_TRANSFER_CREDIT_BYTES)) {
      await this.#abortTransfer(
        transfer,
        stableError(ErrorCode.RESOURCE_EXHAUSTED, "Export byte credit is too large."),
        true,
      );
      return;
    }
    transfer.creditBytes = nextCredit;
    await this.#scheduleTransferPump(transfer);
  }

  async #handleTransferAck(ack: {
    readonly transferId: string;
    readonly acknowledgedSequence: bigint;
    readonly committedBytes: bigint;
  }): Promise<void> {
    if (!this.#negotiatedCapabilities.has(Capability.TRANSFER)) {
      await this.#failProtocol("Transfers were not negotiated.");
      return;
    }
    const transfer = this.#outboundTransfers.get(ack.transferId);
    if (transfer === undefined || transfer.closed) return;
    const expectedCommitted = transfer.sentEndOffsets.get(ack.acknowledgedSequence);
    if (
      expectedCommitted === undefined ||
      ack.acknowledgedSequence <= transfer.acknowledgedSequence ||
      ack.committedBytes !== expectedCommitted ||
      ack.committedBytes <= transfer.committedBytes
    ) {
      await this.#abortTransfer(
        transfer,
        stableError(ErrorCode.PROTOCOL_VIOLATION, "Export acknowledgement is invalid."),
        true,
      );
      return;
    }
    transfer.acknowledgedSequence = ack.acknowledgedSequence;
    transfer.committedBytes = ack.committedBytes;
    for (const sequence of [...transfer.sentEndOffsets.keys()]) {
      if (sequence <= ack.acknowledgedSequence) transfer.sentEndOffsets.delete(sequence);
    }
    if (
      transfer.committedBytes === transfer.totalBytes &&
      transfer.nextOffset === transfer.totalBytes &&
      transfer.sentEndOffsets.size === 0
    ) {
      await this.#completeTransfer(transfer);
      return;
    }
    await this.#scheduleTransferPump(transfer);
  }

  async #scheduleTransferPump(transfer: OutboundTransfer): Promise<void> {
    transfer.pumpTail = transfer.pumpTail.then(() => this.#pumpTransfer(transfer));
    try {
      await transfer.pumpTail;
    } catch (error) {
      await this.#abortTransfer(transfer, mapDomainError(error), true);
    }
  }

  async #pumpTransfer(transfer: OutboundTransfer): Promise<void> {
    if (transfer.closed || this.#terminal) return;
    transfer.handle ??= await open(transfer.filePath, "r");
    while (
      !transfer.closed &&
      transfer.creditBytes > 0n &&
      transfer.nextOffset < transfer.totalBytes &&
      transfer.sentEndOffsets.size < MAX_OUTSTANDING_TRANSFER_CHUNKS
    ) {
      const remaining = transfer.totalBytes - transfer.nextOffset;
      const requested = Number(
        [BigInt(transfer.chunkBytes), transfer.creditBytes, remaining].reduce((left, right) =>
          left < right ? left : right,
        ),
      );
      const buffer = Buffer.allocUnsafe(requested);
      const result = await transfer.handle.read(buffer, 0, requested, Number(transfer.nextOffset));
      if (result.bytesRead <= 0) {
        throw new PiNodeDomainError("session-export-failed", "The export ended unexpectedly.");
      }
      const data = buffer.subarray(0, result.bytesRead);
      const sequence = transfer.nextSequence;
      const offset = transfer.nextOffset;
      const endOffset = offset + BigInt(result.bytesRead);
      await this.#sendOperation({
        case: "transferChunk",
        value: { transferId: transfer.transferId, chunkSequence: sequence, offset, data },
      });
      transfer.sentEndOffsets.set(sequence, endOffset);
      transfer.nextSequence += 1n;
      transfer.nextOffset = endOffset;
      transfer.creditBytes -= BigInt(result.bytesRead);
    }
  }

  async #completeTransfer(transfer: OutboundTransfer): Promise<void> {
    if (transfer.closed) return;
    transfer.closed = true;
    await transfer.handle?.close();
    transfer.handle = undefined;
    try {
      await this.#sendOperation({
        case: "transferComplete",
        value: {
          transferId: transfer.transferId,
          totalBytes: transfer.totalBytes,
          sha256: transfer.sha256,
        },
      });
    } finally {
      this.#outboundTransfers.delete(transfer.transferId);
      await removePrivateTempDirectory(transfer.tempDirectory);
    }
  }

  async #abortTransfer(
    transfer: OutboundTransfer,
    error: StableError,
    notifyPeer: boolean,
  ): Promise<void> {
    if (transfer.closed) return;
    transfer.closed = true;
    this.#outboundTransfers.delete(transfer.transferId);
    await transfer.handle?.close().catch(() => undefined);
    transfer.handle = undefined;
    try {
      if (notifyPeer && !this.#terminal) {
        await this.#sendOperation({
          case: "transferAbort",
          value: { transferId: transfer.transferId, error },
        });
      }
    } finally {
      await removePrivateTempDirectory(transfer.tempDirectory);
    }
  }

  async #releaseTransfers(): Promise<void> {
    const transfers = [...this.#outboundTransfers.values()];
    for (const transfer of transfers) {
      await this.#abortTransfer(
        transfer,
        stableError(ErrorCode.CANCELLED, "The connection closed."),
        false,
      );
    }
  }

  async #claimAdminCommand(requestId: bigint, commandId: string): Promise<boolean> {
    if (!(await this.#claimRequest(requestId, true, commandId))) return false;
    if (!(await this.#claimCommand(requestId, commandId))) return false;
    return this.#requireCapability(requestId, Capability.SESSION_ADMIN, true, commandId);
  }

  #dropObservation(sessionId: string): void {
    const entry = this.#observations.get(sessionId);
    if (!entry) return;
    entry.closed = true;
    entry.unsubscribe();
    this.#observations.delete(sessionId);
    this.#pendingAdmissions.delete(sessionId);
  }

  async #sendSessionAdminOutcome(
    requestId: bigint,
    commandId: string,
    operation: SessionAdminOperation,
    outcome:
      | { readonly case: "session"; readonly value: ReturnType<typeof toProtocolSessionSummary> }
      | {
          readonly case: "deletion";
          readonly value: { readonly sessionId: string; readonly reparentedChildCount: number };
        }
      | { readonly case: "error"; readonly value: StableError },
  ): Promise<void> {
    await this.#sendRequestOperation(
      requestId,
      {
        case: "sessionAdminCommandOutcome",
        value: { requestId, commandId, operation, outcome },
      },
      true,
      commandId,
    );
  }

  async #handleUnsupportedRequest(requestId: bigint): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    await this.#sendRequestRejected(
      requestId,
      stableError(
        ErrorCode.FAILED_PRECONDITION,
        "The requested capability is not implemented by this unpublished v0 server.",
      ),
    );
  }

  async #claimRequest(
    requestId: bigint,
    command: boolean,
    commandId = "unknown-command",
  ): Promise<boolean> {
    if (this.#requestIds.size >= MAX_TRACKED_IDENTIFIERS) {
      await this.#failProtocol("The request identifier retention limit was exceeded.");
      return false;
    }
    if (this.#requestIds.has(requestId)) {
      const error = stableError(ErrorCode.ALREADY_EXISTS, "The request_id was already used.");
      if (command) {
        await this.#sendCommandRejected(requestId, commandId, error);
      } else {
        await this.#sendRequestRejected(requestId, error);
      }
      return false;
    }
    this.#requestIds.add(requestId);
    return true;
  }

  async #claimCommand(requestId: bigint, commandId: string): Promise<boolean> {
    if (this.#commandIds.size >= MAX_TRACKED_IDENTIFIERS) {
      await this.#failProtocol("The command identifier retention limit was exceeded.");
      return false;
    }
    if (this.#commandIds.has(commandId)) {
      await this.#sendCommandRejected(
        requestId,
        commandId,
        stableError(ErrorCode.ALREADY_EXISTS, "The command_id was already used."),
      );
      return false;
    }
    this.#commandIds.add(commandId);
    return true;
  }

  async #requireCapability(
    requestId: bigint,
    capability: Capability,
    command: boolean,
    commandId = "unknown-command",
  ): Promise<boolean> {
    if (this.#negotiatedCapabilities.has(capability)) {
      return true;
    }
    const error = stableError(
      ErrorCode.FAILED_PRECONDITION,
      "The requested operation was not negotiated.",
    );
    if (command) {
      await this.#sendCommandRejected(requestId, commandId, error);
    } else {
      await this.#sendRequestRejected(requestId, error);
    }
    return false;
  }

  #ensureObservation(snapshot: PiNodeSessionSnapshot): {
    readonly snapshot: PiNodeSessionSnapshot;
    readonly entry: ObservedSession;
    readonly pending?: PendingAdmission;
  } {
    const existing = this.#observations.get(snapshot.sessionId);
    if (existing) {
      return { snapshot, entry: existing };
    }

    const pending = { events: [] } satisfies PendingAdmission;
    this.#pendingAdmissions.set(snapshot.sessionId, pending);
    const entry: ObservedSession = {
      sessionId: snapshot.sessionId,
      streamId: this.#streamIdFactory(snapshot.sessionId, ++this.#streamOrdinal),
      unsubscribe: () => {},
      lastDomainSequence: snapshot.conversation.lastEventSequence,
      eventSequence: BigInt(snapshot.conversation.lastEventSequence),
      eventTail: Promise.resolve(),
      closed: false,
    };
    this.#observations.set(snapshot.sessionId, entry);

    try {
      const observation = this.#domain.observeSession(snapshot.sessionId, (event) =>
        this.#acceptDomainEvent(entry, event),
      );
      entry.unsubscribe = observation.unsubscribe;
      entry.lastDomainSequence = observation.snapshot.conversation.lastEventSequence;
      entry.eventSequence = BigInt(observation.snapshot.conversation.lastEventSequence);
      return { snapshot: observation.snapshot, entry, pending };
    } catch (error) {
      this.#observations.delete(snapshot.sessionId);
      this.#pendingAdmissions.delete(snapshot.sessionId);
      throw error;
    }
  }

  #acceptDomainEvent(entry: ObservedSession, event: PiNodeSessionEvent): void {
    if (this.#terminal || entry.closed) {
      return;
    }
    const pending = this.#pendingAdmissions.get(entry.sessionId);
    if (pending) {
      pending.events.push(event);
      return;
    }
    entry.eventTail = entry.eventTail
      .then(() => this.#forwardDomainEvent(entry, event))
      .catch(() => this.#closeObservation(entry, mapDomainError(undefined)));
  }

  #beginAdmission(sessionId: string): PendingAdmission | undefined {
    const entry = this.#observations.get(sessionId);
    if (!entry || entry.closed) {
      return undefined;
    }
    const pending = { events: [] } satisfies PendingAdmission;
    this.#pendingAdmissions.set(sessionId, pending);
    return pending;
  }

  async #flushAdmission(sessionId: string, pending: PendingAdmission | undefined): Promise<void> {
    if (!pending || this.#pendingAdmissions.get(sessionId) !== pending) {
      return;
    }
    const entry = this.#observations.get(sessionId);
    let index = 0;
    while (entry && !entry.closed && index < pending.events.length) {
      const event = pending.events[index++];
      if (event) {
        try {
          await this.#forwardDomainEvent(entry, event);
        } catch (error) {
          await this.#closeObservation(entry, mapDomainError(error));
        }
      }
    }
    this.#pendingAdmissions.delete(sessionId);
  }

  async #forwardDomainEvent(entry: ObservedSession, event: PiNodeSessionEvent): Promise<void> {
    if (entry.closed || this.#terminal) {
      return;
    }
    if (event.sequence <= entry.lastDomainSequence) {
      await this.#closeObservation(
        entry,
        stableError(ErrorCode.DATA_LOSS, "The session event sequence is invalid."),
      );
      return;
    }
    entry.lastDomainSequence = event.sequence;

    switch (event.type) {
      case "running":
        await this.#sendSessionEvent(entry, {
          case: "runningChanged",
          value: { isRunning: event.running },
        });
        return;
      case "command-completed":
        await this.#sendSessionEvent(entry, {
          case: "commandCompleted",
          value:
            event.outcome === "succeeded"
              ? { commandId: event.commandId, succeeded: true }
              : {
                  commandId: event.commandId,
                  succeeded: false,
                  error: mapCommandFailure(
                    event.failure ?? {
                      code: event.outcome === "aborted" ? "aborted" : "runtime-failed",
                      message: "The command did not succeed.",
                    },
                  ),
                },
        });
        return;
      case "entry-upsert":
        await this.#sendSessionEvent(entry, {
          case: "entryUpsert",
          value: {
            entry: toProtocolConversationEntry(event.entry),
            ...(event.expectedPreviousRevision === undefined
              ? {}
              : {
                  expectedPreviousRevision: BigInt(event.expectedPreviousRevision),
                }),
          },
        });
        return;
      case "part-delta":
        await this.#sendSessionEvent(entry, {
          case: "partDelta",
          value: {
            entryId: event.entryId,
            expectedEntryRevision: BigInt(event.expectedEntryRevision),
            resultingEntryRevision: BigInt(event.resultingEntryRevision),
            partId: event.partId,
            expectedPartRevision: BigInt(event.expectedPartRevision),
            resultingPartRevision: BigInt(event.resultingPartRevision),
            textDelta: event.textDelta,
          },
        });
        return;
      case "entry-finalized":
        await this.#sendSessionEvent(entry, {
          case: "entryFinalized",
          value: {
            entry: toProtocolConversationEntry(event.entry),
            expectedPreviousRevision: BigInt(event.expectedPreviousRevision),
          },
        });
        return;
      case "tool-activity":
        await this.#sendSessionEvent(entry, {
          case: "toolActivity",
          value: {
            entryId: event.entryId,
            expectedEntryRevision: BigInt(event.expectedEntryRevision),
            resultingEntryRevision: BigInt(event.resultingEntryRevision),
            activity: toProtocolToolActivity(event.activity),
          },
        });
        return;
      case "metrics":
        await this.#sendSessionEvent(entry, {
          case: "metrics",
          value: {
            entryId: event.entryId,
            expectedEntryRevision: BigInt(event.expectedEntryRevision),
            resultingEntryRevision: BigInt(event.resultingEntryRevision),
            metrics: toProtocolConversationMetrics(event.metrics),
          },
        });
        return;
    }
  }

  async #sendSessionEvent(
    entry: ObservedSession,
    event: NonNullable<MessageInitShape<typeof SessionEventStreamEnvelopeSchema>["event"]>,
  ): Promise<void> {
    const nextEventSequence = entry.eventSequence + 1n;
    try {
      await this.#sendOperation({
        case: "sessionEventStream",
        value: {
          streamId: entry.streamId,
          sessionId: entry.sessionId,
          eventSequence: nextEventSequence,
          event,
        },
      });
      entry.eventSequence = nextEventSequence;
    } catch (error) {
      await this.#closeObservation(
        entry,
        error instanceof OutboundFrameLimitError
          ? stableError(
              ErrorCode.RESOURCE_EXHAUSTED,
              "A session event exceeds the negotiated frame limit.",
            )
          : mapDomainError(error),
      );
    }
  }

  async #closeObservation(entry: ObservedSession, error: StableError): Promise<void> {
    if (entry.closed) {
      return;
    }
    entry.closed = true;
    entry.unsubscribe();
    this.#observations.delete(entry.sessionId);
    this.#pendingAdmissions.delete(entry.sessionId);
    this.#logger?.info("stream-closed");

    if (!this.#terminal) {
      const nextEventSequence = entry.eventSequence + 1n;
      try {
        await this.#sendOperation({
          case: "sessionEventStream",
          value: {
            streamId: entry.streamId,
            sessionId: entry.sessionId,
            eventSequence: nextEventSequence,
            event: {
              case: "streamClosed",
              value: { graceful: false, error },
            },
          },
        });
        entry.eventSequence = nextEventSequence;
      } catch {
        this.#terminal = true;
      }
    }
  }

  async #sendRequestOperation(
    requestId: bigint,
    operation: FrameOperationInit,
    command: boolean,
    commandId = "unknown-command",
  ): Promise<void> {
    try {
      await this.#sendOperation(operation);
    } catch (error) {
      if (!(error instanceof OutboundFrameLimitError)) {
        throw error;
      }
      const limitError = stableError(
        ErrorCode.RESOURCE_EXHAUSTED,
        "The response exceeds the negotiated frame limit.",
      );
      if (command) {
        await this.#sendCommandRejected(requestId, commandId, limitError);
      } else {
        await this.#sendRequestRejected(requestId, limitError);
      }
    }
  }

  async #sendRequestRejected(requestId: bigint, error: StableError): Promise<void> {
    await this.#sendOperation({
      case: "requestRejected",
      value: { requestId, error },
    });
  }

  async #sendCommandRejected(
    requestId: bigint,
    commandId: string,
    error: StableError,
  ): Promise<void> {
    await this.#sendOperation({
      case: "commandRejected",
      value: { requestId, commandId, error },
    });
  }

  async #sendOperation(operation: FrameOperationInit): Promise<void> {
    const nextSequence = this.#lastServerFrameSequence + 1n;
    const frame = create(PiTransportFrameSchema, {
      frameSequence: nextSequence,
      operation,
    });
    const payload = encodeTransportFrame(frame);
    if (payload.length > this.#maxOutboundFrameBytes) {
      throw new OutboundFrameLimitError();
    }
    this.#lastServerFrameSequence = nextSequence;

    const write = this.#writeTail.then(() => this.#writeFrame(payload));
    this.#writeTail = write.then(
      () => undefined,
      () => {
        this.#logger?.error("output-failed");
        this.#terminal = true;
      },
    );
    await write;
  }

  async #failProtocol(safeMessage: string): Promise<PiNodeProtocolReceiveResult> {
    if (!this.#terminal) {
      this.#logger?.error("protocol-violation");
      try {
        await this.#sendOperation({
          case: "error",
          value: {
            correlation: { case: undefined },
            error: stableError(ErrorCode.PROTOCOL_VIOLATION, safeMessage),
          },
        });
      } catch {
        // Broken output or a tiny negotiated limit cannot be repaired on this connection.
      }
    }
    this.#terminal = true;
    await this.#releaseObservations();
    await this.#releaseTransfers();
    return { close: true, reason: "protocol-error" };
  }

  async #releaseObservations(): Promise<void> {
    const entries = [...this.#observations.values()].sort((left, right) =>
      left.sessionId.localeCompare(right.sessionId),
    );
    this.#observations.clear();
    this.#pendingAdmissions.clear();
    for (const entry of entries) {
      entry.closed = true;
      entry.unsubscribe();
    }
    await Promise.all(entries.map((entry) => entry.eventTail.catch(() => undefined)));
  }
}

function sessionHistoryPageToSnapshot(page: PiNodeSessionHistoryPage): PiNodeSessionSnapshot {
  return Object.freeze({
    ...page.summary,
    persistence: "persistent",
    conversation: Object.freeze({
      sessionId: page.conversation.sessionId,
      entries: page.conversation.entries,
      lastEventSequence: page.conversation.lastEventSequence,
    }),
  });
}

async function sha256File(path: string): Promise<Uint8Array> {
  const hash = createHash("sha256");
  for await (const chunk of createReadStream(path, {
    highWaterMark: EXPORT_TRANSFER_CHUNK_BYTES,
  })) {
    hash.update(chunk as Buffer);
  }
  return new Uint8Array(hash.digest());
}

function safeUint64Number(value: bigint, label: string): number {
  if (value < 0n || value > BigInt(Number.MAX_SAFE_INTEGER)) {
    throw new TypeError(`The ${label} is outside the safe integer range.`);
  }
  return Number(value);
}

function sameMessageContentBinding(
  left: PiNodeMessageContentBinding,
  right: PiNodeMessageContentBinding,
): boolean {
  return (
    left.sessionId === right.sessionId &&
    left.entryId === right.entryId &&
    left.partId === right.partId &&
    left.entryRevision === right.entryRevision &&
    left.partRevision === right.partRevision &&
    left.contentId === right.contentId
  );
}

function sameDigest(left: Uint8Array, right: Uint8Array): boolean {
  if (left.length !== right.length) return false;
  let difference = 0;
  for (let index = 0; index < left.length; index += 1) {
    difference |= left[index]! ^ right[index]!;
  }
  return difference === 0;
}

function assertContainedTransferPath(root: string, candidate: string, label: string): void {
  const child = relative(root, candidate);
  if (
    child.length === 0 ||
    child.startsWith(`..${process.platform === "win32" ? "\\" : "/"}`) ||
    child === ".." ||
    isAbsolute(child)
  ) {
    throw new PiNodeDomainError(
      "session-load-failed",
      `The private ${label} path escaped its temporary root.`,
    );
  }
}

function assertContainedExportPath(root: string, candidate: string): void {
  const child = relative(root, candidate);
  if (
    child.length === 0 ||
    child.startsWith(`..${process.platform === "win32" ? "\\" : "/"}`) ||
    child === ".." ||
    isAbsolute(child)
  ) {
    throw new PiNodeDomainError(
      "session-export-failed",
      "The private export path escaped its temporary root.",
    );
  }
}

async function removePrivateTempDirectory(path: string): Promise<void> {
  try {
    await rm(path, { recursive: true, force: true, maxRetries: 2 });
  } catch {
    // The caller already closed every owned file handle; cleanup is best-effort on shutdown.
  }
}

function sameProtocolVersion(
  left: ProtocolVersion,
  right: Readonly<Pick<ProtocolVersion, "major" | "minor" | "patch">>,
): boolean {
  return left.major === right.major && left.minor === right.minor && left.patch === right.patch;
}
