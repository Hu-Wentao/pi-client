import { create } from "@bufbuild/protobuf";
import {
  AssistantConversationEntrySchema,
  BashConversationEntrySchema,
  BoundedTextPartSchema,
  BranchSummaryConversationEntrySchema,
  CompactionConversationEntrySchema,
  ContextMetricsSchema,
  ConversationEntryIdentitySchema,
  ConversationEntrySchema,
  ConversationIdentityScope,
  ConversationMetricsSchema,
  ConversationPageSchema,
  ConversationPartSchema,
  ConversationSnapshotSchema,
  CustomConversationEntrySchema,
  DirectoryEntrySnapshotSchema,
  DirectoryListingSnapshotSchema,
  ErrorCode,
  ImagePartSchema,
  KnownProjectSnapshotSchema,
  MarkerConversationEntrySchema,
  MarkerKind,
  MAX_CONTENT_TEXT_BYTES,
  MAX_IDENTIFIER_BYTES,
  MAX_PATH_BYTES,
  MAX_SHORT_TEXT_BYTES,
  MessageContentBindingSchema,
  MessageContentReferenceSchema,
  MoneyAmountSchema,
  ProjectIdentitySnapshotSchema,
  ProjectSnapshotSchema,
  ProjectTrustReason,
  ProjectTrustSnapshotSchema,
  ProjectTrustStatus,
  SafeListSchema,
  SafeObjectFieldSchema,
  SafeObjectSchema,
  SafeValueKind,
  SafeValueSchema,
  SessionDetailSnapshotSchema,
  SessionSafeProjectionSnapshotSchema,
  SessionStatsSnapshotSchema,
  SessionSummarySnapshotSchema,
  SessionTreeEntryKind,
  SessionTreeNodeSnapshotSchema,
  SessionTreeSnapshotSchema,
  StableErrorSchema,
  ThinkingPartSchema,
  ThinkingVisibility,
  ToolActivitySchema,
  ToolActivityStatus,
  ToolCallPartSchema,
  ToolResultConversationEntrySchema,
  UnknownConversationEntrySchema,
  UnsupportedPartSchema,
  UsageMetricsSchema,
  UserConversationEntrySchema,
  type ConversationEntry,
  type ConversationPage,
  type ConversationSnapshot,
  type DirectoryListingSnapshot,
  type KnownProjectSnapshot,
  type MessageContentBinding,
  type ProjectSnapshot,
  type SafeValue,
  type SessionDetailSnapshot,
  type SessionStatsSnapshot,
  type SessionSummarySnapshot,
  type SessionTreeSnapshot,
  type StableError,
} from "@pi-client/protocol";

