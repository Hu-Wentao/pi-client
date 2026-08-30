import { fromBinary, toBinary } from "@bufbuild/protobuf";
import {
  Capability,
  ErrorCode,
  HealthStatus,
  MessageRole,
  PiTransportFrameSchema,
  ProjectTrustReason,
  ProjectTrustStatus,
  SessionAdminOperation,
  TransferDirection,
  TransferPurpose,
  type DirectoryListingSnapshot,
  type MessageSnapshot,
  type PiTransportFrame,
  type ProjectSnapshot,
  type ProtocolVersion,
  type SessionDetailSnapshot,
  type SessionSummarySnapshot,
  type StableError,
  type StreamClosedEvent,
} from "../gen/ts/pi/client/protocol/v0/protocol_pb.ts";
import {
  MAX_CAPABILITIES,
  MAX_CONTENT_TEXT_BYTES,
  MAX_DIRECTORY_CHILDREN,
  MAX_ERROR_MESSAGE_BYTES,
  MAX_FRAME_BYTES,
  MAX_IDENTIFIER_BYTES,
  MAX_KNOWN_PROJECTS,
  MAX_MESSAGES_PER_SESSION_SNAPSHOT,
  MAX_PATH_BYTES,
  MAX_PROTOCOL_VERSIONS,
  MAX_SESSIONS_PER_RESPONSE,
  MAX_SHORT_TEXT_BYTES,
  MAX_TRANSFER_CHUNK_BYTES,
  SHA256_BYTES,
} from "./limits.ts";

const textEncoder = new TextEncoder();
const forbiddenIdentifierControl = /[\u0000-\u001f\u007f]/u;
const semanticVersionPattern = /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|[0-9A-Za-z-]*[A-Za-z-][0-9A-Za-z-]*)(?:\.(?:0|[1-9]\d*|[0-9A-Za-z-]*[A-Za-z-][0-9A-Za-z-]*))*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/u;

const knownCapabilities = new Set<Capability>([
  Capability.SESSION_READ,
  Capability.SESSION_CREATE,
  Capability.PROMPT_COMMAND,
  Capability.ABORT_COMMAND,
  Capability.SESSION_EVENTS,
  Capability.HEALTH,
  Capability.CANCELLATION,
  Capability.FLOW_CONTROL,
  Capability.TRANSFER,
  Capability.PROJECT_DISCOVERY,
  Capability.PROJECT_TRUST,
  Capability.SESSION_ADMIN,
]);
const knownHealthStatuses = new Set<HealthStatus>([
  HealthStatus.STARTING,
  HealthStatus.SERVING,
  HealthStatus.DEGRADED,
  HealthStatus.STOPPING,
]);
const knownProjectTrustStatuses = new Set<ProjectTrustStatus>([
  ProjectTrustStatus.NOT_REQUIRED,
  ProjectTrustStatus.TRUSTED,
  ProjectTrustStatus.APPROVAL_REQUIRED,
  ProjectTrustStatus.DENIED,
]);
const knownProjectTrustReasons = new Set<ProjectTrustReason>([
  ProjectTrustReason.PI_SETTINGS,
  ProjectTrustReason.PI_EXTENSIONS,
  ProjectTrustReason.PI_SKILLS,
  ProjectTrustReason.PI_PROMPTS,
  ProjectTrustReason.PI_THEMES,
  ProjectTrustReason.PI_SYSTEM_PROMPT,
  ProjectTrustReason.AGENT_SKILLS,
  ProjectTrustReason.SAVED_APPROVAL,
  ProjectTrustReason.SAVED_DENIAL,
]);
const knownMessageRoles = new Set<MessageRole>([
  MessageRole.USER,
  MessageRole.ASSISTANT,
  MessageRole.TOOL,
  MessageRole.SYSTEM,
]);
const knownTransferDirections = new Set<TransferDirection>([
  TransferDirection.UPLOAD,
  TransferDirection.DOWNLOAD,
]);
const knownTransferPurposes = new Set<TransferPurpose>([
  TransferPurpose.FILE,
  TransferPurpose.ATTACHMENT,
  TransferPurpose.EXPORT,
]);
const knownErrorCodes = new Set<ErrorCode>([
  ErrorCode.AUTHENTICATION_REQUIRED,
  ErrorCode.PERMISSION_DENIED,
  ErrorCode.NOT_FOUND,
  ErrorCode.INVALID_REQUEST,
  ErrorCode.CONFLICT,
  ErrorCode.NODE_BUSY,
  ErrorCode.PROTOCOL_VERSION_UNSUPPORTED,
  ErrorCode.CANCELLED,
  ErrorCode.DEADLINE_EXCEEDED,
  ErrorCode.UNAVAILABLE,
  ErrorCode.DATA_LOSS,
  ErrorCode.INTERNAL,
  ErrorCode.PROTOCOL_VIOLATION,
  ErrorCode.RESOURCE_EXHAUSTED,
  ErrorCode.ALREADY_EXISTS,
  ErrorCode.FAILED_PRECONDITION,
]);

