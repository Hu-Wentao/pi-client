import { create } from "@bufbuild/protobuf";
import {
  DirectoryEntrySnapshotSchema,
  DirectoryListingSnapshotSchema,
  ErrorCode,
  KnownProjectSnapshotSchema,
  MAX_CONTENT_TEXT_BYTES,
  MAX_IDENTIFIER_BYTES,
  MAX_PATH_BYTES,
  MAX_SHORT_TEXT_BYTES,
  MessageRole,
  MessageSnapshotSchema,
  ProjectIdentitySnapshotSchema,
  ProjectSnapshotSchema,
  ProjectTrustReason,
  ProjectTrustSnapshotSchema,
  ProjectTrustStatus,
  SessionDetailSnapshotSchema,
  SessionSafeProjectionSnapshotSchema,
  SessionStatsSnapshotSchema,
  SessionSummarySnapshotSchema,
  SessionTreeEntryKind,
  SessionTreeNodeSnapshotSchema,
  SessionTreeSnapshotSchema,
  StableErrorSchema,
  type DirectoryListingSnapshot,
  type KnownProjectSnapshot,
  type MessageSnapshot,
  type ProjectSnapshot,
  type SessionDetailSnapshot,
  type SessionStatsSnapshot,
  type SessionSummarySnapshot,
  type SessionTreeSnapshot,
  type StableError,
} from "@pi-client/protocol";

import {
  PiNodeDomainError,
  type PiNodeCommandFailure,
  type PiNodeDirectoryListing,
  type PiNodeKnownProjectSnapshot,
  type PiNodeMessage,
  type PiNodeProjectSnapshot,
  type PiNodeProjectTrustReason,
  type PiNodeSessionSnapshot,
  type PiNodeSessionStats,
  type PiNodeSessionSummary,
  type PiNodeSessionTreeEntryKind,
  type PiNodeSessionTreeSnapshot,
} from "../pi-node-domain.js";

const textEncoder = new TextEncoder();
const forbiddenIdentifierControl = /[\u0000-\u001f\u007f]/u;
const omittedContent = "[Content omitted because it exceeds the unpublished v0 protocol limit.]";

export class PiNodeProtocolAdapterError extends Error {
  constructor(
    readonly code: "invalid-domain-data",
    message: string,
    options?: ErrorOptions,
  ) {
    super(message, options);
    this.name = "PiNodeProtocolAdapterError";
  }
}

export function toProtocolDirectoryListing(
  listing: PiNodeDirectoryListing,
): DirectoryListingSnapshot {
  return create(DirectoryListingSnapshotSchema, {
    canonicalDirectory: requirePath(listing.canonicalDirectory),
    parentDirectory:
      listing.parentDirectory === undefined ? "" : requirePath(listing.parentDirectory),
    children: listing.children.map((entry) =>
      create(DirectoryEntrySnapshotSchema, {
        name: fitShortText(entry.name),
        canonicalPath: requirePath(entry.canonicalPath),
        isSymbolicLink: entry.isSymbolicLink,
      }),
    ),
    truncated: listing.truncated,
  });
}

export function toProtocolProjectSnapshot(project: PiNodeProjectSnapshot): ProjectSnapshot {
  return create(ProjectSnapshotSchema, {
    identity: create(ProjectIdentitySnapshotSchema, {
      projectId: requireIdentifier(project.identity.projectId, "project identifier"),
      canonicalWorkingDirectory: requirePath(project.identity.canonicalCwd),
      isGitRepository: project.identity.isGitRepository,
      gitRoot: project.identity.gitRoot === undefined ? "" : requirePath(project.identity.gitRoot),
      mainWorktreeRoot:
        project.identity.mainWorktreeRoot === undefined
          ? ""
          : requirePath(project.identity.mainWorktreeRoot),
      branch: project.identity.branch === undefined ? "" : fitShortText(project.identity.branch),
      isLinkedWorktree: project.identity.isLinkedWorktree,
      isDetachedHead: project.identity.isDetachedHead,
      worktreeId: requireIdentifier(project.identity.worktreeId, "worktree identifier"),
      mainProjectId: requireIdentifier(project.identity.mainProjectId, "main project identifier"),
    }),
    trust: create(ProjectTrustSnapshotSchema, {
      status: toProtocolProjectTrustStatus(project.trust.status),
      reasons: project.trust.reasons.map(toProtocolProjectTrustReason),
      revision: requireIdentifier(project.trust.revision, "project trust revision"),
    }),
  });
}