import {
  PiNodeDomainError,
  type PiNodeCommandFailure,
  type PiNodeConversationEntry,
  type PiNodeConversationMetrics,
  type PiNodeConversationPage,
  type PiNodeConversationPart,
  type PiNodeConversationSnapshot,
  type PiNodeDirectoryListing,
  type PiNodeKnownProjectSnapshot,
  type PiNodeMessageContentBinding,
  type PiNodeProjectSnapshot,
  type PiNodeSafeValue,
  type PiNodeToolActivity,
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
    conversation: toProtocolConversationSnapshot(snapshot.conversation),
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

export function toProtocolConversationSnapshot(
  snapshot: PiNodeConversationSnapshot,
): ConversationSnapshot {
  return create(ConversationSnapshotSchema, {
    sessionId: requireIdentifier(snapshot.sessionId, "conversation session identifier"),
    entries: snapshot.entries.map(toProtocolConversationEntry),
    lastEventSequence: nonNegativeUint64(snapshot.lastEventSequence, "conversation event sequence"),
  });
}

export function toProtocolConversationPage(page: PiNodeConversationPage): ConversationPage {
  return create(ConversationPageSchema, {
    sessionId: requireIdentifier(page.sessionId, "conversation session identifier"),
    entries: page.entries.map(toProtocolConversationEntry),
    nextCursor: page.nextCursor === undefined ? "" : fitShortText(page.nextCursor),
    hasMore: page.hasMore,
    activeBranchRevision: requireIdentifier(page.activeBranchRevision, "active branch revision"),
    treeRevision: requireIdentifier(page.treeRevision, "tree revision"),
    lastEventSequence: nonNegativeUint64(page.lastEventSequence, "conversation event sequence"),
  });
}

export function toProtocolConversationEntry(entry: PiNodeConversationEntry): ConversationEntry {
  const kind = toProtocolEntryKind(entry);
  return create(ConversationEntrySchema, {
    identity: create(ConversationEntryIdentitySchema, {
      entryId: requireIdentifier(entry.identity.entryId, "conversation entry identifier"),
      scope:
        entry.identity.scope === "persistent"
          ? ConversationIdentityScope.PERSISTENT
          : ConversationIdentityScope.RUNTIME,
      originCommandId:
        entry.identity.originCommandId === undefined
          ? ""
          : requireIdentifier(entry.identity.originCommandId, "origin command identifier"),
    }),
    revision: positiveUint64(entry.revision, "conversation entry revision"),
    createdAtUnixMillis: positiveMillis(entry.createdAtMs),
    finalized: entry.finalized,
    parts: entry.parts.map(toProtocolConversationPart),
    toolActivities: entry.toolActivities.map(toProtocolToolActivity),
    ...(entry.metrics === undefined
      ? {}
      : { metrics: toProtocolConversationMetrics(entry.metrics) }),
    kind,
  });
}

function toProtocolEntryKind(entry: PiNodeConversationEntry): ConversationEntry["kind"] {
  switch (entry.type) {
    case "user":
      return { case: "user", value: create(UserConversationEntrySchema) };
    case "assistant":
      return {
        case: "assistant",
        value: create(AssistantConversationEntrySchema, {
          provider: fitShortText(entry.provider),
          model: fitShortText(entry.model),
          stopReason: fitShortText(entry.stopReason),
          safeErrorMessage:
            entry.safeErrorMessage === undefined ? "" : fitShortText(entry.safeErrorMessage),
        }),
      };
    case "tool-result":
      return {
        case: "toolResult",
        value: create(ToolResultConversationEntrySchema, {
          toolCallId: requireIdentifier(entry.toolCallId, "tool call identifier"),
          toolName: fitShortText(entry.toolName),
          isError: entry.isError,
          safeDetails: toProtocolSafeValue(entry.safeDetails),
        }),
      };
    case "bash":
      return {
        case: "bash",
        value: create(BashConversationEntrySchema, {
          command: fitContentText(entry.command),
          ...(entry.exitCode === undefined ? {} : { exitCode: entry.exitCode }),
          cancelled: entry.cancelled,
          truncated: entry.truncated,
          excludedFromContext: entry.excludedFromContext,
        }),
      };
    case "custom":
      return {
        case: "custom",
        value: create(CustomConversationEntrySchema, {
          customType: fitShortText(entry.customType),
          display: entry.display,
          safeDetails: toProtocolSafeValue(entry.safeDetails),
        }),
      };
    case "compaction":
      return {
        case: "compaction",
        value: create(CompactionConversationEntrySchema, {
          firstKeptEntryId: requireIdentifier(
            entry.firstKeptEntryId,
            "first kept entry identifier",
          ),
          tokensBefore: nonNegativeUint64(entry.tokensBefore, "tokens before compaction"),
          fromHook: entry.fromHook,
          safeDetails: toProtocolSafeValue(entry.safeDetails),
        }),
      };
    case "branch-summary":
      return {
        case: "branchSummary",
        value: create(BranchSummaryConversationEntrySchema, {
          fromEntryId: requireIdentifier(entry.fromEntryId, "branch source entry identifier"),
          fromHook: entry.fromHook,
          safeDetails: toProtocolSafeValue(entry.safeDetails),
        }),
      };
    case "marker":
      return {
        case: "marker",
        value: create(MarkerConversationEntrySchema, {
          markerKind: toProtocolMarkerKind(entry.markerKind),
          targetEntryId:
            entry.targetEntryId === undefined
              ? ""
              : requireIdentifier(entry.targetEntryId, "marker target entry identifier"),
          label: entry.label === undefined ? "" : fitShortText(entry.label),
          provider: entry.provider === undefined ? "" : fitShortText(entry.provider),
          model: entry.model === undefined ? "" : fitShortText(entry.model),
          thinkingLevel: entry.thinkingLevel === undefined ? "" : fitShortText(entry.thinkingLevel),
        }),
      };
    case "unknown":
      return {
        case: "unknown",
        value: create(UnknownConversationEntrySchema, {
          sourceType: fitShortText(entry.sourceType),
        }),
      };
  }
}

function toProtocolConversationPart(part: PiNodeConversationPart) {
  const base = {
    partId: requireIdentifier(part.partId, "conversation part identifier"),
    revision: positiveUint64(part.revision, "conversation part revision"),
  };
  switch (part.type) {
    case "text":
      return create(ConversationPartSchema, {
        ...base,
        kind: {
          case: "text",
          value: create(BoundedTextPartSchema, {
            content:
              part.text !== undefined
                ? { case: "inlineText", value: part.text }
                : {
                    case: "contentReference",
                    value: toProtocolContentReference(part.contentReference!),
                  },
          }),
        },
      });
    case "thinking":
      return create(ConversationPartSchema, {
        ...base,
        kind: {
          case: "thinking",
          value: create(ThinkingPartSchema, {
            visibility: toProtocolThinkingVisibility(part.visibility),
            content:
              part.visibility !== "visible"
                ? { case: undefined }
                : part.text !== undefined
                  ? { case: "inlineText", value: part.text }
                  : {
                      case: "contentReference",
                      value: toProtocolContentReference(part.contentReference!),
                    },
          }),
        },
      });
    case "image":
      return create(ConversationPartSchema, {
        ...base,
        kind: {
          case: "image",
          value: create(ImagePartSchema, {
            contentReference: toProtocolContentReference(part.contentReference),
          }),
        },
      });
    case "tool-call":
      return create(ConversationPartSchema, {
        ...base,
        kind: {
          case: "toolCall",
          value: create(ToolCallPartSchema, {
            toolCallId: requireIdentifier(part.toolCallId, "tool call identifier"),
            toolName: fitShortText(part.toolName),
            safeArguments: toProtocolSafeValue(part.safeArguments),
          }),
        },
      });
    case "unsupported":
      return create(ConversationPartSchema, {
        ...base,
        kind: {
          case: "unsupported",
          value: create(UnsupportedPartSchema, { sourceType: fitShortText(part.sourceType) }),
        },
      });
  }
}

function toProtocolContentReference(
  reference: NonNullable<Extract<PiNodeConversationPart, { type: "image" }>["contentReference"]>,
) {
  return create(MessageContentReferenceSchema, {
    contentId: requireIdentifier(reference.contentId, "message content identifier"),
    mimeType: fitShortText(reference.mimeType),
    displayName: fitShortText(reference.displayName),
    totalBytes: positiveUint64(reference.totalBytes, "message content length"),
    sha256: Uint8Array.from(reference.sha256),
  });
}

export function toProtocolMessageContentBinding(
  binding: PiNodeMessageContentBinding,
): MessageContentBinding {
  return create(MessageContentBindingSchema, {
    sessionId: requireIdentifier(binding.sessionId, "content session identifier"),
    entryId: requireIdentifier(binding.entryId, "content entry identifier"),
    partId: requireIdentifier(binding.partId, "content part identifier"),
    entryRevision: positiveUint64(binding.entryRevision, "content entry revision"),
    partRevision: positiveUint64(binding.partRevision, "content part revision"),
    contentId: requireIdentifier(binding.contentId, "message content identifier"),
  });
}

function toProtocolSafeValue(value: PiNodeSafeValue): SafeValue {
  switch (value.kind) {
    case "null":
      return create(SafeValueSchema, {
        value: { case: "sentinel", value: SafeValueKind.NULL },
      });
    case "redacted":
      return create(SafeValueSchema, {
        value: { case: "sentinel", value: SafeValueKind.REDACTED },
      });
    case "bool":
      return create(SafeValueSchema, { value: { case: "boolValue", value: value.value } });
    case "int":
      return create(SafeValueSchema, {
        value: { case: "intValue", value: BigInt(value.value) },
      });
    case "double":
      return create(SafeValueSchema, {
        value: { case: "doubleValue", value: value.value },
      });
    case "string":
      return create(SafeValueSchema, {
        value: { case: "stringValue", value: value.value },
      });
    case "list":
      return create(SafeValueSchema, {
        value: {
          case: "listValue",
          value: create(SafeListSchema, { values: value.values.map(toProtocolSafeValue) }),
        },
      });
    case "object":
      return create(SafeValueSchema, {
        value: {
          case: "objectValue",
          value: create(SafeObjectSchema, {
            fields: value.fields.map((field) =>
              create(SafeObjectFieldSchema, {
                key: fitShortText(field.key),
                value: toProtocolSafeValue(field.value),
              }),
            ),
          }),
        },
      });
  }
}

export function toProtocolToolActivity(activity: PiNodeToolActivity) {
  return create(ToolActivitySchema, {
    activityId: requireIdentifier(activity.activityId, "tool activity identifier"),
    toolCallId: requireIdentifier(activity.toolCallId, "tool call identifier"),
    toolName: fitShortText(activity.toolName),
    sourceOrdinal: positiveOrZeroUint32(activity.sourceOrdinal),
    revision: positiveUint64(activity.revision, "tool activity revision"),
    status: toProtocolToolActivityStatus(activity.status),
    ...(activity.progressBasisPoints === undefined
      ? {}
      : { progressBasisPoints: activity.progressBasisPoints }),
    safeDetails: toProtocolSafeValue(activity.safeDetails),
  });
}

export function toProtocolConversationMetrics(metrics: PiNodeConversationMetrics) {
  return create(ConversationMetricsSchema, {
    usage: create(UsageMetricsSchema, {
      inputTokens: nonNegativeUint64(metrics.usage.inputTokens, "input tokens"),
      outputTokens: nonNegativeUint64(metrics.usage.outputTokens, "output tokens"),
      cacheReadTokens: nonNegativeUint64(metrics.usage.cacheReadTokens, "cache read tokens"),
      cacheWriteTokens: nonNegativeUint64(metrics.usage.cacheWriteTokens, "cache write tokens"),
      totalTokens: nonNegativeUint64(metrics.usage.totalTokens, "total tokens"),
    }),
    cost: create(MoneyAmountSchema, {
      currencyCode: fitShortText(metrics.cost.currencyCode),
      decimalAmount: fitShortText(metrics.cost.decimalAmount),
    }),
    ...(metrics.context === undefined
      ? {}
      : {
          context: create(ContextMetricsSchema, {
            ...(metrics.context.tokens === undefined
              ? {}
              : { tokens: nonNegativeUint64(metrics.context.tokens, "context tokens") }),
            contextWindow: positiveUint64(metrics.context.contextWindow, "context window"),
            ...(metrics.context.percentDecimal === undefined
              ? {}
              : { percentDecimal: fitShortText(metrics.context.percentDecimal) }),
          }),
        }),
  });
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
    case "session-content-invalid":
      return stableError(ErrorCode.DATA_LOSS, "The message content reference is stale or invalid.");
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

function toProtocolMarkerKind(
  kind: Extract<PiNodeConversationEntry, { type: "marker" }>["markerKind"],
): MarkerKind {
  switch (kind) {
    case "thinking-level":
      return MarkerKind.THINKING_LEVEL;
    case "model-change":
      return MarkerKind.MODEL_CHANGE;
    case "label":
      return MarkerKind.LABEL;
    case "session-info":
      return MarkerKind.SESSION_INFO;
  }
}

function toProtocolThinkingVisibility(
  visibility: Extract<PiNodeConversationPart, { type: "thinking" }>["visibility"],
): ThinkingVisibility {
  switch (visibility) {
    case "visible":
      return ThinkingVisibility.VISIBLE;
    case "redacted":
      return ThinkingVisibility.REDACTED;
    case "deferred":
      return ThinkingVisibility.DEFERRED;
  }
}

function toProtocolToolActivityStatus(status: PiNodeToolActivity["status"]): ToolActivityStatus {
  switch (status) {
    case "pending":
      return ToolActivityStatus.PENDING;
    case "running":
      return ToolActivityStatus.RUNNING;
    case "succeeded":
      return ToolActivityStatus.SUCCEEDED;
    case "failed":
      return ToolActivityStatus.FAILED;
    case "cancelled":
      return ToolActivityStatus.CANCELLED;
  }
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
