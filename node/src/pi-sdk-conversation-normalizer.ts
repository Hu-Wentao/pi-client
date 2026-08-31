import { createHash } from "node:crypto";

import type { AgentSessionEvent, SessionEntry } from "@earendil-works/pi-coding-agent";

import type {
  PiNodeConversationBackendEvent,
  PiNodeConversationEntry,
  PiNodeConversationMetrics,
  PiNodeConversationPart,
  PiNodeMessageContent,
  PiNodeMessageContentBinding,
  PiNodeMessageContentReference,
  PiNodeMessageContentRequest,
  PiNodeSafeValue,
  PiNodeToolActivity,
} from "./pi-node-conversation.js";

const textEncoder = new TextEncoder();
const MAX_INLINE_TEXT_BYTES = 64 * 1024;
const MAX_CONTENT_BYTES = 16 * 1024 * 1024;
const MAX_PARTS = 256;
const MAX_SAFE_DEPTH = 8;
const MAX_SAFE_ITEMS = 64;
const MAX_SAFE_STRING_BYTES = 4 * 1024;
const MAX_SAFE_TOTAL_BYTES = 64 * 1024;
const MAX_SAFE_KEY_BYTES = 256;
const MAX_SHORT_TEXT_BYTES = 1024;
const redactedKey =
  /(?:api[-_]?key|authorization|cookie|credential|password|private|secret|signature|token)/iu;

interface StoredContent {
  readonly binding: PiNodeMessageContentBinding;
  readonly reference: PiNodeMessageContentReference;
  readonly bytes: Uint8Array;
}

export class PiSdkConversationNormalizer {
  readonly #sessionId: string;
  readonly #clock: () => number;
  readonly #contentById = new Map<string, StoredContent>();
  readonly #activeContentBindings = new Map<string, PiNodeMessageContentBinding>();
  readonly #runtimeEntries = new Map<string, PiNodeConversationEntry>();
  #runtimeMessageIds = new WeakMap<object, string>();
  readonly #toolActivityByCallId = new Map<string, PiNodeToolActivity>();

  #runtimeOrdinal = 0;

  constructor(sessionId: string, clock: () => number = Date.now) {
    this.#sessionId = sessionId;
    this.#clock = clock;
  }