export function toProtocolKnownProjectSnapshot(
  known: PiNodeKnownProjectSnapshot,
): KnownProjectSnapshot {
  return create(KnownProjectSnapshotSchema, {
    project: toProtocolProjectSnapshot(known.project),
    lastSessionAtUnixMillis: positiveMillis(known.lastSessionAtMs),
    sessionCount: positiveUint32(known.sessionCount),
  });
}

export function toProtocolSessionSummary(summary: PiNodeSessionSummary): SessionSummarySnapshot {
  const sessionId = requireIdentifier(summary.sessionId, "session identifier");
  const workingDirectory = requirePath(summary.cwd);
  const createdAtUnixMillis = positiveMillis(summary.createdAtMs);
  const updatedAtUnixMillis = laterMillis(summary.modifiedAtMs, createdAtUnixMillis);
  const title = fitShortText(
    summary.name?.trim() || summary.firstMessage.trim() || "Untitled session",
  );

  return create(SessionSummarySnapshotSchema, {
    sessionId,
    title,
    workingDirectory,
    createdAtUnixMillis,
    updatedAtUnixMillis,
    isRunning: summary.running,
    hasUnread: false,
    adminRevision: requireIdentifier(summary.adminRevision, "session administration revision"),
    hasCustomName: summary.name?.trim().length !== undefined && summary.name.trim().length > 0,
    parentSessionId:
      summary.parentSessionId === undefined
        ? ""
        : requireIdentifier(summary.parentSessionId, "parent session identifier"),
  });
}

export function toProtocolSessionDetail(snapshot: PiNodeSessionSnapshot): SessionDetailSnapshot {
  return create(SessionDetailSnapshotSchema, {
    summary: toProtocolSessionSummary(snapshot),
    messages: snapshot.messages.map((message) => toProtocolMessageSnapshot(message, false)),
  });
}

export function toProtocolSessionStats(stats: PiNodeSessionStats): SessionStatsSnapshot {
  const contextUsageAvailable = stats.contextWindow !== undefined;
  const contextTokensKnown = stats.contextTokens !== undefined;
  return create(SessionStatsSnapshotSchema, {
    projection: create(SessionSafeProjectionSnapshotSchema, {
      sessionFileName: fitShortText(stats.projection.sessionFileName),
      sessionId: requireIdentifier(stats.projection.sessionId, "session identifier"),
      projectId: requireIdentifier(stats.projection.projectId, "project identifier"),
      canonicalProjectDirectory: requirePath(stats.projection.canonicalProjectDirectory),
      worktreeId: requireIdentifier(stats.projection.worktreeId, "worktree identifier"),
      mainProjectId: requireIdentifier(stats.projection.mainProjectId, "main project identifier"),
      branch: stats.projection.branch === undefined ? "" : fitShortText(stats.projection.branch),
      isLinkedWorktree: stats.projection.isLinkedWorktree,
      isDetachedHead: stats.projection.isDetachedHead,
    }),
    userMessages: nonNegativeUint64(stats.userMessages, "user message count"),
    assistantMessages: nonNegativeUint64(stats.assistantMessages, "assistant message count"),
    toolCalls: nonNegativeUint64(stats.toolCalls, "tool call count"),
    toolResults: nonNegativeUint64(stats.toolResults, "tool result count"),
    totalMessages: nonNegativeUint64(stats.totalMessages, "total message count"),
    inputTokens: nonNegativeUint64(stats.inputTokens, "input token count"),
    outputTokens: nonNegativeUint64(stats.outputTokens, "output token count"),
    cacheReadTokens: nonNegativeUint64(stats.cacheReadTokens, "cache-read token count"),
    cacheWriteTokens: nonNegativeUint64(stats.cacheWriteTokens, "cache-write token count"),
    totalTokens: nonNegativeUint64(stats.totalTokens, "total token count"),
    cost: finiteNonNegative(stats.cost, "session cost"),
    hasContextUsage: contextUsageAvailable,
    contextTokens: contextTokensKnown
      ? nonNegativeUint64(stats.contextTokens!, "context token count")
      : 0n,
    contextWindow: contextUsageAvailable
      ? positiveUint64(stats.contextWindow!, "context window")
      : 0n,
    contextPercent:
      stats.contextPercent === undefined
        ? 0
        : finiteNonNegative(stats.contextPercent, "context percentage"),
    activeTimeMillis: nonNegativeUint64(stats.activeTimeMillis, "active time"),
    contextTokensKnown,
  });
}

