import {
  create,
  toBinary,
  type MessageInitShape,
} from "@bufbuild/protobuf";
import { describe, expect, test } from "bun:test";
import {
  Capability,
  ErrorCode,
  HealthStatus,
  MessageRole,
  PiTransportFrameSchema,
  ProtocolVersionSchema,
  SessionAdminOperation,
  SessionDetailSnapshotSchema,
  SessionSummarySnapshotSchema,
  StableErrorSchema,
  TransferDirection,
  TransferPurpose,
  type PiTransportFrame,
} from "../gen/ts/pi/client/protocol/v0/protocol_pb.ts";
import {
  decodeTransportFrame,
  encodeTransportFrame,
  FrameValidationError,
} from "../src/frame_codec.ts";
import {
  encodeIpcLengthPrefixedFrame,
  IpcFrameError,
  IpcLengthPrefixDecoder,
} from "../src/ipc_length_prefix.ts";
import {
  MAX_FRAME_BYTES,
  MAX_TRANSFER_CHUNK_BYTES,
} from "../src/limits.ts";

const maximumUint64 = 18_446_744_073_709_551_615n;
type FrameOperationInit = NonNullable<
  MessageInitShape<typeof PiTransportFrameSchema>["operation"]
>;

function protocolVersion(minor = 1, patch = 0) {
  return create(ProtocolVersionSchema, { major: 0, minor, patch });
}

function stableError(code = ErrorCode.NOT_FOUND) {
  return create(StableErrorSchema, {
    code,
    retryable: false,
    safeMessage: "The requested resource was not found.",
  });
}

function sessionSummary() {
  return create(SessionSummarySnapshotSchema, {
    sessionId: "session-1",
    title: "Protocol work",
    workingDirectory: "/tmp/pi-client-protocol",
    createdAtUnixMillis: 9_007_199_254_740_993n,
    updatedAtUnixMillis: 9_007_199_254_740_999n,
    isRunning: true,
    hasUnread: false,
    adminRevision: "revision-session-1",
    hasCustomName: true,
  });
}

function sessionDetail() {
  return create(SessionDetailSnapshotSchema, {
    summary: sessionSummary(),
    messages: [
      {
        messageId: "message-1",
        role: MessageRole.USER,
        text: "Implement the typed protocol boundary.",
        createdAtUnixMillis: 9_007_199_254_741_001n,
        isStreaming: false,
      },
      {
        messageId: "message-2",
        role: MessageRole.ASSISTANT,
        text: "Working on it.",
        createdAtUnixMillis: 9_007_199_254_741_003n,
        isStreaming: true,
      },
    ],
  });
}

function frame(
  frameSequence: bigint,
  operation: FrameOperationInit,
): PiTransportFrame {
  return create(PiTransportFrameSchema, { frameSequence, operation });
}

function validHealthFrame() {
  return frame(maximumUint64, {
    case: "healthResponse",
    value: {
      requestId: 9_007_199_254_740_999n,
      status: HealthStatus.SERVING,
      nodeVersion: "0.1.0-alpha.1+spike",
      uptimeMillis: 9_007_199_254_741_111n,
    },
  });
}