  resetRuntime(): void {
    const runtimeEntryIds = new Set(this.#runtimeEntries.keys());
    for (const [contentId, binding] of this.#activeContentBindings) {
      if (runtimeEntryIds.has(binding.entryId)) {
        this.#activeContentBindings.delete(contentId);
        this.#contentById.delete(contentId);
      }
    }
    this.#runtimeEntries.clear();
    this.#runtimeMessageIds = new WeakMap<object, string>();
    this.#toolActivityByCallId.clear();
    this.#runtimeOrdinal = 0;
  }

  persistentEntries(entries: readonly SessionEntry[]): readonly PiNodeConversationEntry[] {
    const normalized = entries.map((entry) => this.#persistentEntry(entry));
    for (const entry of normalized) this.#activateEntryContent(entry);
    return Object.freeze(normalized);
  }

  runtimeMessageId(message: unknown): string {
    if (typeof message === "object" && message !== null) {
      const existing = this.#runtimeMessageIds.get(message);
      if (existing !== undefined) return existing;
      const next = boundedRuntimeId(this.#sessionId, ++this.#runtimeOrdinal);
      this.#runtimeMessageIds.set(message, next);
      return next;
    }
    return boundedRuntimeId(this.#sessionId, ++this.#runtimeOrdinal);
  }

  acceptEvent(
    event: AgentSessionEvent,
    originCommandId: string | undefined,
  ): readonly PiNodeConversationBackendEvent[] {
    switch (event.type) {
      case "message_start": {
        const entryId = this.runtimeMessageId(event.message);
        const entry = this.#messageEntry(event.message, {
          entryId,
          scope: "runtime",
          originCommandId,
          revision: 1,
          finalized: false,
        });
        this.#activateEntryContent(entry);
        this.#runtimeEntries.set(entryId, entry);
        return Object.freeze([{ type: "entry-upsert", entry }]);
      }
      case "message_update": {
        const entryId = this.runtimeMessageId(event.message);
        const previous = this.#runtimeEntries.get(entryId);
        if (previous === undefined) {
          const entry = this.#messageEntry(event.message, {
            entryId,
            scope: "runtime",
            originCommandId,
            revision: 1,
            finalized: false,
          });
          this.#activateEntryContent(entry);
          this.#runtimeEntries.set(entryId, entry);
          return Object.freeze([{ type: "entry-upsert", entry }]);
        }

        const candidate = this.#messageEntry(event.message, {
          entryId,
          scope: "runtime",
          originCommandId: previous.identity.originCommandId ?? originCommandId,
          revision: previous.revision + 1,
          finalized: false,
        });
        const delta = assistantTextDelta(event, previous, candidate);
        const events: PiNodeConversationBackendEvent[] = [];
        let current = previous;
        if (delta !== undefined) {
          const nextRevision = current.revision + 1;
          const updatedPart = {
            ...delta.nextPart,
            revision: delta.previousPart.revision + 1,
          } satisfies PiNodeConversationPart;
          current = Object.freeze({
            ...candidate,
            revision: nextRevision,
            parts: Object.freeze(
              candidate.parts.map((part) =>
                part.partId === updatedPart.partId ? Object.freeze(updatedPart) : part,
              ),
            ),
            ...(previous.metrics === undefined ? {} : { metrics: previous.metrics }),
          }) as PiNodeConversationEntry;
          events.push(
            Object.freeze({
              type: "part-delta",
              entryId,
              expectedEntryRevision: previous.revision,
              resultingEntryRevision: nextRevision,
              partId: updatedPart.partId,
              expectedPartRevision: delta.previousPart.revision,
              resultingPartRevision: updatedPart.revision,
              textDelta: delta.delta,
            }),
          );
        } else {
          current = candidate;
          events.push(
            Object.freeze({
              type: "entry-upsert",
              entry: candidate,
              expectedPreviousRevision: previous.revision,
            }),
          );
        }

        if (!sameMetrics(previous.metrics, candidate.metrics) && candidate.metrics !== undefined) {
          const nextRevision = current.revision + 1;
          current = Object.freeze({
            ...current,
            revision: nextRevision,
            metrics: candidate.metrics,
          });
          events.push(
            Object.freeze({
              type: "metrics",
              entryId,
              expectedEntryRevision: nextRevision - 1,
              resultingEntryRevision: nextRevision,
              metrics: candidate.metrics,
            }),
          );
        }
        this.#activateEntryContent(current);
        this.#runtimeEntries.set(entryId, current);
        return Object.freeze(events);
      }
      case "message_end": {
        const entryId = this.runtimeMessageId(event.message);
        const previous = this.#runtimeEntries.get(entryId);
        const expectedPreviousRevision = previous?.revision ?? 0;
        const entry = this.#messageEntry(event.message, {
          entryId,
          scope: "runtime",
          originCommandId: previous?.identity.originCommandId ?? originCommandId,
          revision: expectedPreviousRevision + 1,
          finalized: true,
        });
        this.#activateEntryContent(entry);
        this.#runtimeEntries.set(entryId, entry);
        return Object.freeze([
          Object.freeze({ type: "entry-finalized", entry, expectedPreviousRevision }),
        ]);
      }
      case "tool_execution_start":
        return this.#toolActivityEvent(event.toolCallId, event.toolName, "running", event.args);
      case "tool_execution_update":
        return this.#toolActivityEvent(
          event.toolCallId,
          event.toolName,
          "running",
          event.partialResult,
        );
      case "tool_execution_end":
        return this.#toolActivityEvent(
          event.toolCallId,
          event.toolName,
          event.isError ? "failed" : "succeeded",
          event.result,
        );
      default:
        return Object.freeze([]);
    }
  }

  getContent(input: PiNodeMessageContentRequest): PiNodeMessageContent {
    const stored = this.#contentById.get(input.binding.contentId);
    const activeBinding = this.#activeContentBindings.get(input.binding.contentId);
    if (
      stored === undefined ||
      activeBinding === undefined ||
      !sameBinding(activeBinding, input.binding) ||
      !sameBinding(stored.binding, input.binding) ||
      stored.reference.mimeType !== input.expectedMimeType ||
      stored.reference.totalBytes !== input.expectedTotalBytes ||
      !sameBytes(stored.reference.sha256, input.expectedSha256) ||
      stored.bytes.length !== stored.reference.totalBytes ||
      stored.bytes.length > MAX_CONTENT_BYTES
    ) {
      throw new PiSdkConversationNormalizerError(
        "content-reference-invalid",
        "The message content reference no longer matches the session entry.",
      );
    }
    const digest = sha256(stored.bytes);
    if (!sameBytes(digest, stored.reference.sha256)) {
      throw new PiSdkConversationNormalizerError(
        "content-integrity-failed",
        "The message content failed integrity verification.",
      );
    }
    return Object.freeze({
      binding: stored.binding,
      reference: stored.reference,
      bytes: Uint8Array.from(stored.bytes),
    });
  }

  #persistentEntry(entry: SessionEntry): PiNodeConversationEntry {
    const common = {
      entryId: entry.id,
      scope: "persistent" as const,
      revision: 1,
      finalized: true,
      createdAtMs: parseTimestamp(entry.timestamp, this.#clock()),
    };
    switch (entry.type) {
      case "message":
        return this.#messageEntry(entry.message, common);
      case "custom_message":
        return this.#customEntry(
          common,
          entry.customType,
          entry.display,
          entry.content,
          entry.details,
        );
      case "compaction":
        return this.#entryWithParts(common, [{ type: "text", value: entry.summary }], {
          type: "compaction",
          firstKeptEntryId: entry.firstKeptEntryId,
          tokensBefore: nonNegativeInteger(entry.tokensBefore),
          fromHook: entry.fromHook === true,
          safeDetails: normalizeSafeValue(entry.details),
          ...(entry.usage === undefined ? {} : { metrics: normalizeMetrics(entry.usage) }),
        });
      case "branch_summary":
        return this.#entryWithParts(common, [{ type: "text", value: entry.summary }], {
          type: "branch-summary",
          fromEntryId: entry.fromId,
          fromHook: entry.fromHook === true,
          safeDetails: normalizeSafeValue(entry.details),
          ...(entry.usage === undefined ? {} : { metrics: normalizeMetrics(entry.usage) }),
        });
      case "custom":
        return this.#entryWithParts(common, [], {
          type: "custom",
          customType: boundedShortText(entry.customType, "unknown-extension"),
          display: false,
          safeDetails: normalizeSafeValue(entry.data),
        });
      case "thinking_level_change":
        return this.#entryWithParts(common, [], {
          type: "marker",
          markerKind: "thinking-level",
          thinkingLevel: boundedShortText(entry.thinkingLevel, "unknown"),
        });
      case "model_change":
        return this.#entryWithParts(common, [], {
          type: "marker",
          markerKind: "model-change",
          provider: boundedShortText(entry.provider, "unknown"),
          model: boundedShortText(entry.modelId, "unknown"),
        });
      case "label":
        return this.#entryWithParts(common, [], {
          type: "marker",
          markerKind: "label",
          targetEntryId: entry.targetId,
          ...(entry.label === undefined ? {} : { label: boundedShortText(entry.label, "Label") }),
        });
      case "session_info":
        return this.#entryWithParts(common, [], {
          type: "marker",
          markerKind: "session-info",
          ...(entry.name === undefined ? {} : { label: boundedShortText(entry.name, "Session") }),
        });
      default: {
        const sourceType =
          typeof (entry as { type?: unknown }).type === "string"
            ? (entry as { type: string }).type
            : "unknown";
        return this.#entryWithParts(common, [], {
          type: "unknown",
          sourceType: boundedShortText(sourceType, "unknown"),
        });
      }
    }
  }

  #messageEntry(
    input: unknown,
    common: {
      readonly entryId: string;
      readonly scope: "persistent" | "runtime";
      readonly originCommandId?: string | undefined;
      readonly revision: number;
      readonly finalized: boolean;
      readonly createdAtMs?: number;
    },
  ): PiNodeConversationEntry {
    const message = isRecord(input) ? input : {};
    const role = typeof message.role === "string" ? message.role : "unknown";
    const createdAtMs = finiteTimestamp(message.timestamp, common.createdAtMs ?? this.#clock());
    const base = { ...common, createdAtMs };
    switch (role) {
      case "user":
        return this.#entryWithParts(base, contentSources(message.content), { type: "user" });
      case "assistant":
        return this.#entryWithParts(base, assistantContentSources(message), {
          type: "assistant",
          provider: boundedShortText(message.provider, "unknown"),
          model: boundedShortText(message.model, "unknown"),
          stopReason: boundedShortText(message.stopReason, "unknown"),
          ...(typeof message.errorMessage === "string"
            ? { safeErrorMessage: "The provider request failed." }
            : {}),
          ...(isRecord(message.usage) ? { metrics: normalizeMetrics(message.usage) } : {}),
        });
      case "toolResult":
        return this.#entryWithParts(base, contentSources(message.content), {
          type: "tool-result",
          toolCallId: boundedShortText(message.toolCallId, "unknown-call"),
          toolName: boundedShortText(message.toolName, "unknown-tool"),
          isError: message.isError === true,
          safeDetails: normalizeSafeValue(message.details),
        });
      case "bashExecution":
        return this.#entryWithParts(base, [{ type: "text", value: stringValue(message.output) }], {
          type: "bash",
          command: boundedContentText(message.command),
          ...(Number.isSafeInteger(message.exitCode)
            ? { exitCode: message.exitCode as number }
            : {}),
          cancelled: message.cancelled === true,
          truncated: message.truncated === true,
          excludedFromContext: message.excludeFromContext === true,
        });
      case "custom":
        return this.#customEntry(
          base,
          boundedShortText(message.customType, "unknown-custom"),
          message.display === true,
          message.content,
          message.details,
        );
      case "compactionSummary":
        return this.#entryWithParts(base, [{ type: "text", value: stringValue(message.summary) }], {
          type: "compaction",
          firstKeptEntryId: "unknown-entry",
          tokensBefore: nonNegativeInteger(message.tokensBefore),
          fromHook: false,
          safeDetails: nullSafeValue,
        });
      case "branchSummary":
        return this.#entryWithParts(base, [{ type: "text", value: stringValue(message.summary) }], {
          type: "branch-summary",
          fromEntryId: boundedShortText(message.fromId, "unknown-entry"),
          fromHook: false,
          safeDetails: nullSafeValue,
        });
      default:
        return this.#entryWithParts(base, contentSources(message.content), {
          type: "unknown",
          sourceType: boundedShortText(role, "unknown"),
        });
    }
  }

  #customEntry(
    common: {
      readonly entryId: string;
      readonly scope: "persistent" | "runtime";
      readonly originCommandId?: string | undefined;
      readonly revision: number;
      readonly finalized: boolean;
      readonly createdAtMs?: number;
    },
    customType: string,
    display: boolean,
    content: unknown,
    details: unknown,
  ): PiNodeConversationEntry {
    return this.#entryWithParts(common, contentSources(content), {
      type: "custom",
      customType: boundedShortText(customType, "unknown-custom"),
      display,
      safeDetails: normalizeSafeValue(details),
    });
  }

  #entryWithParts(
    common: {
      readonly entryId: string;
      readonly scope: "persistent" | "runtime";
      readonly originCommandId?: string | undefined;
      readonly revision: number;
      readonly finalized: boolean;
      readonly createdAtMs?: number;
    },
    sources: readonly ContentSource[],
    kind: EntryKind,
  ): PiNodeConversationEntry {
    const parts = Object.freeze(
      sources
        .slice(0, MAX_PARTS)
        .map((source, index) => this.#part(source, common.entryId, common.revision, index)),
    );
    const identity = Object.freeze({
      entryId: common.entryId,
      scope: common.scope,
      ...(common.originCommandId === undefined ? {} : { originCommandId: common.originCommandId }),
    });
    return Object.freeze({
      identity,
      revision: positiveRevision(common.revision),
      createdAtMs: Math.max(1, Math.floor(common.createdAtMs ?? this.#clock())),
      finalized: common.finalized,
      parts,
      toolActivities: Object.freeze([]),
      ...kind,
    } as PiNodeConversationEntry);
  }

  #part(
    source: ContentSource,
    entryId: string,
    entryRevision: number,
    index: number,
  ): PiNodeConversationPart {
    const partId = stablePartId(entryId, index, source.type);
    const partRevision = entryRevision;
    if (source.type === "text") {
      const bytes = textEncoder.encode(source.value);
      if (bytes.length <= MAX_INLINE_TEXT_BYTES) {
        return Object.freeze({ type: "text", partId, revision: partRevision, text: source.value });
      }
      const contentReference = this.#storeContent({
        entryId,
        entryRevision,
        partId,
        partRevision,
        mimeType: "text/plain; charset=utf-8",
        displayName: "message.txt",
        bytes,
      });
      return Object.freeze({ type: "text", partId, revision: partRevision, contentReference });
    }
    if (source.type === "thinking") {
      if (source.visibility !== "visible") {
        return Object.freeze({
          type: "thinking",
          partId,
          revision: partRevision,
          visibility: source.visibility,
        });
      }
      const bytes = textEncoder.encode(source.value);
      if (bytes.length <= MAX_INLINE_TEXT_BYTES) {
        return Object.freeze({
          type: "thinking",
          partId,
          revision: partRevision,
          visibility: "visible",
          text: source.value,
        });
      }
      const contentReference = this.#storeContent({
        entryId,
        entryRevision,
        partId,
        partRevision,
        mimeType: "text/plain; charset=utf-8",
        displayName: "thinking.txt",
        bytes,
      });
      return Object.freeze({
        type: "thinking",
        partId,
        revision: partRevision,
        visibility: "visible",
        contentReference,
      });
    }
    if (source.type === "image") {
      const bytes = decodeBase64(source.data);
      if (bytes === undefined || bytes.length === 0 || bytes.length > MAX_CONTENT_BYTES) {
        return Object.freeze({
          type: "unsupported",
          partId,
          revision: partRevision,
          sourceType: "image-invalid",
        });
      }
      const mimeType = safeImageMime(source.mimeType);
      if (mimeType === undefined) {
        return Object.freeze({
          type: "unsupported",
          partId,
          revision: partRevision,
          sourceType: "image-mime-unsupported",
        });
      }
      const contentReference = this.#storeContent({
        entryId,
        entryRevision,
        partId,
        partRevision,
        mimeType,
        displayName: `image.${imageExtension(mimeType)}`,
        bytes,
      });
      return Object.freeze({ type: "image", partId, revision: partRevision, contentReference });
    }
    if (source.type === "tool-call") {
      return Object.freeze({
        type: "tool-call",
        partId,
        revision: partRevision,
        toolCallId: boundedShortText(source.toolCallId, "unknown-call"),
        toolName: boundedShortText(source.toolName, "unknown-tool"),
        safeArguments: normalizeSafeValue(source.arguments),
      });
    }
    return Object.freeze({
      type: "unsupported",
      partId,
      revision: partRevision,
      sourceType: boundedShortText(source.sourceType, "unknown"),
    });
  }

  #storeContent(input: {
    readonly entryId: string;
    readonly entryRevision: number;
    readonly partId: string;
    readonly partRevision: number;
    readonly mimeType: string;
    readonly displayName: string;
    readonly bytes: Uint8Array;
  }): PiNodeMessageContentReference {
    if (input.bytes.length === 0 || input.bytes.length > MAX_CONTENT_BYTES) {
      throw new PiSdkConversationNormalizerError(
        "content-too-large",
        "Message content exceeds the session-scoped transfer limit.",
      );
    }
    const digest = sha256(input.bytes);
    const contentId = `content-${createHash("sha256")
      .update(this.#sessionId)
      .update("\0")
      .update(input.entryId)
      .update("\0")
      .update(input.partId)
      .update("\0")
      .update(String(input.entryRevision))
      .update("\0")
      .update(String(input.partRevision))
      .update("\0")
      .update(input.mimeType)
      .update("\0")
      .update(digest)
      .digest("hex")
      .slice(0, 48)}`;
    const reference = Object.freeze({
      contentId,
      mimeType: input.mimeType,
      displayName: boundedShortText(input.displayName, "content.bin"),
      totalBytes: input.bytes.length,
      sha256: digest,
    });
    const binding = Object.freeze({
      sessionId: this.#sessionId,
      entryId: input.entryId,
      partId: input.partId,
      entryRevision: input.entryRevision,
      partRevision: input.partRevision,
      contentId,
    });
    this.#contentById.set(
      contentId,
      Object.freeze({ binding, reference, bytes: Uint8Array.from(input.bytes) }),
    );
    return reference;
  }

  #activateEntryContent(entry: PiNodeConversationEntry): void {
    const currentContentIds = new Set(
      entry.parts.flatMap((part) => {
        const reference =
          part.type === "image"
            ? part.contentReference
            : part.type === "text" || part.type === "thinking"
              ? part.contentReference
              : undefined;
        return reference === undefined ? [] : [reference.contentId];
      }),
    );
    for (const [contentId, binding] of this.#activeContentBindings) {
      if (binding.entryId === entry.identity.entryId) {
        this.#activeContentBindings.delete(contentId);
        if (!currentContentIds.has(contentId)) this.#contentById.delete(contentId);
      }
    }
    for (const part of entry.parts) {
      const reference =
        part.type === "image"
          ? part.contentReference
          : part.type === "text" || part.type === "thinking"
            ? part.contentReference
            : undefined;
      if (reference === undefined) continue;
      const stored = this.#contentById.get(reference.contentId);
      if (stored === undefined) continue;
      const binding = Object.freeze({
        sessionId: this.#sessionId,
        entryId: entry.identity.entryId,
        partId: part.partId,
        entryRevision: entry.revision,
        partRevision: part.revision,
        contentId: reference.contentId,
      });
      this.#contentById.set(reference.contentId, Object.freeze({ ...stored, binding }));
      this.#activeContentBindings.set(reference.contentId, binding);
    }
  }

  #toolActivityEvent(
    toolCallId: string,
    toolName: string,
    status: PiNodeToolActivity["status"],
    details: unknown,
  ): readonly PiNodeConversationBackendEvent[] {
    const owner = [...this.#runtimeEntries.values()]
      .reverse()
      .find(
        (entry) =>
          entry.type === "assistant" &&
          entry.parts.some((part) => part.type === "tool-call" && part.toolCallId === toolCallId),
      );
    if (owner === undefined) return Object.freeze([]);
    const sourceOrdinal = owner.parts.findIndex(
      (part) => part.type === "tool-call" && part.toolCallId === toolCallId,
    );
    const previousActivity = this.#toolActivityByCallId.get(toolCallId);
    const activity = Object.freeze({
      activityId:
        previousActivity?.activityId ?? stableActivityId(owner.identity.entryId, toolCallId),
      toolCallId: boundedShortText(toolCallId, "unknown-call"),
      toolName: boundedShortText(toolName, "unknown-tool"),
      sourceOrdinal: Math.max(0, sourceOrdinal),
      revision: (previousActivity?.revision ?? 0) + 1,
      status,
      safeDetails: normalizeSafeValue(details),
    }) satisfies PiNodeToolActivity;
    this.#toolActivityByCallId.set(toolCallId, activity);
    const resultingEntryRevision = owner.revision + 1;
    const updated = Object.freeze({
      ...owner,
      revision: resultingEntryRevision,
      toolActivities: Object.freeze(
        [
          ...owner.toolActivities.filter((candidate) => candidate.toolCallId !== toolCallId),
          activity,
        ].sort((left, right) => left.sourceOrdinal - right.sourceOrdinal),
      ),
    }) as PiNodeConversationEntry;
    this.#activateEntryContent(updated);
    this.#runtimeEntries.set(owner.identity.entryId, updated);
    return Object.freeze([
      Object.freeze({
        type: "tool-activity",
        entryId: owner.identity.entryId,
        expectedEntryRevision: owner.revision,
        resultingEntryRevision,
        activity,
      }),
    ]);
  }
}