export class FrameValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "FrameValidationError";
  }
}

export function encodeTransportFrame(frame: PiTransportFrame): Uint8Array {
  validateTransportFrame(frame);
  const bytes = toBinary(PiTransportFrameSchema, frame);
  assertFrameByteLength(bytes.length);
  return bytes;
}

export function decodeTransportFrame(bytes: Uint8Array): PiTransportFrame {
  assertFrameByteLength(bytes.length);
  const frame = fromBinary(PiTransportFrameSchema, bytes);
  validateTransportFrame(frame);
  return frame;
}

export function validateTransportFrame(frame: PiTransportFrame): void {
  validatePositiveUint64("frame_sequence", frame.frameSequence);

  const operation = frame.operation;
  switch (operation.case) {
    case "clientProtocolOffer": {
      const offer = operation.value;
      validateProtocolVersions(
        "client protocol offer",
        offer.protocolVersions,
        true,
      );
      validateCapabilities(offer.capabilities);
      validateIdentifier("client_instance_id", offer.clientInstanceId);
      validateRequiredShortText(
        "implementation_name",
        offer.implementationName,
      );
      validateSemanticVersion(
        "implementation_version",
        offer.implementationVersion,
      );
      validateAdvertisedLimits(
        offer.maxFrameBytes,
        offer.maxTransferChunkBytes,
      );
      return;
    }
    case "serverHandshakeAccepted": {
      const accepted = operation.value;
      if (accepted.selectedProtocolVersion === undefined) {
        fail("accepted handshake must contain a selected protocol version");
      }
      validateProtocolVersion(accepted.selectedProtocolVersion);
      validateCapabilities(accepted.capabilities);
      validateIdentifier("node_instance_id", accepted.nodeInstanceId);
      validateRequiredShortText(
        "implementation_name",
        accepted.implementationName,
      );
      validateSemanticVersion(
        "implementation_version",
        accepted.implementationVersion,
      );
      validateAdvertisedLimits(
        accepted.maxFrameBytes,
        accepted.maxTransferChunkBytes,
      );
      return;
    }
    case "serverHandshakeRejected": {
      const rejected = operation.value;
      requireStableError("handshake rejection", rejected.error);
      validateProtocolVersions(
        "server supported protocol versions",
        rejected.supportedProtocolVersions,
        false,
      );
      return;
    }
    case "healthRequest":
      validateRequestId(operation.value.requestId);
      return;
    case "healthResponse":
      validateRequestId(operation.value.requestId);
      validateKnownEnum(
        "health response status",
        operation.value.status,
        knownHealthStatuses,
      );
      validateSemanticVersion("node_version", operation.value.nodeVersion);
      return;
    case "getProjectBootstrapRequest":
      validateRequestId(operation.value.requestId);
      return;
    case "getProjectBootstrapResponse":
      validateRequestId(operation.value.requestId);
      validatePath("home_directory", operation.value.homeDirectory);
      requireProjectSnapshot("project bootstrap", operation.value.defaultProject);
      return;
    case "browseDirectoryRequest":
      validateRequestId(operation.value.requestId);
      validatePath("directory", operation.value.directory);
      validateBoundedUint32(
        "max_children",
        operation.value.maxChildren,
        MAX_DIRECTORY_CHILDREN,
        true,
      );
      return;
    case "browseDirectoryResponse":
      validateRequestId(operation.value.requestId);
      requireDirectoryListing("browse directory response", operation.value.directory);
      return;
    case "validateProjectRequest":
      validateRequestId(operation.value.requestId);
      validatePath("candidate_directory", operation.value.candidateDirectory);
      return;
    case "validateProjectResponse":
      validateRequestId(operation.value.requestId);
      requireProjectSnapshot("validate project response", operation.value.project);
      return;
    case "listKnownProjectsRequest":
      validateRequestId(operation.value.requestId);
      validateBoundedUint32(
        "max_projects",
        operation.value.maxProjects,
        MAX_KNOWN_PROJECTS,
        true,
      );
      return;
    case "listKnownProjectsResponse":
      validateRequestId(operation.value.requestId);
      if (operation.value.projects.length > MAX_KNOWN_PROJECTS) {
        fail("known project response exceeds the local hard limit");
      }
      for (const known of operation.value.projects) {
        requireProjectSnapshot("known project", known.project);
        validatePositiveUint64("last_session_at_unix_millis", known.lastSessionAtUnixMillis);
        validateBoundedUint32("session_count", known.sessionCount, 0xffff_ffff, false);
      }
      return;
    case "approveProjectTrustRequest":
      validateRequestId(operation.value.requestId);
      validateIdentifier("project_id", operation.value.projectId);
      validateIdentifier("trust_revision", operation.value.trustRevision);
      return;
    case "approveProjectTrustResponse":
      validateRequestId(operation.value.requestId);
      requireProjectSnapshot("project trust approval", operation.value.project);
      return;
    case "listSessionsRequest":
      validateRequestId(operation.value.requestId);
      validateIdentifier("project_id", operation.value.projectId);
      return;
    case "listSessionsResponse": {
      const response = operation.value;
      validateRequestId(response.requestId);
      if (response.sessions.length > MAX_SESSIONS_PER_RESPONSE) {
        fail("session response count exceeds the local hard limit");
      }
      const sessionIds = new Set<string>();
      for (const session of response.sessions) {
        validateSessionSummary(session);
        if (sessionIds.has(session.sessionId)) {
          fail("session response contains a duplicate session_id");
        }
        sessionIds.add(session.sessionId);
      }
      return;
    }
    case "getSessionRequest":
      validateRequestId(operation.value.requestId);
      validateIdentifier("session_id", operation.value.sessionId);
      validateIdentifier("project_id", operation.value.projectId);
      return;
    case "getSessionResponse":
      validateRequestId(operation.value.requestId);
      requireSessionDetail("get session response", operation.value.session);
      return;
    case "createSessionRequest":
      validateRequestId(operation.value.requestId);
      validateIdentifier("project_id", operation.value.projectId);
      return;
    case "createSessionResponse":
      validateRequestId(operation.value.requestId);
      requireSessionDetail("create session response", operation.value.session);
      return;
    case "promptCommand":
      validateRequestId(operation.value.requestId);
      validateIdentifier("command_id", operation.value.commandId);
      validateIdentifier("session_id", operation.value.sessionId);
      validateContentText("prompt", operation.value.prompt, true);
      return;
    case "abortCommand":
      validateRequestId(operation.value.requestId);
      validateIdentifier("command_id", operation.value.commandId);
      validateIdentifier("session_id", operation.value.sessionId);
      return;
    case "renameSessionCommand":
      validateSessionAdminCommand(operation.value);
      validateRequiredShortText("session name", operation.value.name);
      return;
    case "clearSessionNameCommand":
      validateSessionAdminCommand(operation.value);
      return;
    case "autoNameSessionCommand":
      validateSessionAdminCommand(operation.value);
      if (operation.value.timeoutMillis < 1_000 || operation.value.timeoutMillis > 30_000) {
        fail("auto-name timeout is outside the supported bounds");
      }
      return;
    case "deleteSessionCommand": {
      validateSessionAdminCommand(operation.value);
      const confirmation = operation.value.confirmation;
      if (confirmation === undefined) {
        fail("delete session command must contain confirmation evidence");
      }
      validateIdentifier("confirmation session_id", confirmation.sessionId);
      validateIdentifier("confirmation admin_revision", confirmation.adminRevision);
      validateRequiredShortText("confirmation displayed_title", confirmation.displayedTitle);
      if (
        !confirmation.destructiveActionAcknowledged ||
        confirmation.sessionId !== operation.value.sessionId
      ) {
        fail("delete confirmation evidence is incomplete");
      }
      return;
    }
    case "sessionAdminCommandOutcome": {
      const admin = operation.value;
      validateRequestId(admin.requestId);
      validateIdentifier("command_id", admin.commandId);
      if (admin.operation === SessionAdminOperation.UNSPECIFIED) {
        fail("session administration outcome must identify its operation");
      }
      switch (admin.outcome.case) {
        case "session":
          validateSessionSummary(admin.outcome.value);
          if (admin.operation === SessionAdminOperation.DELETE) {
            fail("delete outcome cannot contain an updated session");
          }
          return;
        case "deletion":
          validateIdentifier("deleted session_id", admin.outcome.value.sessionId);
          if (admin.operation !== SessionAdminOperation.DELETE) {
            fail("only delete outcomes may contain deletion evidence");
          }
          return;
        case "error":
          requireStableError("session administration outcome", admin.outcome.value);
          return;
        case undefined:
          fail("session administration outcome must contain a typed result");
      }
    }
    case "requestRejected":
      validateRequestId(operation.value.requestId);
      requireStableError("request rejection", operation.value.error);
      return;
    case "commandAccepted":
      validateRequestId(operation.value.requestId);
      validateIdentifier("command_id", operation.value.commandId);
      return;
    case "commandRejected":
      validateRequestId(operation.value.requestId);
      validateIdentifier("command_id", operation.value.commandId);
      requireStableError("command rejection", operation.value.error);
      return;
    case "sessionEventStream": {
      const stream = operation.value;
      validateIdentifier("stream_id", stream.streamId);
      validateIdentifier("session_id", stream.sessionId);
      validatePositiveUint64("event_sequence", stream.eventSequence);
      switch (stream.event.case) {
        case "messageAdded":
          if (stream.event.value.message === undefined) {
            fail("message added event must contain a message snapshot");
          }
          validateMessageSnapshot(stream.event.value.message);
          return;
        case "messageDelta":
          validateIdentifier("message_id", stream.event.value.messageId);
          validateContentText("message delta", stream.event.value.delta, true);
          return;
        case "runningChanged":
          return;
        case "commandCompleted":
          validateIdentifier("command_id", stream.event.value.commandId);
          validateCompletionError(
            stream.event.value.succeeded,
            stream.event.value.error,
          );
          return;
        case "streamClosed":
          validateStreamClosed(stream.event.value);
          return;
        case undefined:
          fail("session event stream must contain a typed event");
      }
      return;
    }
    case "eventStream": {
      const stream = operation.value;
      validateIdentifier("stream_id", stream.streamId);
      validatePositiveUint64("event_sequence", stream.eventSequence);
      switch (stream.event.case) {
        case "heartbeat":
          validatePositiveUint64(
            "observed_unix_millis",
            stream.event.value.observedUnixMillis,
          );
          return;
        case "healthStatusChanged":
          validateKnownEnum(
            "health status event",
            stream.event.value.status,
            knownHealthStatuses,
          );
          validateShortText("health summary", stream.event.value.summary, false);
          return;
        case "streamClosed":
          validateStreamClosed(stream.event.value);
          return;
        case undefined:
          fail("event stream envelope must contain a typed event");
      }
      return;
    }
    case "cancel": {
      const target = operation.value.target;
      switch (target.case) {
        case "requestId":
          validateRequestId(target.value);
          break;
        case "streamId":
        case "transferId":
          validateIdentifier(target.case, target.value);
          break;
        case undefined:
          fail("cancel must contain a target identifier");
      }
      validateShortText("cancel reason", operation.value.reason, false);
      return;
    }
    case "windowUpdate": {
      const target = operation.value.target;
      if (target.case === undefined) {
        fail("window update must contain a target identifier");
      }
      validateIdentifier(target.case, target.value);
      if (
        operation.value.creditMessages === 0 &&
        operation.value.creditBytes === 0n
      ) {
        fail("window update must grant message or byte credit");
      }
      return;
    }
    case "transferOpen": {
      const transfer = operation.value;
      validateIdentifier("transfer_id", transfer.transferId);
      validateKnownEnum(
        "transfer direction",
        transfer.direction,
        knownTransferDirections,
      );
      validateKnownEnum(
        "transfer purpose",
        transfer.purpose,
        knownTransferPurposes,
      );
      validateShortText("content_type", transfer.contentType, false);
      validateShortText("file_name", transfer.fileName, false);
      if (
        transfer.chunkBytes <= 0 ||
        transfer.chunkBytes > MAX_TRANSFER_CHUNK_BYTES
      ) {
        fail("transfer chunk_bytes is outside the local hard limit");
      }
      validateDigest(transfer.sha256);
      return;
    }
    case "transferChunk":
      validateIdentifier("transfer_id", operation.value.transferId);
      validatePositiveUint64(
        "chunk_sequence",
        operation.value.chunkSequence,
      );
      if (
        operation.value.data.length === 0 ||
        operation.value.data.length > MAX_TRANSFER_CHUNK_BYTES
      ) {
        fail("transfer chunk data is outside the local hard limit");
      }
      return;
    case "transferAck":
      validateIdentifier("transfer_id", operation.value.transferId);
      validatePositiveUint64(
        "acknowledged_sequence",
        operation.value.acknowledgedSequence,
      );
      return;
    case "transferComplete":
      validateIdentifier("transfer_id", operation.value.transferId);
      validateDigest(operation.value.sha256);
      return;
    case "transferAbort":
      validateIdentifier("transfer_id", operation.value.transferId);
      requireStableError("transfer abort", operation.value.error);
      return;
    case "error": {
      const envelope = operation.value;
      switch (envelope.correlation.case) {
        case "requestId":
          validateRequestId(envelope.correlation.value);
          break;
        case "streamId":
        case "transferId":
          validateIdentifier(
            envelope.correlation.case,
            envelope.correlation.value,
          );
          break;
        case undefined:
          break;
      }
      requireStableError("error envelope", envelope.error);
      return;
    }
    case undefined:
      fail("transport frame must contain a typed operation");
  }
}