describe("bounded Protobuf frame codec", () => {
  test("round-trips exact v0 SemVer offers and full-range uint64 values", () => {
    const offered = frame(maximumUint64, {
      case: "clientProtocolOffer",
      value: {
        protocolVersions: [protocolVersion(3, 0), protocolVersion(2, 4)],
        capabilities: [
          Capability.SESSION_READ,
          Capability.PROMPT_COMMAND,
          Capability.SESSION_EVENTS,
        ],
        clientInstanceId: "client-1",
        implementationName: "Pi Client",
        implementationVersion: "0.1.0-alpha.1+spike",
        maxFrameBytes: MAX_FRAME_BYTES,
        maxTransferChunkBytes: MAX_TRANSFER_CHUNK_BYTES,
      },
    });

    const decoded = decodeTransportFrame(encodeTransportFrame(offered));
    expect(decoded.frameSequence).toBe(maximumUint64);
    expect(decoded.operation.case).toBe("clientProtocolOffer");
    if (decoded.operation.case === "clientProtocolOffer") {
      expect(
        decoded.operation.value.protocolVersions.map(
          (version) => `${version.major}.${version.minor}.${version.patch}`,
        ),
      ).toEqual(["0.3.0", "0.2.4"]);
    }
  });

  test("round-trips handshake and core session operations", () => {
    const detail = sessionDetail();
    const operations: FrameOperationInit[] = [
      {
        case: "serverHandshakeAccepted",
        value: {
          selectedProtocolVersion: protocolVersion(),
          capabilities: [Capability.SESSION_READ, Capability.SESSION_EVENTS],
          nodeInstanceId: "node-1",
          implementationName: "Pi Node",
          implementationVersion: "0.1.0",
          maxFrameBytes: MAX_FRAME_BYTES,
          maxTransferChunkBytes: MAX_TRANSFER_CHUNK_BYTES,
        },
      },
      {
        case: "serverHandshakeRejected",
        value: {
          error: stableError(ErrorCode.PROTOCOL_VERSION_UNSUPPORTED),
          supportedProtocolVersions: [protocolVersion()],
        },
      },
      {
        case: "listSessionsRequest",
        value: { requestId: 1n, projectId: "project-1" },
      },
      {
        case: "listSessionsResponse",
        value: { requestId: 2n, sessions: [sessionSummary()] },
      },
      {
        case: "getSessionRequest",
        value: { requestId: 3n, sessionId: "session-1", projectId: "project-1" },
      },
      {
        case: "getSessionResponse",
        value: { requestId: 4n, session: detail },
      },
      {
        case: "createSessionRequest",
        value: { requestId: 5n, projectId: "project-1" },
      },
      {
        case: "createSessionResponse",
        value: { requestId: 6n, session: detail },
      },
      {
        case: "promptCommand",
        value: {
          requestId: 7n,
          commandId: "command-1",
          sessionId: "session-1",
          prompt: "Continue.",
        },
      },
      {
        case: "abortCommand",
        value: {
          requestId: 8n,
          commandId: "command-2",
          sessionId: "session-1",
        },
      },
      {
        case: "renameSessionCommand",
        value: {
          requestId: 9n,
          commandId: "admin-rename-1",
          projectId: "project-1",
          sessionId: "session-1",
          name: "Renamed session",
        },
      },
      {
        case: "clearSessionNameCommand",
        value: {
          requestId: 10n,
          commandId: "admin-clear-1",
          projectId: "project-1",
          sessionId: "session-1",
        },
      },
      {
        case: "autoNameSessionCommand",
        value: {
          requestId: 11n,
          commandId: "admin-auto-1",
          projectId: "project-1",
          sessionId: "session-1",
          timeoutMillis: 15_000,
        },
      },
      {
        case: "deleteSessionCommand",
        value: {
          requestId: 12n,
          commandId: "admin-delete-1",
          projectId: "project-1",
          sessionId: "session-1",
          confirmation: {
            sessionId: "session-1",
            adminRevision: "revision-session-1",
            displayedTitle: "Protocol work",
            destructiveActionAcknowledged: true,
          },
        },
      },
      {
        case: "sessionAdminCommandOutcome",
        value: {
          requestId: 13n,
          commandId: "admin-auto-1",
          operation: SessionAdminOperation.AUTO_NAME,
          outcome: { case: "session", value: sessionSummary() },
        },
      },
      {
        case: "requestRejected",
        value: { requestId: 9n, error: stableError() },
      },
      {
        case: "commandAccepted",
        value: { requestId: 10n, commandId: "command-1" },
      },
      {
        case: "commandRejected",
        value: {
          requestId: 11n,
          commandId: "command-2",
          error: stableError(ErrorCode.CONFLICT),
        },
      },
    ];

    operations.forEach((operation, index) => {
      const decoded = decodeTransportFrame(
        encodeTransportFrame(frame(BigInt(index + 1), operation)),
      );
      expect(decoded.operation.case).toBe(operation.case);
    });
  });

  test("round-trips every typed per-session stream event", () => {
    const events: FrameOperationInit[] = [
      {
        case: "sessionEventStream",
        value: {
          streamId: "stream-1",
          sessionId: "session-1",
          eventSequence: 1n,
          event: {
            case: "messageAdded",
            value: { message: sessionDetail().messages[0] },
          },
        },
      },
      {
        case: "sessionEventStream",
        value: {
          streamId: "stream-1",
          sessionId: "session-1",
          eventSequence: 2n,
          event: {
            case: "messageDelta",
            value: { messageId: "message-2", delta: "More output" },
          },
        },
      },
      {
        case: "sessionEventStream",
        value: {
          streamId: "stream-1",
          sessionId: "session-1",
          eventSequence: 3n,
          event: { case: "runningChanged", value: { isRunning: false } },
        },
      },
      {
        case: "sessionEventStream",
        value: {
          streamId: "stream-1",
          sessionId: "session-1",
          eventSequence: 4n,
          event: {
            case: "commandCompleted",
            value: { commandId: "command-1", succeeded: true },
          },
        },
      },
    ];

    events.forEach((operation, index) => {
      const decoded = decodeTransportFrame(
        encodeTransportFrame(frame(BigInt(index + 1), operation)),
      );
      expect(decoded.operation.case).toBe("sessionEventStream");
    });
  });

  test("preserves custom cancel, window, and transfer operations", () => {
    const operations: FrameOperationInit[] = [
      {
        case: "cancel",
        value: {
          target: { case: "requestId", value: maximumUint64 },
          reason: "caller closed",
        },
      },
      {
        case: "windowUpdate",
        value: {
          target: { case: "streamId", value: "stream-1" },
          creditMessages: 32,
          creditBytes: 1_048_576n,
        },
      },
      {
        case: "transferOpen",
        value: {
          requestId: 3n,
          transferId: "transfer-1",
          direction: TransferDirection.DOWNLOAD,
          purpose: TransferPurpose.EXPORT,
          contentType: "application/octet-stream",
          fileName: "session.pb",
          totalBytes: 42n,
          chunkBytes: 42,
          sha256: new Uint8Array(32),
        },
      },
    ];

    operations.forEach((operation, index) => {
      expect(
        decodeTransportFrame(
          encodeTransportFrame(frame(BigInt(index + 1), operation)),
        ).operation.case,
      ).toBe(operation.case);
    });
  });

  test("rejects truncated, malformed, unknown-operation, and unknown-enum bytes", () => {
    expect(() => decodeTransportFrame(Uint8Array.of(0x80))).toThrow();
    expect(() => decodeTransportFrame(Uint8Array.of(0x0a, 0x02, 0x01))).toThrow();

    const unknownOperation = Uint8Array.from([
      0x08,
      0x01,
      ...encodeVarint(BigInt((19_001 << 3) | 2)),
      0x00,
    ]);
    expect(() => decodeTransportFrame(unknownOperation)).toThrow(
      FrameValidationError,
    );

    const unknownEnum = frame(1n, {
      case: "healthResponse",
      value: {
        requestId: 1n,
        status: 99 as HealthStatus,
        nodeVersion: "0.1.0",
      },
    });
    expect(() =>
      decodeTransportFrame(toBinary(PiTransportFrameSchema, unknownEnum)),
    ).toThrow(FrameValidationError);
  });

  test("rejects semantically invalid and oversized frames", () => {
    expect(() => decodeTransportFrame(new Uint8Array(MAX_FRAME_BYTES + 1))).toThrow(
      FrameValidationError,
    );
    expect(() => decodeTransportFrame(Uint8Array.of(0x08, 0x01))).toThrow(
      FrameValidationError,
    );

    const duplicateOffer = frame(1n, {
      case: "clientProtocolOffer",
      value: {
        protocolVersions: [protocolVersion(), protocolVersion()],
        capabilities: [Capability.SESSION_READ],
        clientInstanceId: "client-1",
        implementationName: "Pi Client",
        implementationVersion: "0.1.0",
        maxFrameBytes: MAX_FRAME_BYTES,
        maxTransferChunkBytes: MAX_TRANSFER_CHUNK_BYTES,
      },
    });
    expect(() => encodeTransportFrame(duplicateOffer)).toThrow(
      FrameValidationError,
    );

    const invalidChunk = frame(2n, {
      case: "transferChunk",
      value: {
        transferId: "transfer-1",
        chunkSequence: 1n,
        data: new Uint8Array(MAX_TRANSFER_CHUNK_BYTES + 1),
      },
    });
    expect(() =>
      decodeTransportFrame(toBinary(PiTransportFrameSchema, invalidChunk)),
    ).toThrow(FrameValidationError);
  });
});

