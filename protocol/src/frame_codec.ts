import { fromBinary, toBinary } from "@bufbuild/protobuf";
import {
  Capability,
  ConversationIdentityScope,
  ErrorCode,
  HealthStatus,
  MarkerKind,
  MessageRole,
  PiTransportFrameSchema,
  ProjectTrustReason,
  ProjectTrustStatus,
  SessionAdminOperation,
  SessionExportFormat,
  SessionTreeEntryKind,
  SessionTreeMutationOperation,
  SafeValueKind,
  ThinkingVisibility,
  ToolActivityStatus,
  TransferDirection,
  TransferPurpose,
  type ConversationEntry,
  type ConversationMetrics,
  type ConversationPage,
  type ConversationPart,
  type ConversationSnapshot,
  type DirectoryListingSnapshot,
  type MessageContentBinding,
  type MessageContentReference,
  type MessageSnapshot,
  type PiTransportFrame,
  type ProjectSnapshot,
  type ProtocolVersion,
  type SessionDetailSnapshot,
  type SafeValue,
  type SessionSummarySnapshot,
  type SessionTreeSnapshot,
  type StableError,
  type ToolActivity,
  type StreamClosedEvent,
} from "../gen/ts/pi/client/protocol/v0/protocol_pb.ts";
import {
  MAX_CAPABILITIES,
  MAX_CONTENT_TEXT_BYTES,
  MAX_DIRECTORY_CHILDREN,
  MAX_ERROR_MESSAGE_BYTES,
  MAX_CONVERSATION_PARTS,
  MAX_FRAME_BYTES,
  MAX_IDENTIFIER_BYTES,
  MAX_INLINE_CONVERSATION_TEXT_BYTES,
  MAX_KNOWN_PROJECTS,
  MAX_MESSAGE_CONTENT_BYTES,
  MAX_MESSAGES_PER_SESSION_SNAPSHOT,
  MAX_PATH_BYTES,
  MAX_SESSION_HISTORY_PAGE_MESSAGES,
  MAX_PROTOCOL_VERSIONS,
  MAX_SAFE_VALUE_BYTES,
  MAX_SAFE_VALUE_DEPTH,
  MAX_SAFE_VALUE_ITEMS,
  MAX_SESSIONS_PER_RESPONSE,
  MAX_SHORT_TEXT_BYTES,
  MAX_TOOL_ACTIVITIES,
  MAX_TRANSFER_CHUNK_BYTES,
  MAX_TRANSFER_CREDIT_BYTES,
  SHA256_BYTES,
} from "./limits.ts";

const textEncoder = new TextEncoder();
const forbiddenIdentifierControl = /[\u0000-\u001f\u007f]/u;
const semanticVersionPattern =
  /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|[0-9A-Za-z-]*[A-Za-z-][0-9A-Za-z-]*)(?:\.(?:0|[1-9]\d*|[0-9A-Za-z-]*[A-Za-z-][0-9A-Za-z-]*))*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/u;

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
  Capability.SESSION_TREE,
  Capability.SESSION_HISTORY,
  Capability.SESSION_STATS,
  Capability.SESSION_EXPORT,
  Capability.RICH_CONVERSATION,
  Capability.MESSAGE_CONTENT,
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
const knownSessionTreeEntryKinds = new Set<SessionTreeEntryKind>([
  SessionTreeEntryKind.USER_MESSAGE,
  SessionTreeEntryKind.ASSISTANT_MESSAGE,
  SessionTreeEntryKind.TOOL_MESSAGE,
  SessionTreeEntryKind.CUSTOM_MESSAGE,
  SessionTreeEntryKind.THINKING_LEVEL,
  SessionTreeEntryKind.MODEL_CHANGE,
  SessionTreeEntryKind.COMPACTION,
  SessionTreeEntryKind.BRANCH_SUMMARY,
  SessionTreeEntryKind.CUSTOM,
  SessionTreeEntryKind.LABEL,
  SessionTreeEntryKind.SESSION_INFO,
]);
const knownSessionTreeMutationOperations =
  new Set<SessionTreeMutationOperation>([
    SessionTreeMutationOperation.NAVIGATE,
    SessionTreeMutationOperation.FORK,
    SessionTreeMutationOperation.CLONE,
  ]);