function validateAdvertisedLimits(
  maxFrameBytes: number,
  maxTransferChunkBytes: number,
): void {
  if (maxFrameBytes <= 0 || maxFrameBytes > MAX_FRAME_BYTES) {
    fail("advertised max_frame_bytes is outside the local hard limit");
  }
  if (
    maxTransferChunkBytes <= 0 ||
    maxTransferChunkBytes > MAX_TRANSFER_CHUNK_BYTES
  ) {
    fail("advertised max_transfer_chunk_bytes is outside the local hard limit");
  }
}

function validateProtocolVersions(
  label: string,
  versions: ProtocolVersion[],
  required: boolean,
): void {
  if (required && versions.length === 0) {
    fail(`${label} must contain at least one protocol version`);
  }
  if (versions.length > MAX_PROTOCOL_VERSIONS) {
    fail(`${label} exceeds the local protocol version limit`);
  }
  const seen = new Set<string>();
  for (const version of versions) {
    validateProtocolVersion(version);
    const key = `${version.major}.${version.minor}.${version.patch}`;
    if (seen.has(key)) {
      fail(`${label} contains a duplicate protocol version`);
    }
    seen.add(key);
  }
}

function validateProtocolVersion(version: ProtocolVersion): void {
  if (version.major !== 0) {
    fail("v0 protocol versions must use major zero");
  }
}

