import assert from "node:assert/strict";
import test from "node:test";

import type { AgentSessionEvent, SessionEntry } from "@earendil-works/pi-coding-agent";

import {
  PiSdkConversationNormalizer,
  PiSdkConversationNormalizerError,
  normalizeSafeValue,
} from "../src/pi-sdk-conversation-normalizer.js";

test("normalizes every persistent semantic entry without exposing SDK objects", () => {
  const normalizer = new PiSdkConversationNormalizer("session-1", () => 1000);
  const entries = normalizer.persistentEntries([
    {
      type: "message",
      id: "user-1",
      timestamp: "2025-01-01T00:00:00.000Z",
      message: { role: "user", content: "Hello", timestamp: 1 },
    },
    {
      type: "message",
      id: "assistant-1",
      timestamp: "2025-01-01T00:00:01.000Z",
      message: {
        role: "assistant",
        content: [
          { type: "text", text: "Answer" },
          { type: "thinking", thinking: "visible reasoning" },
          { type: "thinking", thinking: "private reasoning", redacted: true },
          { type: "thinking", deferred: true },
          { type: "toolCall", id: "call-1", name: "search", arguments: { query: "x" } },
          { type: "futurePart", private: "not exposed" },
        ],
        provider: "provider",
        model: "model",
        stopReason: "stop",
        timestamp: 2,
      },
    },
    {
      type: "custom_message",
      id: "custom-message-1",
      timestamp: "2025-01-01T00:00:02.000Z",
      customType: "notice",
      display: true,
      content: "Custom",
      details: { token: "secret", safe: "visible" },
    },
    {
      type: "compaction",
      id: "compaction-1",
      timestamp: "2025-01-01T00:00:03.000Z",
      summary: "Compacted",
      firstKeptEntryId: "assistant-1",
      tokensBefore: 42,
    },
    {
      type: "branch_summary",
      id: "branch-1",
      timestamp: "2025-01-01T00:00:04.000Z",
      summary: "Branch",
      fromId: "assistant-1",
    },
    {
      type: "thinking_level_change",
      id: "thinking-level-1",
      timestamp: "2025-01-01T00:00:05.000Z",
      thinkingLevel: "high",
    },
    {
      type: "model_change",
      id: "model-change-1",
      timestamp: "2025-01-01T00:00:06.000Z",
      provider: "provider-2",
      modelId: "model-2",
    },
    {
      type: "label",
      id: "label-1",
      timestamp: "2025-01-01T00:00:07.000Z",
      targetId: "assistant-1",
      label: "checkpoint",
    },
    {
      type: "session_info",
      id: "session-info-1",
      timestamp: "2025-01-01T00:00:08.000Z",
      name: "Named session",
    },
    {
      type: "future_entry",
      id: "unknown-1",
      timestamp: "2025-01-01T00:00:09.000Z",
      secret: "must not escape",
    },
  ] as unknown as readonly SessionEntry[]);

  assert.deepEqual(
    entries.map((entry) => entry.type),
    [
      "user",
      "assistant",
      "custom",
      "compaction",
      "branch-summary",
      "marker",
      "marker",
      "marker",
      "marker",
      "unknown",
    ],
  );
  const assistant = entries[1]!;
  assert.equal(assistant.type, "assistant");
  assert.deepEqual(
    assistant.parts.map((part) => part.type),
    ["text", "thinking", "thinking", "thinking", "tool-call", "unsupported"],
  );
  const thinking = assistant.parts.filter((part) => part.type === "thinking");
  assert.deepEqual(
    thinking.map((part) => (part.type === "thinking" ? part.visibility : "")),
    ["visible", "redacted", "deferred"],
  );
  assert.equal("text" in thinking[1]!, false);
  assert.equal("text" in thinking[2]!, false);
  assert.equal(JSON.stringify(entries).includes("private reasoning"), false);
  assert.equal(JSON.stringify(entries).includes("must not escape"), false);
});

test("projects public deferred responses without exposing provider handles", () => {
  const normalizer = new PiSdkConversationNormalizer("session-deferred", () => 1500);
  const entry = normalizer.persistentEntries([
    {
      type: "message",
      id: "assistant-deferred",
      timestamp: "2025-01-01T00:00:00.000Z",
      message: {
        role: "assistant",
        content: [],
        api: "provider-api",
        provider: "provider",
        model: "model",
        usage: {
          input: 1,
          output: 0,
          cacheRead: 0,
          cacheWrite: 0,
          totalTokens: 1,
          cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
        },
        stopReason: "deferred",
        deferred: {
          provider: "provider",
          modelId: "private-model-id",
          api: "provider-api",
          id: "private-provider-handle",
        },
        timestamp: 1,
      },
    },
  ] as unknown as readonly SessionEntry[])[0]!;

  assert.equal(entry.type, "assistant");
  assert.equal(entry.parts.length, 1);
  assert.equal(entry.parts[0]?.type, "thinking");
  if (entry.parts[0]?.type !== "thinking") throw new Error("wrong deferred part");
  assert.equal(entry.parts[0].visibility, "deferred");
  assert.equal("text" in entry.parts[0], false);
  assert.equal(JSON.stringify(entry).includes("private-provider-handle"), false);
  assert.equal(JSON.stringify(entry).includes("private-model-id"), false);
});