export function toProtocolSessionTree(tree: PiNodeSessionTreeSnapshot): SessionTreeSnapshot {
  return create(SessionTreeSnapshotSchema, {
    sessionId: requireIdentifier(tree.sessionId, "session identifier"),
    nodes: tree.nodes.map((node) =>
      create(SessionTreeNodeSnapshotSchema, {
        entryId: requireIdentifier(node.entryId, "session tree entry identifier"),
        parentEntryId:
          node.parentEntryId === undefined
            ? ""
            : requireIdentifier(node.parentEntryId, "parent session tree entry identifier"),
        kind: toProtocolSessionTreeEntryKind(node.kind),
        text: fitContentText(node.text),
        createdAtUnixMillis: positiveMillis(node.createdAtMs),
        label: node.label === undefined ? "" : fitShortText(node.label),
        depth: positiveOrZeroUint32(node.depth),
        isOnActivePath: node.isOnActivePath,
        hasChildren: node.hasChildren,
        canEditFromHere: node.canEditFromHere,
        canFork: node.canFork,
      }),
    ),
    activePathEntryIds: tree.activePathEntryIds.map((entryId) =>
      requireIdentifier(entryId, "active path entry identifier"),
    ),
    activeLeafEntryId:
      tree.activeLeafEntryId === undefined
        ? ""
        : requireIdentifier(tree.activeLeafEntryId, "active leaf entry identifier"),
    canCloneActiveBranch: tree.canCloneActiveBranch,
    adminRevision: requireIdentifier(tree.adminRevision, "session administration revision"),
  });
}

export function toProtocolMessageSnapshot(
  message: PiNodeMessage,
  isStreaming: boolean,
): MessageSnapshot {
  return create(MessageSnapshotSchema, {
    messageId: requireIdentifier(message.id, "message identifier"),
    role: toProtocolMessageRole(message.role),
    text: fitContentText(piNodeMessageText(message)),
    createdAtUnixMillis: positiveMillis(message.timestampMs),
    isStreaming,
  });
}

export function piNodeMessageText(message: PiNodeMessage): string {
  const parts: string[] = [];
  for (const part of message.parts) {
    switch (part.type) {
      case "text":
        parts.push(part.text);
        break;
      case "thinking":
        if (!part.redacted && part.text.length > 0) {
          parts.push(part.text);
        }
        break;
      case "image":
        parts.push(`[Image: ${fitShortText(part.mimeType || "unknown media type")}]`);
        break;
      case "tool-call":
        parts.push(`[Tool call: ${fitShortText(part.name || "unnamed")}]`);
        break;
      case "unsupported":
        parts.push(`[Unsupported content: ${fitShortText(part.sourceType || "unknown")}]`);
        break;
    }
  }
  return parts.join("\n");
}