const knownSessionExportFormats = new Set<SessionExportFormat>([
  SessionExportFormat.HTML,
  SessionExportFormat.JSONL,
]);
const knownTransferDirections = new Set<TransferDirection>([
  TransferDirection.UPLOAD,
  TransferDirection.DOWNLOAD,
]);
const knownTransferPurposes = new Set<TransferPurpose>([
  TransferPurpose.FILE,
  TransferPurpose.ATTACHMENT,
  TransferPurpose.EXPORT,
  TransferPurpose.MESSAGE_CONTENT,
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
      requireProjectSnapshot(
        "project bootstrap",
        operation.value.defaultProject,
      );
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
      requireDirectoryListing(
        "browse directory response",
        operation.value.directory,
      );
      return;
    case "validateProjectRequest":
      validateRequestId(operation.value.requestId);
      validatePath("candidate_directory", operation.value.candidateDirectory);
      return;
    case "validateProjectResponse":
      validateRequestId(operation.value.requestId);
      requireProjectSnapshot(
        "validate project response",
        operation.value.project,
      );
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
        validatePositiveUint64(
          "last_session_at_unix_millis",
          known.lastSessionAtUnixMillis,
        );
        validateBoundedUint32(
          "session_count",
          known.sessionCount,
          0xffff_ffff,
          false,
        );
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
    case "getSessionTreeRequest":
      validateRequestId(operation.value.requestId);
      validateIdentifier("project_id", operation.value.projectId);
      validateIdentifier("session_id", operation.value.sessionId);
      return;
    case "getSessionTreeResponse":
      validateRequestId(operation.value.requestId);
      requireSessionTree("get session tree response", operation.value.tree);
      return;
    case "navigateSessionTreeCommand":
      validateSessionTreeMutationCommand(operation.value);
      validateIdentifier("entry_id", operation.value.entryId);
      return;
    case "forkSessionCommand":
      validateSessionTreeMutationCommand(operation.value);
      validateIdentifier("user_entry_id", operation.value.userEntryId);
      return;
    case "cloneSessionCommand":
      validateSessionTreeMutationCommand(operation.value);
      return;
    case "sessionTreeMutationOutcome": {
      const mutation = operation.value;
      validateRequestId(mutation.requestId);
      validateIdentifier("command_id", mutation.commandId);
      validateKnownEnum(
        "session tree mutation operation",
        mutation.operation,
        knownSessionTreeMutationOperations,
      );
      switch (mutation.outcome.case) {
        case "result": {
          const result = mutation.outcome.value;
          requireSessionDetail("session tree mutation result", result.session);
          requireSessionTree("session tree mutation result", result.tree);
          if (result.session?.summary?.sessionId !== result.tree?.sessionId) {
            fail("session tree mutation result identities must match");
          }
          validateContentText(
            "session tree editor text",
            result.editorText,
            false,
          );
          return;
        }
        case "error":
          requireStableError(
            "session tree mutation outcome",
            mutation.outcome.value,
          );
          return;
        case undefined:
          fail("session tree mutation outcome must contain a typed result");
      }
    }
    case "getSessionHistoryRequest": {
      const request = operation.value;
      validateRequestId(request.requestId);
      validateIdentifier("project_id", request.projectId);
      validateIdentifier("session_id", request.sessionId);
      validateShortText("history cursor", request.cursor, false);
      validateBoundedUint32(
        "history limit",
        request.limit,
        MAX_SESSION_HISTORY_PAGE_MESSAGES,
        true,
      );
      validateOptionalIdentifier(
        "expected_active_branch_revision",
        request.expectedActiveBranchRevision,
      );
      validateOptionalIdentifier(
        "expected_tree_revision",
        request.expectedTreeRevision,
      );
      return;
    }
    case "getSessionHistoryResponse": {
      const response = operation.value;
      validateRequestId(response.requestId);
      if (response.summary === undefined || response.conversation === undefined) {
        fail("session history response must contain a summary and conversation page");
      }
      validateSessionSummary(response.summary);
      validateConversationPage(response.conversation);
      if (response.conversation.sessionId !== response.summary.sessionId) {
        fail("session history conversation must match its summary session_id");
      }
      return;
    }
    case "getSessionStatsRequest":
      validateRequestId(operation.value.requestId);
      validateIdentifier("project_id", operation.value.projectId);
      validateIdentifier("session_id", operation.value.sessionId);
      return;
    case "getSessionStatsResponse": {
      const response = operation.value;
      validateRequestId(response.requestId);
      const stats = response.stats;
      if (stats === undefined || stats.projection === undefined) {
        fail("session stats response must contain stats and a safe projection");
      }
      const projection = stats.projection;
      validateRequiredShortText(
        "session_file_name",
        projection.sessionFileName,
      );
      validateIdentifier("session_id", projection.sessionId);
      validateIdentifier("project_id", projection.projectId);
      validatePath(
        "canonical_project_directory",
        projection.canonicalProjectDirectory,
      );
      validateIdentifier("worktree_id", projection.worktreeId);
      validateIdentifier("main_project_id", projection.mainProjectId);
      validateShortText("branch", projection.branch, false);
      if (projection.isDetachedHead && projection.branch.length > 0) {
        fail("a detached stats projection must not contain a branch");
      }
      validateNonNegativeUint64("user_messages", stats.userMessages);
      validateNonNegativeUint64("assistant_messages", stats.assistantMessages);
      validateNonNegativeUint64("tool_calls", stats.toolCalls);
      validateNonNegativeUint64("tool_results", stats.toolResults);
      validateNonNegativeUint64("total_messages", stats.totalMessages);
      validateNonNegativeUint64("input_tokens", stats.inputTokens);
      validateNonNegativeUint64("output_tokens", stats.outputTokens);
      validateNonNegativeUint64("cache_read_tokens", stats.cacheReadTokens);
      validateNonNegativeUint64("cache_write_tokens", stats.cacheWriteTokens);
      validateNonNegativeUint64("total_tokens", stats.totalTokens);
      validateNonNegativeNumber("cost", stats.cost);
      validateNonNegativeUint64("active_time_millis", stats.activeTimeMillis);
      if (stats.hasContextUsage) {
        validatePositiveUint64("context_window", stats.contextWindow);
        if (stats.contextTokensKnown) {
          validateNonNegativeUint64("context_tokens", stats.contextTokens);
          validateNonNegativeNumber("context_percent", stats.contextPercent);
        } else if (stats.contextTokens !== 0n || stats.contextPercent !== 0) {
          fail("unknown context tokens must not contain usage values");
        }
      } else if (
        stats.contextTokensKnown ||
        stats.contextTokens !== 0n ||
        stats.contextWindow !== 0n ||
        stats.contextPercent !== 0
      ) {
        fail("unknown context usage must not contain context values");
      }
      return;
    }
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
      if (
        operation.value.timeoutMillis < 1_000 ||
        operation.value.timeoutMillis > 30_000
      ) {
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
      validateIdentifier(
        "confirmation admin_revision",
        confirmation.adminRevision,
      );
      validateRequiredShortText(
        "confirmation displayed_title",
        confirmation.displayedTitle,
      );
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
          validateIdentifier(
            "deleted session_id",
            admin.outcome.value.sessionId,
          );
          if (admin.operation !== SessionAdminOperation.DELETE) {
            fail("only delete outcomes may contain deletion evidence");
          }
          return;
        case "error":
          requireStableError(
            "session administration outcome",
            admin.outcome.value,
          );
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
        case "entryUpsert":
          if (stream.event.value.entry === undefined) {
            fail("entry upsert event must contain an entry");
          }
          validateConversationEntry(stream.event.value.entry);
          if (stream.event.value.expectedPreviousRevision !== undefined) {
            validatePositiveUint64(
              "expected_previous_revision",
              stream.event.value.expectedPreviousRevision,
            );
          }
          return;
        case "partDelta": {
          const delta = stream.event.value;
          validateIdentifier("entry_id", delta.entryId);
          validateIdentifier("part_id", delta.partId);
          validateRevisionTransition(
            delta.expectedEntryRevision,
            delta.resultingEntryRevision,
            "entry",
          );
          validateRevisionTransition(
            delta.expectedPartRevision,
            delta.resultingPartRevision,
            "part",
          );
          validateInlineConversationText("part delta", delta.textDelta, true);
          return;
        }
        case "entryFinalized":
          if (stream.event.value.entry === undefined || !stream.event.value.entry.finalized) {
            fail("entry finalized event must contain a finalized entry");
          }
          validateConversationEntry(stream.event.value.entry);
          validatePositiveUint64(
            "expected_previous_revision",
            stream.event.value.expectedPreviousRevision,
          );
          return;
        case "toolActivity":
          validateIdentifier("entry_id", stream.event.value.entryId);
          validateRevisionTransition(
            stream.event.value.expectedEntryRevision,
            stream.event.value.resultingEntryRevision,
            "entry",
          );
          if (stream.event.value.activity === undefined) {
            fail("tool activity event must contain an activity");
          }
          validateToolActivity(stream.event.value.activity);
          return;
        case "metrics":
          validateIdentifier("entry_id", stream.event.value.entryId);
          validateRevisionTransition(
            stream.event.value.expectedEntryRevision,
            stream.event.value.resultingEntryRevision,
            "entry",
          );
          if (stream.event.value.metrics === undefined) {
            fail("metrics event must contain metrics");
          }
          validateConversationMetrics(stream.event.value.metrics);
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
          validateShortText(
            "health summary",
            stream.event.value.summary,
            false,
          );
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
      if (operation.value.creditBytes > BigInt(MAX_TRANSFER_CREDIT_BYTES)) {
        fail("window update byte credit exceeds the local hard limit");
      }
      return;
    }
    case "exportSessionRequest": {
      const request = operation.value;
      validateRequestId(request.requestId);
      validateIdentifier("project_id", request.projectId);
      validateIdentifier("session_id", request.sessionId);
      validateKnownEnum(
        "session export format",
        request.format,
        knownSessionExportFormats,
      );
      validateOptionalIdentifier(
        "expected_active_branch_revision",
        request.expectedActiveBranchRevision,
      );
      validateOptionalIdentifier(
        "expected_tree_revision",
        request.expectedTreeRevision,
      );
      return;
    }
    case "getMessageContentRequest": {
      const request = operation.value;
      validateRequestId(request.requestId);
      validateIdentifier("project_id", request.projectId);
      if (request.binding === undefined) {
        fail("message content request must contain a binding");
      }
      validateMessageContentBinding(request.binding);
      validateRequiredShortText("expected_mime_type", request.expectedMimeType);
      validatePositiveUint64("expected_total_bytes", request.expectedTotalBytes);
      if (request.expectedTotalBytes > BigInt(MAX_MESSAGE_CONTENT_BYTES)) {
        fail("message content request exceeds the local hard limit");
      }
      validateRequiredDigest(request.expectedSha256);
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
      validateRequestId(transfer.requestId);
      validateRequiredShortText("content_type", transfer.contentType);
      validateRequiredShortText("file_name", transfer.fileName);
      validatePositiveUint64("total_bytes", transfer.totalBytes);
      if (
        transfer.chunkBytes <= 0 ||
        transfer.chunkBytes > MAX_TRANSFER_CHUNK_BYTES
      ) {
        fail("transfer chunk_bytes is outside the local hard limit");
      }
      validateRequiredDigest(transfer.sha256);
      if (transfer.purpose === TransferPurpose.MESSAGE_CONTENT) {
        if (
          transfer.direction !== TransferDirection.DOWNLOAD ||
          transfer.messageContentBinding === undefined
        ) {
          fail("message content transfers must be bound downloads");
        }
        if (transfer.totalBytes > BigInt(MAX_MESSAGE_CONTENT_BYTES)) {
          fail("message content transfer exceeds the local hard limit");
        }
        validateMessageContentBinding(transfer.messageContentBinding);
      } else if (transfer.messageContentBinding !== undefined) {
        fail("only message content transfers may contain a message binding");
      }
      return;
    }
    case "transferChunk":
      validateIdentifier("transfer_id", operation.value.transferId);
      validatePositiveUint64("chunk_sequence", operation.value.chunkSequence);
      validateNonNegativeUint64("offset", operation.value.offset);
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
      validatePositiveUint64("committed_bytes", operation.value.committedBytes);
      return;
    case "transferComplete":
      validateIdentifier("transfer_id", operation.value.transferId);
      validatePositiveUint64("total_bytes", operation.value.totalBytes);
      validateRequiredDigest(operation.value.sha256);
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

function requireProjectSnapshot(
  label: string,
  project: ProjectSnapshot | undefined,
): void {
  if (
    project === undefined ||
    project.identity === undefined ||
    project.trust === undefined
  ) {
    fail(`${label} must contain project identity and trust snapshots`);
  }
  const identity = project.identity;
  validateIdentifier("project_id", identity.projectId);
  validatePath(
    "canonical_working_directory",
    identity.canonicalWorkingDirectory,
  );
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
  validateKnownEnum(
    "project trust status",
    trust.status,
    knownProjectTrustStatuses,
  );
  validateIdentifier("project trust revision", trust.revision);
  const reasons = new Set<ProjectTrustReason>();
  for (const reason of trust.reasons) {
    validateKnownEnum("project trust reason", reason, knownProjectTrustReasons);
    if (reasons.has(reason)) {
      fail("project trust reasons contain a duplicate");
    }
    reasons.add(reason);
  }
  if (
    trust.status === ProjectTrustStatus.NOT_REQUIRED &&
    trust.reasons.length > 0
  ) {
    fail("a not-required project trust snapshot must not contain reasons");
  }
  if (
    trust.status !== ProjectTrustStatus.NOT_REQUIRED &&
    trust.reasons.length === 0
  ) {
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
  if (detail.summary === undefined || detail.conversation === undefined) {
    fail("session detail must contain a summary and conversation snapshot");
  }
  validateSessionSummary(detail.summary);
  validateConversationSnapshot(detail.conversation);
  if (detail.conversation.sessionId !== detail.summary.sessionId) {
    fail("session detail conversation must match its summary session_id");
  }
}

function validateConversationSnapshot(snapshot: ConversationSnapshot): void {
  validateIdentifier("conversation session_id", snapshot.sessionId);
  if (snapshot.entries.length > MAX_MESSAGES_PER_SESSION_SNAPSHOT) {
    fail("conversation entry count exceeds the local hard limit");
  }
  validateConversationEntries(snapshot.entries);
  validateNonNegativeUint64("last_event_sequence", snapshot.lastEventSequence);
}

function validateConversationPage(page: ConversationPage): void {
  validateIdentifier("conversation page session_id", page.sessionId);
  if (page.entries.length > MAX_SESSION_HISTORY_PAGE_MESSAGES) {
    fail("conversation page exceeds the local hard limit");
  }
  validateConversationEntries(page.entries);
  validateShortText("next_cursor", page.nextCursor, false);
  if (page.hasMore !== (page.nextCursor.length > 0)) {
    fail("conversation page cursor and has_more must agree");
  }
  validateIdentifier("active_branch_revision", page.activeBranchRevision);
  validateIdentifier("tree_revision", page.treeRevision);
  validateNonNegativeUint64("last_event_sequence", page.lastEventSequence);
}

function validateConversationEntries(entries: readonly ConversationEntry[]): void {
  const entryIds = new Set<string>();
  for (const entry of entries) {
    validateConversationEntry(entry);
    const entryId = entry.identity!.entryId;
    if (entryIds.has(entryId)) fail("conversation contains a duplicate entry_id");
    entryIds.add(entryId);
  }
}

function validateConversationEntry(entry: ConversationEntry): void {
  const identity = entry.identity;
  if (identity === undefined) fail("conversation entry must contain an identity");
  validateIdentifier("entry_id", identity.entryId);
  if (
    identity.scope !== ConversationIdentityScope.PERSISTENT &&
    identity.scope !== ConversationIdentityScope.RUNTIME
  ) {
    fail("conversation entry identity scope is unknown");
  }
  validateOptionalIdentifier("origin_command_id", identity.originCommandId);
  validatePositiveUint64("entry revision", entry.revision);
  validatePositiveUint64("entry created_at_unix_millis", entry.createdAtUnixMillis);
  if (entry.parts.length > MAX_CONVERSATION_PARTS) {
    fail("conversation entry part count exceeds the local hard limit");
  }
  if (entry.toolActivities.length > MAX_TOOL_ACTIVITIES) {
    fail("conversation tool activity count exceeds the local hard limit");
  }
  const partIds = new Set<string>();
  for (const part of entry.parts) {
    validateConversationPart(part);
    if (partIds.has(part.partId)) fail("conversation entry contains a duplicate part_id");
    partIds.add(part.partId);
  }
  const activityIds = new Set<string>();
  const toolCallIds = new Set<string>();
  let priorOrdinal = -1;
  for (const activity of entry.toolActivities) {
    validateToolActivity(activity);
    if (activityIds.has(activity.activityId) || toolCallIds.has(activity.toolCallId)) {
      fail("conversation entry contains a duplicate tool activity identity");
    }
    if (activity.sourceOrdinal < priorOrdinal) {
      fail("conversation tool activities must preserve source ordinal order");
    }
    priorOrdinal = activity.sourceOrdinal;
    activityIds.add(activity.activityId);
    toolCallIds.add(activity.toolCallId);
  }
  if (entry.metrics !== undefined) validateConversationMetrics(entry.metrics);

  switch (entry.kind.case) {
    case "user":
      break;
    case "assistant":
      validateRequiredShortText("assistant provider", entry.kind.value.provider);
      validateRequiredShortText("assistant model", entry.kind.value.model);
      validateRequiredShortText("assistant stop_reason", entry.kind.value.stopReason);
      validateShortText("assistant safe_error_message", entry.kind.value.safeErrorMessage, false);
      break;
    case "toolResult":
      validateIdentifier("tool result call_id", entry.kind.value.toolCallId);
      validateRequiredShortText("tool result name", entry.kind.value.toolName);
      requireSafeValue("tool result details", entry.kind.value.safeDetails);
      break;
    case "bash":
      validateInlineConversationText("bash command", entry.kind.value.command, true);
      break;
    case "custom":
      validateRequiredShortText("custom type", entry.kind.value.customType);
      requireSafeValue("custom details", entry.kind.value.safeDetails);
      break;
    case "compaction":
      validateIdentifier("first_kept_entry_id", entry.kind.value.firstKeptEntryId);
      requireSafeValue("compaction details", entry.kind.value.safeDetails);
      break;
    case "branchSummary":
      validateIdentifier("branch summary from_entry_id", entry.kind.value.fromEntryId);
      requireSafeValue("branch summary details", entry.kind.value.safeDetails);
      break;
    case "marker": {
      const marker = entry.kind.value;
      if (
        marker.markerKind !== MarkerKind.THINKING_LEVEL &&
        marker.markerKind !== MarkerKind.MODEL_CHANGE &&
        marker.markerKind !== MarkerKind.LABEL &&
        marker.markerKind !== MarkerKind.SESSION_INFO
      ) {
        fail("conversation marker kind is unknown");
      }
      validateOptionalIdentifier("marker target_entry_id", marker.targetEntryId);
      validateShortText("marker label", marker.label, false);
      validateShortText("marker provider", marker.provider, false);
      validateShortText("marker model", marker.model, false);
      validateShortText("marker thinking_level", marker.thinkingLevel, false);
      break;
    }
    case "unknown":
      validateRequiredShortText("unknown entry source_type", entry.kind.value.sourceType);
      break;
    case undefined:
      fail("conversation entry must contain a typed kind");
  }
}

function validateConversationPart(part: ConversationPart): void {
  validateIdentifier("part_id", part.partId);
  validatePositiveUint64("part revision", part.revision);
  switch (part.kind.case) {
    case "text":
      validateBoundedPartContent("text part", part.kind.value.content, false);
      return;
    case "thinking": {
      const thinking = part.kind.value;
      if (
        thinking.visibility !== ThinkingVisibility.VISIBLE &&
        thinking.visibility !== ThinkingVisibility.REDACTED &&
        thinking.visibility !== ThinkingVisibility.DEFERRED
      ) {
        fail("thinking visibility is unknown");
      }
      if (thinking.visibility === ThinkingVisibility.VISIBLE) {
        validateBoundedPartContent("thinking part", thinking.content, false);
      } else if (thinking.content.case !== undefined) {
        fail("redacted or deferred thinking must not contain content");
      }
      return;
    }
    case "image":
      if (part.kind.value.contentReference === undefined) {
        fail("image part must contain a content reference");
      }
      validateMessageContentReference(part.kind.value.contentReference);
      if (!part.kind.value.contentReference.mimeType.startsWith("image/")) {
        fail("image part content reference must use an image MIME type");
      }
      return;
    case "toolCall":
      validateIdentifier("tool_call_id", part.kind.value.toolCallId);
      validateRequiredShortText("tool name", part.kind.value.toolName);
      requireSafeValue("tool arguments", part.kind.value.safeArguments);
      return;
    case "unsupported":
      validateRequiredShortText("unsupported source_type", part.kind.value.sourceType);
      return;
    case undefined:
      fail("conversation part must contain a typed kind");
  }
}

function validateBoundedPartContent(
  label: string,
  content:
    | { readonly case: "inlineText"; readonly value: string }
    | { readonly case: "contentReference"; readonly value: MessageContentReference }
    | { readonly case: undefined; readonly value?: undefined },
  allowEmpty: boolean,
): void {
  switch (content.case) {
    case "inlineText":
      validateInlineConversationText(label, content.value, allowEmpty);
      return;
    case "contentReference":
      validateMessageContentReference(content.value);
      return;
    case undefined:
      fail(`${label} must contain inline text or a content reference`);
  }
}

function validateInlineConversationText(label: string, value: string, allowEmpty: boolean): void {
  const length = textEncoder.encode(value).length;
  if ((!allowEmpty && length === 0) || length > MAX_INLINE_CONVERSATION_TEXT_BYTES) {
    fail(`${label} is outside the inline conversation text limit`);
  }
}

function validateMessageContentReference(reference: MessageContentReference): void {
  validateIdentifier("content_id", reference.contentId);
  validateRequiredShortText("content mime_type", reference.mimeType);
  validateRequiredShortText("content display_name", reference.displayName);
  validatePositiveUint64("content total_bytes", reference.totalBytes);
  if (reference.totalBytes > BigInt(MAX_MESSAGE_CONTENT_BYTES)) {
    fail("message content reference exceeds the local hard limit");
  }
  validateRequiredDigest(reference.sha256);
}

function validateMessageContentBinding(binding: MessageContentBinding): void {
  validateIdentifier("content binding session_id", binding.sessionId);
  validateIdentifier("content binding entry_id", binding.entryId);
  validateIdentifier("content binding part_id", binding.partId);
  validatePositiveUint64("content binding entry_revision", binding.entryRevision);
  validatePositiveUint64("content binding part_revision", binding.partRevision);
  validateIdentifier("content binding content_id", binding.contentId);
}

function requireSafeValue(label: string, value: SafeValue | undefined): void {
  if (value === undefined) fail(`${label} must contain a safe value`);
  const bytes = validateSafeValue(value, 0);
  if (bytes > MAX_SAFE_VALUE_BYTES) fail(`${label} exceeds the safe value byte limit`);
}

function validateSafeValue(value: SafeValue, depth: number): number {
  if (depth > MAX_SAFE_VALUE_DEPTH) fail("safe value exceeds the depth limit");
  switch (value.value.case) {
    case "sentinel":
      if (
        value.value.value !== SafeValueKind.NULL &&
        value.value.value !== SafeValueKind.REDACTED
      ) {
        fail("safe value sentinel is unknown");
      }
      return 1;
    case "boolValue":
    case "intValue":
      return 8;
    case "doubleValue":
      if (!Number.isFinite(value.value.value)) fail("safe double must be finite");
      return 8;
    case "stringValue":
      return textEncoder.encode(value.value.value).length;
    case "listValue": {
      if (value.value.value.values.length > MAX_SAFE_VALUE_ITEMS) {
        fail("safe list exceeds the item limit");
      }
      return value.value.value.values.reduce(
        (total, child) => total + validateSafeValue(child, depth + 1),
        0,
      );
    }
    case "objectValue": {
      if (value.value.value.fields.length > MAX_SAFE_VALUE_ITEMS) {
        fail("safe object exceeds the item limit");
      }
      const keys = new Set<string>();
      let total = 0;
      for (const field of value.value.value.fields) {
        validateRequiredShortText("safe object key", field.key);
        if (keys.has(field.key)) fail("safe object contains a duplicate key");
        keys.add(field.key);
        if (field.value === undefined) fail("safe object field must contain a value");
        total += textEncoder.encode(field.key).length + validateSafeValue(field.value, depth + 1);
      }
      return total;
    }
    case undefined:
      fail("safe value must contain a typed value");
  }
}

function validateToolActivity(activity: ToolActivity): void {
  validateIdentifier("activity_id", activity.activityId);
  validateIdentifier("activity tool_call_id", activity.toolCallId);
  validateRequiredShortText("activity tool_name", activity.toolName);
  validatePositiveUint64("activity revision", activity.revision);
  if (
    activity.status !== ToolActivityStatus.PENDING &&
    activity.status !== ToolActivityStatus.RUNNING &&
    activity.status !== ToolActivityStatus.SUCCEEDED &&
    activity.status !== ToolActivityStatus.FAILED &&
    activity.status !== ToolActivityStatus.CANCELLED
  ) {
    fail("tool activity status is unknown");
  }
  if (activity.progressBasisPoints !== undefined && activity.progressBasisPoints > 10_000) {
    fail("tool activity progress exceeds 10000 basis points");
  }
  requireSafeValue("tool activity details", activity.safeDetails);
}

function validateConversationMetrics(metrics: ConversationMetrics): void {
  if (metrics.usage === undefined || metrics.cost === undefined) {
    fail("conversation metrics must contain usage and cost");
  }
  validateRequiredShortText("money currency_code", metrics.cost.currencyCode);
  if (!/^[A-Z]{3}$/u.test(metrics.cost.currencyCode)) {
    fail("money currency_code must be an ISO-style three-letter code");
  }
  validateDecimal("money decimal_amount", metrics.cost.decimalAmount);
  if (metrics.context !== undefined) {
    validatePositiveUint64("context window", metrics.context.contextWindow);
    if (metrics.context.tokens !== undefined) {
      validateNonNegativeUint64("context tokens", metrics.context.tokens);
      if (metrics.context.tokens > metrics.context.contextWindow) {
        fail("context tokens exceed context window");
      }
    }
    if (metrics.context.percentDecimal !== undefined) {
      validateDecimal("context percent", metrics.context.percentDecimal);
    }
  }
}

function validateDecimal(label: string, value: string): void {
  if (!/^(?:0|[1-9]\d*)(?:\.\d+)?$/u.test(value) || textEncoder.encode(value).length > MAX_SHORT_TEXT_BYTES) {
    fail(`${label} must be a non-negative canonical decimal`);
  }
}

function validateRevisionTransition(expected: bigint, resulting: bigint, label: string): void {
  validatePositiveUint64(`${label} expected revision`, expected);
  validatePositiveUint64(`${label} resulting revision`, resulting);
  if (resulting !== expected + 1n) fail(`${label} revision transition must advance by one`);
}

function validateSessionTreeMutationCommand(command: {
  readonly requestId: bigint;
  readonly commandId: string;
  readonly projectId: string;
  readonly sessionId: string;
  readonly expectedAdminRevision: string;
}): void {
  validateRequestId(command.requestId);
  validateIdentifier("command_id", command.commandId);
  validateIdentifier("project_id", command.projectId);
  validateIdentifier("session_id", command.sessionId);
  validateIdentifier("expected_admin_revision", command.expectedAdminRevision);
}

function requireSessionTree(
  label: string,
  tree: SessionTreeSnapshot | undefined,
): void {
  if (tree === undefined) {
    fail(`${label} must contain a session tree snapshot`);
  }
  validateSessionTree(tree);
}

function validateSessionTree(tree: SessionTreeSnapshot): void {
  validateIdentifier("session tree session_id", tree.sessionId);
  validateIdentifier("session tree admin_revision", tree.adminRevision);
  if (tree.nodes.length > MAX_MESSAGES_PER_SESSION_SNAPSHOT) {
    fail("session tree entry count exceeds the local hard limit");
  }
  const byId = new Map(tree.nodes.map((node) => [node.entryId, node]));
  if (byId.size !== tree.nodes.length) {
    fail("session tree contains a duplicate entry_id");
  }
  for (const node of tree.nodes) {
    validateIdentifier("session tree entry_id", node.entryId);
    if (node.parentEntryId.length > 0) {
      validateIdentifier("session tree parent_entry_id", node.parentEntryId);
      if (node.parentEntryId === node.entryId) {
        fail("session tree entry cannot parent itself");
      }
    }
    validateKnownEnum(
      "session tree entry kind",
      node.kind,
      knownSessionTreeEntryKinds,
    );
    validateContentText("session tree entry text", node.text, false);
    validatePositiveUint64(
      "session tree entry created_at_unix_millis",
      node.createdAtUnixMillis,
    );
    if (node.label.length > 0) {
      validateRequiredShortText("session tree entry label", node.label);
    }
    validateBoundedUint32("session tree depth", node.depth, 0xffff_ffff, true);
    const isUser = node.kind === SessionTreeEntryKind.USER_MESSAGE;
    if ((node.canEditFromHere || node.canFork) && !isUser) {
      fail("only user-message entries can expose edit or fork actions");
    }
  }

  const activeIds = new Set<string>();
  let previous: string | undefined;
  let activeContainsUser = false;
  for (const entryId of tree.activePathEntryIds) {
    validateIdentifier("active path entry_id", entryId);
    if (activeIds.has(entryId)) {
      fail("active path contains a duplicate entry_id");
    }
    activeIds.add(entryId);
    const node = byId.get(entryId);
    if (node === undefined) {
      fail("active path references an unknown entry_id");
    }
    if (previous === undefined) {
      if (node.parentEntryId.length > 0 && byId.has(node.parentEntryId)) {
        fail("active path must begin at a tree root");
      }
    } else if (node.parentEntryId !== previous) {
      fail("active path parent linkage is not contiguous");
    }
    if (!node.isOnActivePath) {
      fail("active path entry must be marked active");
    }
    activeContainsUser ||= node.kind === SessionTreeEntryKind.USER_MESSAGE;
    previous = entryId;
  }
  for (const node of tree.nodes) {
    if (node.isOnActivePath !== activeIds.has(node.entryId)) {
      fail(
        "session tree active-path flags disagree with active_path_entry_ids",
      );
    }
  }
  if (tree.activePathEntryIds.length === 0) {
    if (tree.activeLeafEntryId.length > 0 || tree.canCloneActiveBranch) {
      fail("an empty active path cannot expose a leaf or clone action");
    }
  } else {
    validateIdentifier("active_leaf_entry_id", tree.activeLeafEntryId);
    if (tree.activeLeafEntryId !== tree.activePathEntryIds.at(-1)) {
      fail("active leaf must be the final active path entry");
    }
    if (tree.canCloneActiveBranch && !activeContainsUser) {
      fail("a cloneable active branch must contain a user message");
    }
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
  if (summary.parentSessionId.length > 0) {
    validateIdentifier("parent_session_id", summary.parentSessionId);
    if (summary.parentSessionId === summary.sessionId) {
      fail("a session cannot be its own parent");
    }
  }
  validateRequiredShortText("session title", summary.title);
  validatePath("working_directory", summary.workingDirectory);
  validatePositiveUint64("created_at_unix_millis", summary.createdAtUnixMillis);
  validatePositiveUint64("updated_at_unix_millis", summary.updatedAtUnixMillis);
  if (summary.updatedAtUnixMillis < summary.createdAtUnixMillis) {
    fail("session updated time must not precede its created time");
  }
}

function validateMessageSnapshot(message: MessageSnapshot): void {
  validateIdentifier("message_id", message.messageId);
  validateKnownEnum("message role", message.role, knownMessageRoles);
  validateContentText("message text", message.text, false);
  validatePositiveUint64("created_at_unix_millis", message.createdAtUnixMillis);
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

function validateRequiredDigest(digest: Uint8Array): void {
  validateDigest(digest);
  if (digest.length !== SHA256_BYTES) {
    fail("sha256 must contain exactly 32 bytes");
  }
}

function validateBoundedUint32(
  label: string,
  value: number,
  maximum: number,
  allowZero: boolean,
): void {
  if (
    !Number.isSafeInteger(value) ||
    value < (allowZero ? 0 : 1) ||
    value > maximum
  ) {
    fail(`${label} is outside the local uint32 limit`);
  }
}

function validateRequestId(value: bigint): void {
  validatePositiveUint64("request_id", value);
}

function validateNonNegativeUint64(label: string, value: bigint): void {
  if (value < 0n) {
    fail(`${label} must be a non-negative uint64`);
  }
}

function validatePositiveUint64(label: string, value: bigint): void {
  if (value <= 0n) {
    fail(`${label} must be a positive uint64`);
  }
}

function validateOptionalIdentifier(label: string, value: string): void {
  if (value.length > 0) validateIdentifier(label, value);
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

function validateNonNegativeNumber(label: string, value: number): void {
  if (!Number.isFinite(value) || value < 0) {
    fail(`${label} must be a finite non-negative number`);
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