function validateCapabilities(capabilities: Capability[]): void {
  if (capabilities.length > MAX_CAPABILITIES) {
    fail("capability count exceeds the local hard limit");
  }
  const seen = new Set<Capability>();
  for (const capability of capabilities) {
    validateKnownEnum("capability", capability, knownCapabilities);
    if (seen.has(capability)) {
      fail("capability list contains a duplicate");
    }
    seen.add(capability);
  }
}

function requireDirectoryListing(
  label: string,
  listing: DirectoryListingSnapshot | undefined,
): void {
  if (listing === undefined) {
    fail(`${label} must contain a directory listing`);
  }
  validatePath("canonical_directory", listing.canonicalDirectory);
  if (listing.parentDirectory.length > 0) {
    validatePath("parent_directory", listing.parentDirectory);
  }
  if (listing.children.length > MAX_DIRECTORY_CHILDREN) {
    fail("directory child count exceeds the local hard limit");
  }
  const names = new Set<string>();
  for (const child of listing.children) {
    validateRequiredShortText("directory child name", child.name);
    validatePath("directory child canonical_path", child.canonicalPath);
    if (names.has(child.name)) {
      fail("directory listing contains a duplicate child name");
    }
    names.add(child.name);
  }
}

function requireProjectSnapshot(label: string, project: ProjectSnapshot | undefined): void {
  if (project === undefined || project.identity === undefined || project.trust === undefined) {
    fail(`${label} must contain project identity and trust snapshots`);
  }
  const identity = project.identity;
  validateIdentifier("project_id", identity.projectId);
  validatePath("canonical_working_directory", identity.canonicalWorkingDirectory);
  validateIdentifier("worktree_id", identity.worktreeId);
  validateIdentifier("main_project_id", identity.mainProjectId);
  if (identity.isGitRepository) {
    validatePath("git_root", identity.gitRoot);
    validatePath("main_worktree_root", identity.mainWorktreeRoot);
    validateShortText("branch", identity.branch, false);
    if (identity.isDetachedHead && identity.branch.length > 0) {
      fail("a detached project identity must not contain a branch");
    }
  } else if (
    identity.gitRoot.length > 0 ||
    identity.mainWorktreeRoot.length > 0 ||
    identity.branch.length > 0 ||
    identity.isLinkedWorktree ||
    identity.isDetachedHead
  ) {
    fail("a non-Git project identity contains Git-only fields");
  }

  const trust = project.trust;
  validateKnownEnum("project trust status", trust.status, knownProjectTrustStatuses);
  validateIdentifier("project trust revision", trust.revision);
  const reasons = new Set<ProjectTrustReason>();
  for (const reason of trust.reasons) {
    validateKnownEnum("project trust reason", reason, knownProjectTrustReasons);
    if (reasons.has(reason)) {
      fail("project trust reasons contain a duplicate");
    }
    reasons.add(reason);
  }
  if (trust.status === ProjectTrustStatus.NOT_REQUIRED && trust.reasons.length > 0) {
    fail("a not-required project trust snapshot must not contain reasons");
  }
  if (trust.status !== ProjectTrustStatus.NOT_REQUIRED && trust.reasons.length === 0) {
    fail("a restricted or trusted project must contain a trust reason");
  }
}