export function mapDomainError(error: unknown): StableError {
  if (error instanceof PiNodeProtocolAdapterError) {
    return stableError(
      ErrorCode.DATA_LOSS,
      "Session data cannot be represented by the unpublished v0 protocol.",
    );
  }
  if (error instanceof TypeError || error instanceof RangeError) {
    return stableError(ErrorCode.INVALID_REQUEST, "The request is invalid.");
  }
  if (!(error instanceof PiNodeDomainError)) {
    return stableError(ErrorCode.INTERNAL, "The Pi Node operation failed.");
  }

  switch (error.code) {
    case "invalid-project-path":
    case "project-validation-failed":
      return stableError(ErrorCode.INVALID_REQUEST, "The project directory is invalid.");
    case "project-not-registered":
      return stableError(
        ErrorCode.FAILED_PRECONDITION,
        "The project must be validated before it can be used.",
      );
    case "project-trust-revision-stale":
      return stableError(ErrorCode.CONFLICT, "Project trust evidence changed. Validate again.");
    case "project-trust-denied":
      return stableError(ErrorCode.PERMISSION_DENIED, "Project access was denied.");
    case "project-trust-unresolved":
      return stableError(
        ErrorCode.FAILED_PRECONDITION,
        "The project requires an explicit trust decision.",
      );
    case "session-not-found":
      return stableError(ErrorCode.NOT_FOUND, "The requested session was not found.");
    case "session-not-loaded":
      return stableError(
        ErrorCode.FAILED_PRECONDITION,
        "The session must be opened before issuing commands.",
      );
    case "session-owned":
      return stableError(ErrorCode.CONFLICT, "The session is already in use.");
    case "session-capacity-exceeded":
      return stableError(ErrorCode.NODE_BUSY, "The Pi Node session capacity is exhausted.", true);
    case "session-history-cursor-invalid":
      return stableError(ErrorCode.INVALID_REQUEST, "The session history cursor is invalid.");
    case "session-history-conflict":
      return stableError(
        ErrorCode.CONFLICT,
        "The active session branch changed. Refresh and try again.",
      );
    case "session-admin-invalid-name":
      return stableError(ErrorCode.INVALID_REQUEST, "The session name is invalid.");
    case "session-admin-confirmation-required":
      return stableError(
        ErrorCode.FAILED_PRECONDITION,
        "Explicit session deletion confirmation is required.",
      );
    case "session-admin-conflict":
      return stableError(ErrorCode.CONFLICT, "The session changed. Refresh and try again.");
    case "session-admin-locked":
      return stableError(ErrorCode.NODE_BUSY, "The session is being administered.", true);
    case "session-auto-name-model-unavailable":
      return stableError(ErrorCode.FAILED_PRECONDITION, "The session model is unavailable.");
    case "session-auto-name-provider-auth-required":
      return stableError(
        ErrorCode.AUTHENTICATION_REQUIRED,
        "The session model provider requires authentication.",
      );
    case "session-auto-name-timeout":
      return stableError(
        ErrorCode.DEADLINE_EXCEEDED,
        "Session naming exceeded its deadline.",
        true,
      );
    case "session-auto-name-cancelled":
      return stableError(ErrorCode.CANCELLED, "Session naming was cancelled.");
    case "session-tree-entry-invalid":
      return stableError(ErrorCode.INVALID_REQUEST, "The selected session tree entry is invalid.");
    case "session-clone-ineligible":
      return stableError(
        ErrorCode.FAILED_PRECONDITION,
        "The active branch is not eligible for cloning.",
      );
    case "session-mutation-conflict":
      return stableError(ErrorCode.CONFLICT, "The session changed. Refresh and try again.");
    case "session-mutation-locked":
      return stableError(ErrorCode.NODE_BUSY, "The session has an active mutation.", true);
    case "service-disposed":
      return stableError(ErrorCode.UNAVAILABLE, "The Pi Node service is unavailable.", true);
    case "project-trust-resolution-failed":
    case "project-browse-failed":
    case "project-list-failed":
    case "project-trust-persist-failed":
    case "session-list-failed":
    case "session-create-failed":
    case "session-load-failed":
    case "session-dispose-failed":
    case "session-admin-failed":
    case "session-auto-name-failed":
    case "session-mutation-failed":
    case "session-export-failed":
    case "abort-failed":
      return stableError(ErrorCode.INTERNAL, "The Pi Node operation failed.");
  }
}