export type PiSdkConversationNormalizerErrorCode =
  | "content-reference-invalid"
  | "content-integrity-failed"
  | "content-too-large";

export class PiSdkConversationNormalizerError extends Error {
  constructor(
    readonly code: PiSdkConversationNormalizerErrorCode,
    message: string,
  ) {
    super(message);
    this.name = "PiSdkConversationNormalizerError";
  }
}

type EntryKind = PiNodeConversationEntry extends infer Entry
  ? Entry extends PiNodeConversationEntry
    ? Omit<
        Entry,
        "identity" | "revision" | "createdAtMs" | "finalized" | "parts" | "toolActivities"
      >
    : never
  : never;

type ContentSource =
  | { readonly type: "text"; readonly value: string }
  | {
      readonly type: "thinking";
      readonly visibility: "visible" | "redacted" | "deferred";
      readonly value: string;
    }
  | { readonly type: "image"; readonly mimeType: string; readonly data: string }
  | {
      readonly type: "tool-call";
      readonly toolCallId: string;
      readonly toolName: string;
      readonly arguments: unknown;
    }
  | { readonly type: "unsupported"; readonly sourceType: string };

const nullSafeValue = Object.freeze({ kind: "null" as const });
const redactedSafeValue = Object.freeze({ kind: "redacted" as const });