function requireSessionDetail(
  label: string,
  detail: SessionDetailSnapshot | undefined,
): void {
  if (detail === undefined) {
    fail(`${label} must contain a session detail snapshot`);
  }
  validateSessionDetail(detail);
}

function validateSessionDetail(detail: SessionDetailSnapshot): void {
  if (detail.summary === undefined) {
    fail("session detail must contain a summary snapshot");
  }
  validateSessionSummary(detail.summary);
  if (detail.messages.length > MAX_MESSAGES_PER_SESSION_SNAPSHOT) {
    fail("session message count exceeds the local hard limit");
  }
  const messageIds = new Set<string>();
  for (const message of detail.messages) {
    validateMessageSnapshot(message);
    if (messageIds.has(message.messageId)) {
      fail("session detail contains a duplicate message_id");
    }
    messageIds.add(message.messageId);
  }
}

function validateSessionAdminCommand(command: {
  readonly requestId: bigint;
  readonly commandId: string;
  readonly projectId: string;
  readonly sessionId: string;
}): void {
  validateRequestId(command.requestId);
  validateIdentifier("command_id", command.commandId);
  validateIdentifier("project_id", command.projectId);
  validateIdentifier("session_id", command.sessionId);
}

function validateSessionSummary(summary: SessionSummarySnapshot): void {
  validateIdentifier("session_id", summary.sessionId);
  validateIdentifier("admin_revision", summary.adminRevision);
  validateRequiredShortText("session title", summary.title);
  validatePath("working_directory", summary.workingDirectory);
  validatePositiveUint64(
    "created_at_unix_millis",
    summary.createdAtUnixMillis,
  );
  validatePositiveUint64(
    "updated_at_unix_millis",
    summary.updatedAtUnixMillis,
  );
  if (summary.updatedAtUnixMillis < summary.createdAtUnixMillis) {
    fail("session updated time must not precede its created time");
  }
}