export function mapCommandFailure(failure: PiNodeCommandFailure): StableError {
  switch (failure.code) {
    case "invalid-prompt":
      return stableError(ErrorCode.INVALID_REQUEST, "The prompt is invalid.");
    case "session-busy":
      return stableError(ErrorCode.NODE_BUSY, "The session already has an active command.", true);
    case "model-unavailable":
      return stableError(ErrorCode.FAILED_PRECONDITION, "No usable model is selected.");
    case "provider-auth-required":
      return stableError(
        ErrorCode.AUTHENTICATION_REQUIRED,
        "The selected provider requires authentication.",
      );
    case "prompt-rejected":
      return stableError(ErrorCode.FAILED_PRECONDITION, "The prompt was rejected.");
    case "aborted":
      return stableError(ErrorCode.CANCELLED, "The command was aborted.");
    case "runtime-failed":
      return stableError(ErrorCode.INTERNAL, "The command failed in the Pi runtime.");
  }
}

export function stableError(
  code: ErrorCode,
  safeMessage: string,
  retryable = false,
  retryAfterMillis = 0,
): StableError {
  return create(StableErrorSchema, {
    code,
    retryable,
    retryAfterMillis: retryable ? retryAfterMillis : 0,
    safeMessage: fitShortText(safeMessage),
  });
}

function toProtocolProjectTrustStatus(
  status: PiNodeProjectSnapshot["trust"]["status"],
): ProjectTrustStatus {
  switch (status) {
    case "not-required":
      return ProjectTrustStatus.NOT_REQUIRED;
    case "trusted":
      return ProjectTrustStatus.TRUSTED;
    case "approval-required":
      return ProjectTrustStatus.APPROVAL_REQUIRED;
    case "denied":
      return ProjectTrustStatus.DENIED;
  }
}

function toProtocolProjectTrustReason(reason: PiNodeProjectTrustReason): ProjectTrustReason {
  switch (reason) {
    case "pi-settings":
      return ProjectTrustReason.PI_SETTINGS;
    case "pi-extensions":
      return ProjectTrustReason.PI_EXTENSIONS;
    case "pi-skills":
      return ProjectTrustReason.PI_SKILLS;
    case "pi-prompts":
      return ProjectTrustReason.PI_PROMPTS;
    case "pi-themes":
      return ProjectTrustReason.PI_THEMES;
    case "pi-system-prompt":
      return ProjectTrustReason.PI_SYSTEM_PROMPT;
    case "agent-skills":
      return ProjectTrustReason.AGENT_SKILLS;
    case "saved-approval":
      return ProjectTrustReason.SAVED_APPROVAL;
    case "saved-denial":
      return ProjectTrustReason.SAVED_DENIAL;
  }
}

function toProtocolSessionTreeEntryKind(kind: PiNodeSessionTreeEntryKind): SessionTreeEntryKind {
  switch (kind) {
    case "user-message":
      return SessionTreeEntryKind.USER_MESSAGE;
    case "assistant-message":
      return SessionTreeEntryKind.ASSISTANT_MESSAGE;
    case "tool-message":
      return SessionTreeEntryKind.TOOL_MESSAGE;
    case "custom-message":
      return SessionTreeEntryKind.CUSTOM_MESSAGE;
    case "thinking-level":
      return SessionTreeEntryKind.THINKING_LEVEL;
    case "model-change":
      return SessionTreeEntryKind.MODEL_CHANGE;
    case "compaction":
      return SessionTreeEntryKind.COMPACTION;
    case "branch-summary":
      return SessionTreeEntryKind.BRANCH_SUMMARY;
    case "custom":
      return SessionTreeEntryKind.CUSTOM;
    case "label":
      return SessionTreeEntryKind.LABEL;
    case "session-info":
      return SessionTreeEntryKind.SESSION_INFO;
  }
}

