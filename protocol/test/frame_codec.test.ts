import { create } from "@bufbuild/protobuf";
import { describe, expect, test } from "bun:test";
import {
  ConversationIdentityScope,
  PiTransportFrameSchema,
  SafeValueKind,
  ThinkingVisibility,
  ToolActivityStatus,
  TransferDirection,
  TransferPurpose,
  type PiTransportFrame,
} from "../gen/ts/pi/client/protocol/v0/protocol_pb.ts";
import {
  decodeTransportFrame,
  encodeTransportFrame,
  FrameValidationError,
} from "../src/frame_codec.ts";
import { MAX_SAFE_VALUE_ITEMS } from "../src/limits.ts";

describe("rich conversation frame codec", () => {
  test("round-trips a sealed conversation snapshot", () => {
    const decoded = decodeTransportFrame(encodeTransportFrame(sessionFrame()));
    expect(decoded.operation.case).toBe("getSessionResponse");
    if (decoded.operation.case !== "getSessionResponse") throw new Error("wrong operation");
    const conversation = decoded.operation.value.session?.conversation;
    expect(conversation?.sessionId).toBe("session-1");
    expect(conversation?.lastEventSequence).toBe(7n);
    expect(conversation?.entries[0]?.kind.case).toBe("assistant");
    expect(conversation?.entries[0]?.parts.map((part) => part.kind.case)).toEqual([
      "text",
      "thinking",
    ]);
  });

  test("accepts exact message content requests and bound downloads", () => {
    const request = create(PiTransportFrameSchema, {
      frameSequence: 2n,
      operation: {
        case: "getMessageContentRequest",
        value: {
          requestId: 2n,
          projectId: "project-1",
          binding: binding(),
          expectedMimeType: "image/png",
          expectedTotalBytes: 4n,
          expectedSha256: new Uint8Array(32),
        },
      },
    });
    expect(() => encodeTransportFrame(request)).not.toThrow();

    const transfer = create(PiTransportFrameSchema, {
      frameSequence: 3n,
      operation: {
        case: "transferOpen",
        value: {
          requestId: 2n,
          transferId: "transfer-1",
          direction: TransferDirection.DOWNLOAD,
          purpose: TransferPurpose.MESSAGE_CONTENT,
          contentType: "image/png",
          fileName: "image.png",
          totalBytes: 4n,
          chunkBytes: 4,
          sha256: new Uint8Array(32),
          messageContentBinding: binding(),
        },
      },
    });
    expect(() => encodeTransportFrame(transfer)).not.toThrow();
  });

  test("rejects unbound message content downloads", () => {
    const frame = create(PiTransportFrameSchema, {
      frameSequence: 4n,
      operation: {
        case: "transferOpen",
        value: {
          requestId: 2n,
          transferId: "transfer-1",
          direction: TransferDirection.DOWNLOAD,
          purpose: TransferPurpose.MESSAGE_CONTENT,
          contentType: "image/png",
          fileName: "image.png",
          totalBytes: 4n,
          chunkBytes: 4,
          sha256: new Uint8Array(32),
        },
      },
    });
    expect(() => encodeTransportFrame(frame)).toThrow(FrameValidationError);
  });

  test("rejects plaintext on redacted thinking", () => {
    const frame = sessionFrame();
    if (frame.operation.case !== "getSessionResponse") throw new Error("wrong operation");
    const entry = frame.operation.value.session!.conversation!.entries[0]!;
    entry.parts[1]!.kind = {
      case: "thinking",
      value: {
        visibility: ThinkingVisibility.REDACTED,
        content: { case: "inlineText", value: "must not cross the boundary" },
      } as never,
    };
    expect(() => encodeTransportFrame(frame)).toThrow(FrameValidationError);
  });

  test("rejects event revision gaps", () => {
    const frame = create(PiTransportFrameSchema, {
      frameSequence: 6n,
      operation: {
        case: "sessionEventStream",
        value: {
          streamId: "stream-1",
          sessionId: "session-1",
          eventSequence: 8n,
          event: {
            case: "partDelta",
            value: {
              entryId: "entry-1",
              expectedEntryRevision: 2n,
              resultingEntryRevision: 4n,
              partId: "part-text",
              expectedPartRevision: 2n,
              resultingPartRevision: 3n,
              textDelta: "next",
            },
          },
        },
      },
    });
    expect(() => encodeTransportFrame(frame)).toThrow(FrameValidationError);
  });

  test("rejects safe values beyond item limits", () => {
    const frame = sessionFrame();
    if (frame.operation.case !== "getSessionResponse") throw new Error("wrong operation");
    const entry = frame.operation.value.session!.conversation!.entries[0]!;
    entry.parts.push({
      $typeName: "pi.client.protocol.v0.ConversationPart",
      partId: "part-tool",
      revision: 1n,
      kind: {
        case: "toolCall",
        value: {
          $typeName: "pi.client.protocol.v0.ToolCallPart",
          toolCallId: "call-1",
          toolName: "bounded-tool",
          safeArguments: {
            $typeName: "pi.client.protocol.v0.SafeValue",
            value: {
              case: "listValue",
              value: {
                $typeName: "pi.client.protocol.v0.SafeList",
                values: Array.from({ length: MAX_SAFE_VALUE_ITEMS + 1 }, () => ({
                  $typeName: "pi.client.protocol.v0.SafeValue" as const,
                  value: { case: "sentinel" as const, value: SafeValueKind.NULL },
                })),
              },
            },
          },
        },
      },
    });
    expect(() => encodeTransportFrame(frame)).toThrow(FrameValidationError);
  });

  test("accepts ordered tool activity and exact metrics", () => {
    const frame = sessionFrame();
    if (frame.operation.case !== "getSessionResponse") throw new Error("wrong operation");
    const entry = frame.operation.value.session!.conversation!.entries[0]!;
    entry.toolActivities.push(
      {
        $typeName: "pi.client.protocol.v0.ToolActivity",
        activityId: "activity-1",
        toolCallId: "call-1",
        toolName: "tool-1",
        sourceOrdinal: 0,
        revision: 1n,
        status: ToolActivityStatus.RUNNING,
        safeDetails: {
          $typeName: "pi.client.protocol.v0.SafeValue",
          value: { case: "sentinel", value: SafeValueKind.NULL },
        },
      },
      {
        $typeName: "pi.client.protocol.v0.ToolActivity",
        activityId: "activity-2",
        toolCallId: "call-2",
        toolName: "tool-2",
        sourceOrdinal: 1,
        revision: 1n,
        status: ToolActivityStatus.RUNNING,
        safeDetails: {
          $typeName: "pi.client.protocol.v0.SafeValue",
          value: { case: "sentinel", value: SafeValueKind.NULL },
        },
      },
    );
    entry.metrics = {
      $typeName: "pi.client.protocol.v0.ConversationMetrics",
      usage: {
        $typeName: "pi.client.protocol.v0.UsageMetrics",
        inputTokens: 11n,
        outputTokens: 7n,
        cacheReadTokens: 3n,
        cacheWriteTokens: 2n,
        totalTokens: 23n,
      },
      cost: {
        $typeName: "pi.client.protocol.v0.MoneyAmount",
        currencyCode: "USD",
        decimalAmount: "0.00125",
      },
      context: {
        $typeName: "pi.client.protocol.v0.ContextMetrics",
        tokens: 23n,
        contextWindow: 200_000n,
        percentDecimal: "0.0115",
      },
    };
    expect(() => encodeTransportFrame(frame)).not.toThrow();
  });
});