function validateMessageSnapshot(message: MessageSnapshot): void {
  validateIdentifier("message_id", message.messageId);
  validateKnownEnum("message role", message.role, knownMessageRoles);
  validateContentText("message text", message.text, false);
  validatePositiveUint64(
    "created_at_unix_millis",
    message.createdAtUnixMillis,
  );
}

function validateCompletionError(
  succeeded: boolean,
  error: StableError | undefined,
): void {
  if (succeeded) {
    if (error !== undefined) {
      fail("successful command completion must not contain an error");
    }
    return;
  }
  requireStableError("failed command completion", error);
}

function validateStreamClosed(event: StreamClosedEvent): void {
  if (event.graceful) {
    if (event.error !== undefined) {
      fail("graceful stream close must not contain an error");
    }
    return;
  }
  requireStableError("ungraceful stream close", event.error);
}

function requireStableError(
  label: string,
  error: StableError | undefined,
): void {
  if (error === undefined) {
    fail(`${label} must contain a stable error`);
  }
  validateStableError(error);
}

function validateStableError(error: StableError): void {
  validateKnownEnum("stable error code", error.code, knownErrorCodes);
  validateTextBytes(
    "stable error safe_message",
    error.safeMessage,
    MAX_ERROR_MESSAGE_BYTES,
    false,
  );
  if (error.retryAfterMillis > 0 && !error.retryable) {
    fail("retry_after_millis requires retryable=true");
  }
}

