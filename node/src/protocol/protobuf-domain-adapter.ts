import { create } from "@bufbuild/protobuf";
import {
  ErrorCode,
  MAX_CONTENT_TEXT_BYTES,
  MAX_IDENTIFIER_BYTES,
  MAX_PATH_BYTES,
  MAX_SHORT_TEXT_BYTES,
  MessageRole,
  MessageSnapshotSchema,
  SessionDetailSnapshotSchema,
  SessionSummarySnapshotSchema,
  StableErrorSchema,
  type MessageSnapshot,
  type SessionDetailSnapshot,
  type SessionSummarySnapshot,
  type StableError,
} from "@pi-client/protocol";

import {
  PiNodeDomainError,
  type PiNodeCommandFailure,
  type PiNodeMessage,
  type PiNodeSessionSnapshot,
  type PiNodeSessionSummary,
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
  });
}

export function toProtocolSessionDetail(snapshot: PiNodeSessionSnapshot): SessionDetailSnapshot {
  return create(SessionDetailSnapshotSchema, {
    summary: toProtocolSessionSummary(snapshot),
    messages: snapshot.messages.map((message) => toProtocolMessageSnapshot(message, false)),
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
      return stableError(ErrorCode.INVALID_REQUEST, "The working directory is invalid.");
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
    case "service-disposed":
      return stableError(ErrorCode.UNAVAILABLE, "The Pi Node service is unavailable.", true);
    case "project-trust-resolution-failed":
    case "session-list-failed":
    case "session-create-failed":
    case "session-load-failed":
    case "session-dispose-failed":
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