export function normalizeSafeValue(value: unknown): PiNodeSafeValue {
  const budget = { bytes: 0 };
  const seen = new WeakSet<object>();
  return normalizeSafeValueInner(value, 0, budget, seen);
}

function normalizeSafeValueInner(
  value: unknown,
  depth: number,
  budget: { bytes: number },
  seen: WeakSet<object>,
): PiNodeSafeValue {
  if (budget.bytes >= MAX_SAFE_TOTAL_BYTES || depth >= MAX_SAFE_DEPTH) {
    return redactedSafeValue;
  }
  if (value === null || value === undefined) return nullSafeValue;
  if (typeof value === "boolean") return Object.freeze({ kind: "bool", value });
  if (typeof value === "number") {
    if (!Number.isFinite(value)) return redactedSafeValue;
    return Number.isSafeInteger(value)
      ? Object.freeze({ kind: "int", value })
      : Object.freeze({ kind: "double", value });
  }
  if (typeof value === "string") {
    const text = boundedUtf8(value.replaceAll("\u0000", ""), MAX_SAFE_STRING_BYTES);
    budget.bytes += textEncoder.encode(text).length;
    return Object.freeze({ kind: "string", value: text });
  }
  if (typeof value !== "object") return redactedSafeValue;
  if (seen.has(value)) return redactedSafeValue;
  seen.add(value);
  try {
    if (Array.isArray(value)) {
      return Object.freeze({
        kind: "list",
        values: Object.freeze(
          value
            .slice(0, MAX_SAFE_ITEMS)
            .map((item) => normalizeSafeValueInner(item, depth + 1, budget, seen)),
        ),
      });
    }
    const fields = Object.keys(value)
      .sort()
      .slice(0, MAX_SAFE_ITEMS)
      .map((rawKey) => {
        const key = boundedUtf8(rawKey.replaceAll("\u0000", ""), MAX_SAFE_KEY_BYTES);
        budget.bytes += textEncoder.encode(key).length;
        return Object.freeze({
          key,
          value: redactedKey.test(key)
            ? redactedSafeValue
            : normalizeSafeValueInner(
                (value as Record<string, unknown>)[rawKey],
                depth + 1,
                budget,
                seen,
              ),
        });
      });
    return Object.freeze({ kind: "object", fields: Object.freeze(fields) });
  } finally {
    seen.delete(value);
  }
}