function sessionFrame(): PiTransportFrame {
  return create(PiTransportFrameSchema, {
    frameSequence: 1n,
    operation: {
      case: "getSessionResponse",
      value: {
        requestId: 1n,
        session: {
          summary: {
            sessionId: "session-1",
            title: "Rich conversation",
            workingDirectory: "/tmp/project",
            createdAtUnixMillis: 1n,
            updatedAtUnixMillis: 2n,
            adminRevision: "admin-revision-1",
          },
          conversation: {
            sessionId: "session-1",
            lastEventSequence: 7n,
            entries: [
              {
                identity: {
                  entryId: "entry-1",
                  scope: ConversationIdentityScope.RUNTIME,
                  originCommandId: "command-1",
                },
                revision: 2n,
                createdAtUnixMillis: 3n,
                finalized: false,
                parts: [
                  {
                    partId: "part-text",
                    revision: 2n,
                    kind: {
                      case: "text",
                      value: {
                        content: { case: "inlineText", value: "Hello" },
                      },
                    },
                  },
                  {
                    partId: "part-thinking",
                    revision: 1n,
                    kind: {
                      case: "thinking",
                      value: {
                        visibility: ThinkingVisibility.DEFERRED,
                        content: { case: undefined },
                      },
                    },
                  },
                ],
                kind: {
                  case: "assistant",
                  value: {
                    provider: "provider",
                    model: "model",
                    stopReason: "streaming",
                  },
                },
              },
            ],
          },
        },
      },
    },
  });
}

function binding() {
  return {
    sessionId: "session-1",
    entryId: "entry-1",
    partId: "part-image",
    entryRevision: 2n,
    partRevision: 1n,
    contentId: "content-1",
  };
}
