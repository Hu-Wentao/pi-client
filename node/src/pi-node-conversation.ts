export type PiNodeSafeValue =
  | { readonly kind: "null" }
  | { readonly kind: "redacted" }
  | { readonly kind: "bool"; readonly value: boolean }
  | { readonly kind: "int"; readonly value: number }
  | { readonly kind: "double"; readonly value: number }
  | { readonly kind: "string"; readonly value: string }
  | { readonly kind: "list"; readonly values: readonly PiNodeSafeValue[] }
  | {
      readonly kind: "object";
      readonly fields: readonly {
        readonly key: string;
        readonly value: PiNodeSafeValue;
      }[];
    };

export type PiNodeConversationIdentityScope = "persistent" | "runtime";

export interface PiNodeConversationEntryIdentity {
  readonly entryId: string;
  readonly scope: PiNodeConversationIdentityScope;
  readonly originCommandId?: string;
}

export interface PiNodeMessageContentReference {
  readonly contentId: string;
  readonly mimeType: string;
  readonly displayName: string;
  readonly totalBytes: number;
  readonly sha256: Uint8Array;
}

export interface PiNodeMessageContentBinding {
  readonly sessionId: string;
  readonly entryId: string;
  readonly partId: string;
  readonly entryRevision: number;
  readonly partRevision: number;
  readonly contentId: string;
}

interface PiNodeConversationPartBase {
  readonly partId: string;
  readonly revision: number;
}

export type PiNodeConversationPart =
  | (PiNodeConversationPartBase & {
      readonly type: "text";
      readonly text?: string;
      readonly contentReference?: PiNodeMessageContentReference;
    })
  | (PiNodeConversationPartBase & {
      readonly type: "thinking";
      readonly visibility: "visible" | "redacted" | "deferred";
      readonly text?: string;
      readonly contentReference?: PiNodeMessageContentReference;
    })
  | (PiNodeConversationPartBase & {
      readonly type: "image";
      readonly contentReference: PiNodeMessageContentReference;
    })
  | (PiNodeConversationPartBase & {
      readonly type: "tool-call";
      readonly toolCallId: string;
      readonly toolName: string;
      readonly safeArguments: PiNodeSafeValue;
    })
  | (PiNodeConversationPartBase & {
      readonly type: "unsupported";
      readonly sourceType: string;
    });

export type PiNodeToolActivityStatus = "pending" | "running" | "succeeded" | "failed" | "cancelled";

export interface PiNodeToolActivity {
  readonly activityId: string;
  readonly toolCallId: string;
  readonly toolName: string;
  readonly sourceOrdinal: number;
  readonly revision: number;
  readonly status: PiNodeToolActivityStatus;
  readonly progressBasisPoints?: number;
  readonly safeDetails: PiNodeSafeValue;
}

export interface PiNodeUsageMetrics {
  readonly inputTokens: number;
  readonly outputTokens: number;
  readonly cacheReadTokens: number;
  readonly cacheWriteTokens: number;
  readonly totalTokens: number;
}

export interface PiNodeMoneyAmount {
  readonly currencyCode: string;
  readonly decimalAmount: string;
}

export interface PiNodeContextMetrics {
  readonly tokens?: number;
  readonly contextWindow: number;
  readonly percentDecimal?: string;
}

export interface PiNodeConversationMetrics {
  readonly usage: PiNodeUsageMetrics;
  readonly cost: PiNodeMoneyAmount;
  readonly context?: PiNodeContextMetrics;
}

interface PiNodeConversationEntryBase {
  readonly identity: PiNodeConversationEntryIdentity;
  readonly revision: number;
  readonly createdAtMs: number;
  readonly finalized: boolean;
  readonly parts: readonly PiNodeConversationPart[];
  readonly toolActivities: readonly PiNodeToolActivity[];
  readonly metrics?: PiNodeConversationMetrics;
}