function assistantContentSources(message: Record<string, unknown>): readonly ContentSource[] {
  const sources = [...contentSources(message.content)];
  if (
    (message.stopReason === "deferred" || isRecord(message.deferred)) &&
    !sources.some((source) => source.type === "thinking" && source.visibility === "deferred")
  ) {
    sources.push({ type: "thinking", visibility: "deferred", value: "" });
  }
  return Object.freeze(sources);
}

function contentSources(content: unknown): readonly ContentSource[] {
  if (typeof content === "string") return Object.freeze([{ type: "text", value: content }]);
  if (!Array.isArray(content)) return Object.freeze([]);
  return Object.freeze(
    content.slice(0, MAX_PARTS).map((part): ContentSource => {
      if (!isRecord(part) || typeof part.type !== "string") {
        return { type: "unsupported", sourceType: "unknown" };
      }
      if (part.type === "text" && typeof part.text === "string") {
        return { type: "text", value: part.text };
      }
      if (part.type === "thinking") {
        if (part.redacted === true) {
          return { type: "thinking", visibility: "redacted", value: "" };
        }
        if (part.deferred === true || typeof part.thinking !== "string") {
          return { type: "thinking", visibility: "deferred", value: "" };
        }
        return { type: "thinking", visibility: "visible", value: part.thinking };
      }
      if (
        part.type === "image" &&
        typeof part.mimeType === "string" &&
        typeof part.data === "string"
      ) {
        return { type: "image", mimeType: part.mimeType, data: part.data };
      }
      if (part.type === "toolCall") {
        return {
          type: "tool-call",
          toolCallId: stringValue(part.id),
          toolName: stringValue(part.name),
          arguments: part.arguments,
        };
      }
      return { type: "unsupported", sourceType: part.type };
    }),
  );
}