function toProtocolMessageRole(role: PiNodeMessage["role"]): MessageRole {
  switch (role) {
    case "user":
      return MessageRole.USER;
    case "assistant":
      return MessageRole.ASSISTANT;
    case "tool":
      return MessageRole.TOOL;
    case "custom":
      return MessageRole.SYSTEM;
  }
}

function requireIdentifier(value: string, label: string): string {
  const bytes = textEncoder.encode(value).length;
  if (
    bytes === 0 ||
    bytes > MAX_IDENTIFIER_BYTES ||
    value.trim() !== value ||
    forbiddenIdentifierControl.test(value)
  ) {
    throw new PiNodeProtocolAdapterError(
      "invalid-domain-data",
      `The ${label} is outside the protocol identifier bounds.`,
    );
  }
  return value;
}

function requirePath(value: string): string {
  const bytes = textEncoder.encode(value).length;
  if (
    bytes === 0 ||
    bytes > MAX_PATH_BYTES ||
    value.trim() !== value ||
    forbiddenIdentifierControl.test(value)
  ) {
    throw new PiNodeProtocolAdapterError(
      "invalid-domain-data",
      "The working directory is outside the protocol path bounds.",
    );
  }
  return value;
}

function fitShortText(value: string): string {
  return fitText(value, MAX_SHORT_TEXT_BYTES, "Unnamed");
}

function fitContentText(value: string): string {
  if (textEncoder.encode(value).length <= MAX_CONTENT_TEXT_BYTES && !value.includes("\u0000")) {
    return value;
  }
  return omittedContent;
}

function fitText(value: string, maxBytes: number, fallback: string): string {
  const normalized = value.replaceAll("\u0000", "").trim() || fallback;
  if (textEncoder.encode(normalized).length <= maxBytes) {
    return normalized;
  }

  let result = "";
  for (const character of normalized) {
    if (textEncoder.encode(result + character).length > maxBytes) {
      break;
    }
    result += character;
  }
  return result || fallback;
}

function nonNegativeUint64(value: number, label: string): bigint {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new PiNodeProtocolAdapterError(
      "invalid-domain-data",
      `The ${label} is outside the protocol uint64 bounds.`,
    );
  }
  return BigInt(value);
}

function positiveUint64(value: number, label: string): bigint {
  if (!Number.isSafeInteger(value) || value < 1) {
    throw new PiNodeProtocolAdapterError(
      "invalid-domain-data",
      `The ${label} is outside the protocol uint64 bounds.`,
    );
  }
  return BigInt(value);
}

function finiteNonNegative(value: number, label: string): number {
  if (!Number.isFinite(value) || value < 0) {
    throw new PiNodeProtocolAdapterError(
      "invalid-domain-data",
      `The ${label} is outside the protocol numeric bounds.`,
    );
  }
  return value;
}

function positiveMillis(value: number): bigint {
  if (!Number.isFinite(value)) {
    return 1n;
  }
  return BigInt(Math.max(1, Math.floor(value)));
}

function laterMillis(value: number, minimum: bigint): bigint {
  const candidate = positiveMillis(value);
  return candidate < minimum ? minimum : candidate;
}

function positiveOrZeroUint32(value: number): number {
  if (!Number.isSafeInteger(value) || value < 0 || value > 0xffff_ffff) {
    throw new PiNodeProtocolAdapterError(
      "invalid-domain-data",
      "The session tree depth is outside the protocol bounds.",
    );
  }
  return value;
}

function positiveUint32(value: number): number {
  if (!Number.isSafeInteger(value) || value < 1 || value > 0xffff_ffff) {
    throw new PiNodeProtocolAdapterError(
      "invalid-domain-data",
      "The project session count is outside the protocol bounds.",
    );
  }
  return value;
}