function validateDigest(digest: Uint8Array): void {
  if (digest.length !== 0 && digest.length !== SHA256_BYTES) {
    fail("sha256 must be empty or exactly 32 bytes");
  }
}

function validateBoundedUint32(
  label: string,
  value: number,
  maximum: number,
  allowZero: boolean,
): void {
  if (!Number.isSafeInteger(value) || value < (allowZero ? 0 : 1) || value > maximum) {
    fail(`${label} is outside the local uint32 limit`);
  }
}

function validateRequestId(value: bigint): void {
  validatePositiveUint64("request_id", value);
}

function validatePositiveUint64(label: string, value: bigint): void {
  if (value <= 0n) {
    fail(`${label} must be a positive uint64`);
  }
}

function validateIdentifier(label: string, value: string): void {
  const bytes = textEncoder.encode(value).length;
  if (
    bytes === 0 ||
    bytes > MAX_IDENTIFIER_BYTES ||
    value.trim() !== value ||
    forbiddenIdentifierControl.test(value)
  ) {
    fail(`${label} is outside the local identifier limit`);
  }
}

function validatePath(label: string, value: string): void {
  const bytes = textEncoder.encode(value).length;
  if (
    bytes === 0 ||
    bytes > MAX_PATH_BYTES ||
    value.trim() !== value ||
    forbiddenIdentifierControl.test(value)
  ) {
    fail(`${label} is outside the local path limit`);
  }
}

function validateRequiredShortText(label: string, value: string): void {
  validateShortText(label, value, true);
}

function validateShortText(
  label: string,
  value: string,
  required: boolean,
): void {
  validateTextBytes(label, value, MAX_SHORT_TEXT_BYTES, required);
}

function validateContentText(
  label: string,
  value: string,
  required: boolean,
): void {
  validateTextBytes(label, value, MAX_CONTENT_TEXT_BYTES, required);
}

function validateTextBytes(
  label: string,
  value: string,
  maxBytes: number,
  required: boolean,
): void {
  const bytes = textEncoder.encode(value).length;
  if (
    (required && value.trim().length === 0) ||
    bytes > maxBytes ||
    value.includes("\u0000")
  ) {
    fail(`${label} is outside the local text limit`);
  }
}

function validateSemanticVersion(label: string, value: string): void {
  validateRequiredShortText(label, value);
  if (!semanticVersionPattern.test(value)) {
    fail(`${label} must be a SemVer 2.0.0 version`);
  }
}

function validateKnownEnum<T extends number>(
  label: string,
  value: T,
  known: ReadonlySet<T>,
): void {
  if (!known.has(value)) {
    fail(`${label} must contain a known non-zero enum value`);
  }
}

function assertFrameByteLength(length: number): void {
  if (length <= 0) {
    fail("transport frame must contain at least one byte");
  }
  if (length > MAX_FRAME_BYTES) {
    fail(`transport frame exceeds ${MAX_FRAME_BYTES} bytes`);
  }
}

function fail(message: string): never {
  throw new FrameValidationError(message);
}