function assistantTextDelta(
  event: Extract<AgentSessionEvent, { type: "message_update" }>,
  previous: PiNodeConversationEntry,
  candidate: PiNodeConversationEntry,
):
  | {
      readonly previousPart: PiNodeConversationPart;
      readonly nextPart: PiNodeConversationPart;
      readonly delta: string;
    }
  | undefined {
  const update = event.assistantMessageEvent;
  if (update.type !== "text_delta" && update.type !== "thinking_delta") return undefined;
  const index = update.contentIndex;
  if (!Number.isSafeInteger(index) || index < 0) return undefined;
  const previousPart = previous.parts[index];
  const nextPart = candidate.parts[index];
  if (previousPart === undefined || nextPart === undefined) return undefined;
  if (update.type === "text_delta" && previousPart.type === "text" && nextPart.type === "text") {
    return typeof update.delta === "string" && update.delta.length > 0
      ? { previousPart, nextPart, delta: update.delta }
      : undefined;
  }
  if (
    update.type === "thinking_delta" &&
    previousPart.type === "thinking" &&
    nextPart.type === "thinking" &&
    previousPart.visibility === "visible" &&
    nextPart.visibility === "visible"
  ) {
    return typeof update.delta === "string" && update.delta.length > 0
      ? { previousPart, nextPart, delta: update.delta }
      : undefined;
  }
  return undefined;
}

