import { randomUUID } from "node:crypto";

import { create, type MessageInitShape } from "@bufbuild/protobuf";
import {
  Capability,
  ErrorCode,
  MAX_FRAME_BYTES,
  MAX_TRANSFER_CHUNK_BYTES,
  PiTransportFrameSchema,
  SessionEventStreamEnvelopeSchema,
  decodeTransportFrame,
  encodeTransportFrame,
  type PiTransportFrame,
  type ProtocolVersion,
  type StableError,
} from "@pi-client/protocol";

import type { PiNodeSessionEvent, PiNodeSessionSnapshot } from "../pi-node-domain.js";
import {
  mapCommandFailure,
  mapDomainError,
  piNodeMessageText,
  stableError,
  toProtocolMessageSnapshot,
  toProtocolSessionDetail,
  toProtocolSessionSummary,
} from "./protobuf-domain-adapter.js";
import type { PiNodeProtocolDomain } from "./pi-node-protocol-domain-port.js";

const MAX_TRACKED_IDENTIFIERS = 65_536;

export const PI_NODE_PROTOCOL_IMPLEMENTATION_NAME = "Pi Client Node";
export const SUPPORTED_UNPUBLISHED_PROTOCOL_VERSIONS = Object.freeze([
  Object.freeze({ major: 0, minor: 1, patch: 0 }),
] as const);
export const SUPPORTED_PROTOCOL_CAPABILITIES = Object.freeze([
  Capability.SESSION_READ,
  Capability.SESSION_CREATE,
  Capability.PROMPT_COMMAND,
  Capability.ABORT_COMMAND,
  Capability.SESSION_EVENTS,
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
  readonly workingDirectory: string;
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
  readonly messageTextById: Map<string, string>;
  unsubscribe: () => void;
  lastDomainSequence: number;
  eventSequence: bigint;
  eventTail: Promise<void>;
  closed: boolean;
}

interface PendingAdmission {
  readonly events: PiNodeSessionEvent[];
}

class OutboundFrameLimitError extends Error {
  constructor() {
    super("The outbound frame exceeds the negotiated frame limit.");
    this.name = "OutboundFrameLimitError";
  }
}

export class PiNodeProtobufConnection {
  readonly #domain: PiNodeProtocolDomain;
  readonly #workingDirectory: string;
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
  readonly #sessionWorkingDirectories = new Map<string, string>();

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
    this.#workingDirectory = options.workingDirectory;
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
    await this.#releaseObservations();
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
      case "listSessionsRequest":
        await this.#handleListSessions(frame.operation.value.requestId);
        return;
      case "getSessionRequest":
        await this.#handleGetSession(
          frame.operation.value.requestId,
          frame.operation.value.sessionId,
        );
        return;
      case "createSessionRequest":
        await this.#handleCreateSession(
          frame.operation.value.requestId,
          frame.operation.value.workingDirectory,
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
      case "healthRequest":
        await this.#handleUnsupportedRequest(frame.operation.value.requestId);
        return;
      case "serverHandshakeAccepted":
      case "serverHandshakeRejected":
      case "healthResponse":
      case "listSessionsResponse":
      case "getSessionResponse":
      case "createSessionResponse":
      case "requestRejected":
      case "commandAccepted":
      case "commandRejected":
      case "sessionEventStream":
      case "eventStream":
      case "error":
        await this.#failProtocol("The client sent a server-only operation.");
        return;
      case "cancel":
      case "windowUpdate":
      case "transferOpen":
      case "transferChunk":
      case "transferAck":
      case "transferComplete":
      case "transferAbort":
        await this.#failProtocol("The client sent an operation that was not negotiated.");
        return;
      case "clientProtocolOffer":
      case undefined:
        await this.#failProtocol("The client sent an invalid operation.");
    }
  }

  async #handleListSessions(requestId: bigint): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.SESSION_READ, false))) {
      return;
    }

    try {
      const sessions = await this.#domain.listSessions({ cwd: this.#workingDirectory });
      for (const session of sessions) {
        this.#sessionWorkingDirectories.set(session.sessionId, session.cwd);
      }
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

  async #handleGetSession(requestId: bigint, sessionId: string): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.SESSION_READ, false))) {
      return;
    }

    let observationPending: PendingAdmission | undefined;
    try {
      const snapshot = await this.#domain.getSession({
        cwd: this.#sessionWorkingDirectories.get(sessionId) ?? this.#workingDirectory,
        sessionId,
      });
      this.#sessionWorkingDirectories.set(snapshot.sessionId, snapshot.cwd);
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

  async #handleCreateSession(requestId: bigint, workingDirectory: string): Promise<void> {
    if (!(await this.#claimRequest(requestId, false))) {
      return;
    }
    if (!(await this.#requireCapability(requestId, Capability.SESSION_CREATE, false))) {
      return;
    }

    let sessionId: string | undefined;
    let observationPending: PendingAdmission | undefined;
    try {
      const snapshot = await this.#domain.createSession({ cwd: workingDirectory });
      sessionId = snapshot.sessionId;
      this.#sessionWorkingDirectories.set(snapshot.sessionId, snapshot.cwd);
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
      messageTextById: new Map(
        snapshot.messages.map((message) => [message.id, piNodeMessageText(message)]),
      ),
      unsubscribe: () => {},
      lastDomainSequence: snapshot.lastEventSequence,
      eventSequence: 0n,
      eventTail: Promise.resolve(),
      closed: false,
    };
    this.#observations.set(snapshot.sessionId, entry);

    try {
      const observation = this.#domain.observeSession(snapshot.sessionId, (event) =>
        this.#acceptDomainEvent(entry, event),
      );
      entry.unsubscribe = observation.unsubscribe;
      entry.lastDomainSequence = observation.snapshot.lastEventSequence;
      entry.messageTextById.clear();
      for (const message of observation.snapshot.messages) {
        entry.messageTextById.set(message.id, piNodeMessageText(message));
      }
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
      case "message": {
        const message = toProtocolMessageSnapshot(event.message, event.phase !== "completed");
        const previous = entry.messageTextById.get(event.message.id);
        const current = message.text;
        entry.messageTextById.set(event.message.id, current);

        if (event.phase === "started" || event.phase === "completed" || previous === undefined) {
          await this.#sendSessionEvent(entry, {
            case: "messageAdded",
            value: { message },
          });
          return;
        }
        if (current === previous) {
          return;
        }
        if (!current.startsWith(previous)) {
          await this.#sendSessionEvent(entry, {
            case: "messageAdded",
            value: { message },
          });
          return;
        }
        const delta = current.slice(previous.length);
        if (delta.length > 0) {
          await this.#sendSessionEvent(entry, {
            case: "messageDelta",
            value: { messageId: event.message.id, delta },
          });
        }
      }
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

function sameProtocolVersion(
  left: ProtocolVersion,
  right: Readonly<Pick<ProtocolVersion, "major" | "minor" | "patch">>,
): boolean {
  return left.major === right.major && left.minor === right.minor && left.patch === right.patch;
}