test("normalizes safe values with secret, cycle, item, depth, and byte bounds", () => {
  const cyclic: Record<string, unknown> = { safe: "visible", apiToken: "secret" };
  cyclic.self = cyclic;
  cyclic.items = Array.from({ length: 100 }, (_, index) => index);
  let deep: Record<string, unknown> = cyclic;
  for (let index = 0; index < 12; index += 1) deep = { next: deep };

  const value = normalizeSafeValue(deep);
  const serialized = JSON.stringify(value);
  assert.equal(serialized.includes("secret"), false);
  assert.equal(serialized.includes("visible"), false, "depth exhaustion must redact nested data");
  assert.ok(serialized.length < 70_000);

  const top = normalizeSafeValue(cyclic);
  assert.equal(top.kind, "object");
  if (top.kind !== "object") throw new Error("wrong safe value kind");
  const token = top.fields.find((field) => field.key === "apiToken");
  const self = top.fields.find((field) => field.key === "self");
  const items = top.fields.find((field) => field.key === "items");
  assert.equal(token?.value.kind, "redacted");
  assert.equal(self?.value.kind, "redacted");
  assert.equal(items?.value.kind, "list");
  if (items?.value.kind === "list") assert.equal(items.value.values.length, 64);
});

test("uses revision-aware runtime events and retains origin command identity", () => {
  const normalizer = new PiSdkConversationNormalizer("session-runtime", () => 2000);
  const message = assistantMessage("A");
  const start = normalizer.acceptEvent(
    { type: "message_start", message } as AgentSessionEvent,
    "command-1",
  );
  assert.equal(start[0]?.type, "entry-upsert");
  if (start[0]?.type !== "entry-upsert") throw new Error("wrong start event");
  assert.equal(start[0].entry.identity.originCommandId, "command-1");
  assert.equal(start[0].entry.revision, 1);

  message.content[0]!.text = "AB";
  const update = normalizer.acceptEvent(
    {
      type: "message_update",
      message,
      assistantMessageEvent: { type: "text_delta", contentIndex: 0, delta: "B" },
    } as AgentSessionEvent,
    "command-1",
  );
  assert.equal(update[0]?.type, "part-delta");
  if (update[0]?.type !== "part-delta") throw new Error("wrong update event");
  assert.equal(update[0].expectedEntryRevision, 1);
  assert.equal(update[0].resultingEntryRevision, 2);
  assert.equal(update[0].expectedPartRevision, 1);
  assert.equal(update[0].resultingPartRevision, 2);

  const end = normalizer.acceptEvent(
    { type: "message_end", message } as AgentSessionEvent,
    "command-1",
  );
  assert.equal(end[0]?.type, "entry-finalized");
  if (end[0]?.type !== "entry-finalized") throw new Error("wrong end event");
  assert.equal(end[0].expectedPreviousRevision, 2);
  assert.equal(end[0].entry.revision, 3);
  assert.equal(end[0].entry.finalized, true);
});