describe("stream IPC length prefix", () => {
  test("decodes split and coalesced frames", () => {
    const first = encodeIpcLengthPrefixedFrame(encodeTransportFrame(validHealthFrame()));
    const second = encodeIpcLengthPrefixedFrame(encodeTransportFrame(validHealthFrame()));
    const joined = new Uint8Array(first.length + second.length);
    joined.set(first);
    joined.set(second, first.length);

    const decoder = new IpcLengthPrefixDecoder();
    expect(decoder.push(joined.slice(0, 3))).toHaveLength(0);
    const frames = decoder.push(joined.slice(3));
    expect(frames).toHaveLength(2);
    decoder.finish();
  });

  test("rejects truncated, zero-length, and oversized stream frames", () => {
    const truncated = new IpcLengthPrefixDecoder();
    truncated.push(Uint8Array.of(0, 0, 0, 5, 1, 2));
    expect(() => truncated.finish()).toThrow(IpcFrameError);

    expect(() => new IpcLengthPrefixDecoder().push(Uint8Array.of(0, 0, 0, 0))).toThrow(
      IpcFrameError,
    );

    const oversized = MAX_FRAME_BYTES + 1;
    const header = new Uint8Array(4);
    new DataView(header.buffer).setUint32(0, oversized, false);
    expect(() => new IpcLengthPrefixDecoder().push(header)).toThrow(IpcFrameError);
  });
});

function encodeVarint(value: bigint): number[] {
  const output: number[] = [];
  let remaining = value;
  while (remaining >= 0x80n) {
    output.push(Number((remaining & 0x7fn) | 0x80n));
    remaining >>= 7n;
  }
  output.push(Number(remaining));
  return output;
}