export type PiNodeConversationEntry =
  | (PiNodeConversationEntryBase & { readonly type: "user" })
  | (PiNodeConversationEntryBase & {
      readonly type: "assistant";
      readonly provider: string;
      readonly model: string;
      readonly stopReason: string;
      readonly safeErrorMessage?: string;
    })
  | (PiNodeConversationEntryBase & {
      readonly type: "tool-result";
      readonly toolCallId: string;
      readonly toolName: string;
      readonly isError: boolean;
      readonly safeDetails: PiNodeSafeValue;
    })
  | (PiNodeConversationEntryBase & {
      readonly type: "bash";
      readonly command: string;
      readonly exitCode?: number;
      readonly cancelled: boolean;
      readonly truncated: boolean;
      readonly excludedFromContext: boolean;
    })
  | (PiNodeConversationEntryBase & {
      readonly type: "custom";
      readonly customType: string;
      readonly display: boolean;
      readonly safeDetails: PiNodeSafeValue;
    })
  | (PiNodeConversationEntryBase & {
      readonly type: "compaction";
      readonly firstKeptEntryId: string;
      readonly tokensBefore: number;
      readonly fromHook: boolean;
      readonly safeDetails: PiNodeSafeValue;
    })
  | (PiNodeConversationEntryBase & {
      readonly type: "branch-summary";
      readonly fromEntryId: string;
      readonly fromHook: boolean;
      readonly safeDetails: PiNodeSafeValue;
    })
  | (PiNodeConversationEntryBase & {
      readonly type: "marker";
      readonly markerKind: "thinking-level" | "model-change" | "label" | "session-info";
      readonly targetEntryId?: string;
      readonly label?: string;
      readonly provider?: string;
      readonly model?: string;
      readonly thinkingLevel?: string;
    })
  | (PiNodeConversationEntryBase & {
      readonly type: "unknown";
      readonly sourceType: string;
    });

export interface PiNodeConversationSnapshot {
  readonly sessionId: string;
  readonly entries: readonly PiNodeConversationEntry[];
  readonly lastEventSequence: number;
}

export interface PiNodeConversationPage {
  readonly sessionId: string;
  readonly entries: readonly PiNodeConversationEntry[];
  readonly nextCursor?: string;
  readonly hasMore: boolean;
  readonly activeBranchRevision: string;
  readonly treeRevision: string;
  readonly lastEventSequence: number;
}

export type PiNodeConversationBackendEvent =
  | {
      readonly type: "entry-upsert";
      readonly entry: PiNodeConversationEntry;
      readonly expectedPreviousRevision?: number;
    }
  | {
      readonly type: "part-delta";
      readonly entryId: string;
      readonly expectedEntryRevision: number;
      readonly resultingEntryRevision: number;
      readonly partId: string;
      readonly expectedPartRevision: number;
      readonly resultingPartRevision: number;
      readonly textDelta: string;
    }
  | {
      readonly type: "entry-finalized";
      readonly entry: PiNodeConversationEntry;
      readonly expectedPreviousRevision: number;
    }
  | {
      readonly type: "tool-activity";
      readonly entryId: string;
      readonly expectedEntryRevision: number;
      readonly resultingEntryRevision: number;
      readonly activity: PiNodeToolActivity;
    }
  | {
      readonly type: "metrics";
      readonly entryId: string;
      readonly expectedEntryRevision: number;
      readonly resultingEntryRevision: number;
      readonly metrics: PiNodeConversationMetrics;
    };

export interface PiNodeMessageContentRequest {
  readonly binding: PiNodeMessageContentBinding;
  readonly expectedMimeType: string;
  readonly expectedTotalBytes: number;
  readonly expectedSha256: Uint8Array;
}

export interface PiNodeMessageContent {
  readonly binding: PiNodeMessageContentBinding;
  readonly reference: PiNodeMessageContentReference;
  readonly bytes: Uint8Array;
}