test("keeps parallel tool activity identity and source ordinal ordering", () => {
  const normalizer = new PiSdkConversationNormalizer("session-tools", () => 3000);
  const message = {
    role: "assistant",
    content: [
      { type: "toolCall", id: "call-1", name: "first", arguments: {} },
      { type: "toolCall", id: "call-2", name: "second", arguments: {} },
    ],
    provider: "provider",
    model: "model",
    stopReason: "toolUse",
    timestamp: 3,
  };
  normalizer.acceptEvent({ type: "message_start", message } as AgentSessionEvent, "command-2");

  const second = normalizer.acceptEvent(
    {
      type: "tool_execution_start",
      toolCallId: "call-2",
      toolName: "second",
      args: {},
    } as AgentSessionEvent,
    "command-2",
  );
  const first = normalizer.acceptEvent(
    {
      type: "tool_execution_start",
      toolCallId: "call-1",
      toolName: "first",
      args: {},
    } as AgentSessionEvent,
    "command-2",
  );
  const secondUpdate = normalizer.acceptEvent(
    {
      type: "tool_execution_end",
      toolCallId: "call-2",
      toolName: "second",
      result: { password: "secret", ok: true },
      isError: false,
    } as AgentSessionEvent,
    "command-2",
  );

  assert.equal(second[0]?.type, "tool-activity");
  assert.equal(first[0]?.type, "tool-activity");
  assert.equal(secondUpdate[0]?.type, "tool-activity");
  if (
    second[0]?.type !== "tool-activity" ||
    first[0]?.type !== "tool-activity" ||
    secondUpdate[0]?.type !== "tool-activity"
  )
    throw new Error("wrong tool event");
  assert.equal(second[0].activity.sourceOrdinal, 1);
  assert.equal(first[0].activity.sourceOrdinal, 0);
  assert.equal(secondUpdate[0].activity.activityId, second[0].activity.activityId);
  assert.equal(secondUpdate[0].activity.revision, 2);
  assert.equal(JSON.stringify(secondUpdate[0].activity).includes("secret"), false);
});

test("stores large text and supported images behind exact session-scoped bindings", () => {
  const normalizer = new PiSdkConversationNormalizer("session-content", () => 4000);
  const imageBytes = Uint8Array.from([137, 80, 78, 71]);
  const entries = normalizer.persistentEntries([
    {
      type: "message",
      id: "content-entry",
      timestamp: "2025-01-01T00:00:00.000Z",
      message: {
        role: "user",
        content: [
          { type: "text", text: "x".repeat(64 * 1024 + 1) },
          {
            type: "image",
            mimeType: "image/png",
            data: Buffer.from(imageBytes).toString("base64"),
          },
          { type: "image", mimeType: "text/html", data: Buffer.from("unsafe").toString("base64") },
        ],
        timestamp: 4,
      },
    },
  ] as unknown as readonly SessionEntry[]);
  const entry = entries[0]!;
  const text = entry.parts[0]!;
  const image = entry.parts[1]!;
  const rejectedImage = entry.parts[2]!;
  assert.equal(text.type, "text");
  assert.equal(image.type, "image");
  assert.equal(rejectedImage.type, "unsupported");
  if (text.type !== "text" || !text.contentReference) throw new Error("missing text reference");
  if (image.type !== "image") throw new Error("missing image reference");

  const binding = {
    sessionId: "session-content",
    entryId: entry.identity.entryId,
    partId: text.partId,
    entryRevision: entry.revision,
    partRevision: text.revision,
    contentId: text.contentReference.contentId,
  };
  const content = normalizer.getContent({
    binding,
    expectedMimeType: text.contentReference.mimeType,
    expectedTotalBytes: text.contentReference.totalBytes,
    expectedSha256: text.contentReference.sha256,
  });
  assert.equal(new TextDecoder().decode(content.bytes), "x".repeat(64 * 1024 + 1));

  assert.throws(
    () =>
      normalizer.getContent({
        binding: { ...binding, partRevision: binding.partRevision + 1 },
        expectedMimeType: text.contentReference!.mimeType,
        expectedTotalBytes: text.contentReference!.totalBytes,
        expectedSha256: text.contentReference!.sha256,
      }),
    (error) =>
      error instanceof PiSdkConversationNormalizerError &&
      error.code === "content-reference-invalid",
  );
  assert.throws(
    () =>
      normalizer.getContent({
        binding,
        expectedMimeType: text.contentReference!.mimeType,
        expectedTotalBytes: text.contentReference!.totalBytes,
        expectedSha256: new Uint8Array(32),
      }),
    (error) =>
      error instanceof PiSdkConversationNormalizerError &&
      error.code === "content-reference-invalid",
  );

  normalizer.persistentEntries([
    {
      type: "message",
      id: "content-entry",
      timestamp: "2025-01-01T00:00:01.000Z",
      message: {
        role: "user",
        content: [{ type: "text", text: "y".repeat(64 * 1024 + 1) }],
        timestamp: 5,
      },
    },
  ] as unknown as readonly SessionEntry[]);
  assert.throws(
    () =>
      normalizer.getContent({
        binding,
        expectedMimeType: text.contentReference!.mimeType,
        expectedTotalBytes: text.contentReference!.totalBytes,
        expectedSha256: text.contentReference!.sha256,
      }),
    (error) =>
      error instanceof PiSdkConversationNormalizerError &&
      error.code === "content-reference-invalid",
  );
});

function assistantMessage(text: string) {
  return {
    role: "assistant",
    content: [{ type: "text", text }],
    provider: "provider",
    model: "model",
    stopReason: "streaming",
    timestamp: 2,
  };
}
