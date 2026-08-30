import { create, toBinary } from "@bufbuild/protobuf";
import { describe, expect, test } from "bun:test";
import {
  HealthStatus,
  PiTransportFrameSchema,
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

function validHealthFrame() {
  return create(PiTransportFrameSchema, {
    frameSequence: 9_007_199_254_740_993n,
    operation: {
      case: "healthResponse",
      value: {
        requestId: "health-1",
        status: HealthStatus.SERVING,
        nodeVersion: "node-spike",
        uptimeMillis: 9_007_199_254_740_999n,
      },
    },
  });
}

describe("bounded Protobuf frame codec", () => {
  test("round-trips a typed operation and uint64 values", () => {
    const decoded = decodeTransportFrame(encodeTransportFrame(validHealthFrame()));
    expect(decoded.frameSequence).toBe(9_007_199_254_740_993n);
    expect(decoded.operation.case).toBe("healthResponse");
    if (decoded.operation.case === "healthResponse") {
      expect(decoded.operation.value.uptimeMillis).toBe(9_007_199_254_740_999n);
    }
  });

  test("rejects truncated and malformed protobuf bytes", () => {
    expect(() => decodeTransportFrame(Uint8Array.of(0x80))).toThrow();
    expect(() => decodeTransportFrame(Uint8Array.of(0x0a, 0x02, 0x01))).toThrow();
  });

  test("rejects oversized and semantically invalid frames", () => {
    expect(() => decodeTransportFrame(new Uint8Array(MAX_FRAME_BYTES + 1))).toThrow(
      FrameValidationError,
    );
    expect(() => decodeTransportFrame(Uint8Array.of(0x08, 0x01))).toThrow(
      FrameValidationError,
    );

    const invalidChunk = create(PiTransportFrameSchema, {
      operation: {
        case: "transferChunk",
        value: {
          transferId: "transfer-1",
          data: new Uint8Array(MAX_TRANSFER_CHUNK_BYTES + 1),
        },
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