function normalizeMetrics(input: unknown): PiNodeConversationMetrics {
  const usage = isRecord(input) ? input : {};
  const cost = isRecord(usage.cost) ? usage.cost : {};
  return Object.freeze({
    usage: Object.freeze({
      inputTokens: nonNegativeInteger(usage.input),
      outputTokens: nonNegativeInteger(usage.output),
      cacheReadTokens: nonNegativeInteger(usage.cacheRead),
      cacheWriteTokens: nonNegativeInteger(usage.cacheWrite),
      totalTokens: nonNegativeInteger(usage.totalTokens),
    }),
    cost: Object.freeze({
      currencyCode: "USD",
      decimalAmount: canonicalDecimal(cost.total),
    }),
  });
}

function sameMetrics(
  left: PiNodeConversationMetrics | undefined,
  right: PiNodeConversationMetrics | undefined,
): boolean {
  return JSON.stringify(left) === JSON.stringify(right);
}

function sameBinding(
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

function sameBytes(left: Uint8Array, right: Uint8Array): boolean {
  if (left.length !== right.length) return false;
  let difference = 0;
  for (let index = 0; index < left.length; index += 1) difference |= left[index]! ^ right[index]!;
  return difference === 0;
}

function sha256(bytes: Uint8Array): Uint8Array {
  return new Uint8Array(createHash("sha256").update(bytes).digest());
}

function decodeBase64(value: string): Uint8Array | undefined {
  if (value.length > Math.ceil((MAX_CONTENT_BYTES * 4) / 3) + 8) return undefined;
  try {
    const buffer = Buffer.from(value, "base64");
    if (buffer.length === 0 && value.length > 0) return undefined;
    return new Uint8Array(buffer);
  } catch {
    return undefined;
  }
}

function safeImageMime(value: string): string | undefined {
  const normalized = value.trim().toLowerCase();
  return /^(?:image\/(?:png|jpeg|gif|webp))$/u.test(normalized) ? normalized : undefined;
}

function imageExtension(mimeType: string): string {
  return mimeType === "image/jpeg" ? "jpg" : mimeType.slice("image/".length);
}

function stablePartId(entryId: string, index: number, sourceType: string): string {
  return `part-${createHash("sha256").update(`${entryId}\u0000${index}\u0000${sourceType}`).digest("hex").slice(0, 32)}`;
}

function stableActivityId(entryId: string, toolCallId: string): string {
  return `activity-${createHash("sha256").update(`${entryId}\u0000${toolCallId}`).digest("hex").slice(0, 32)}`;
}

function boundedRuntimeId(sessionId: string, ordinal: number): string {
  return `runtime-${createHash("sha256").update(`${sessionId}\u0000${ordinal}`).digest("hex").slice(0, 32)}`;
}

function boundedShortText(value: unknown, fallback: string): string {
  const text = typeof value === "string" ? value.replaceAll("\u0000", "").trim() : "";
  return boundedUtf8(text.length === 0 ? fallback : text, MAX_SHORT_TEXT_BYTES);
}

function boundedContentText(value: unknown): string {
  return boundedUtf8(
    typeof value === "string" ? value.replaceAll("\u0000", "") : "",
    MAX_INLINE_TEXT_BYTES,
  );
}

function boundedUtf8(value: string, maxBytes: number): string {
  if (textEncoder.encode(value).length <= maxBytes) return value;
  let result = "";
  for (const character of value) {
    if (textEncoder.encode(result + character).length > maxBytes) break;
    result += character;
  }
  return result;
}

function finiteTimestamp(value: unknown, fallback: number): number {
  return typeof value === "number" && Number.isFinite(value)
    ? Math.max(1, Math.floor(value))
    : Math.max(1, Math.floor(fallback));
}

function parseTimestamp(value: unknown, fallback: number): number {
  if (typeof value !== "string") return Math.max(1, Math.floor(fallback));
  const parsed = Date.parse(value);
  return Number.isFinite(parsed)
    ? Math.max(1, Math.floor(parsed))
    : Math.max(1, Math.floor(fallback));
}

function nonNegativeInteger(value: unknown): number {
  return typeof value === "number" && Number.isSafeInteger(value) && value >= 0 ? value : 0;
}

function positiveRevision(value: number): number {
  return Number.isSafeInteger(value) && value > 0 ? value : 1;
}

function canonicalDecimal(value: unknown): string {
  return typeof value === "number" && Number.isFinite(value) && value >= 0 ? value.toString() : "0";
}

function stringValue(value: unknown): string {
  return typeof value === "string" ? value : "";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
