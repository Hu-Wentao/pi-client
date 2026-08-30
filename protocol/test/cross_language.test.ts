import { fromBinary, toBinary } from "@bufbuild/protobuf";
import { describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { PiTransportFrameSchema } from "../gen/ts/pi/client/protocol/v0/protocol_pb.ts";
import { decodeTransportFrame } from "../src/frame_codec.ts";

const vectors = resolve(import.meta.dir, "../test-vectors");
const unknownSuffix = Uint8Array.from([0xc0, 0xa3, 0x09, 0x7b]);

describe("cross-language Protobuf vectors", () => {
  test("decodes Dart event stream and uint64 values", () => {
    const frame = decodeTransportFrame(
      readFileSync(resolve(vectors, "dart_event_stream.pb")),
    );

    expect(frame.frameSequence).toBe(9_007_199_254_740_995n);
    expect(frame.operation.case).toBe("eventStream");
    if (frame.operation.case !== "eventStream") {
      throw new Error("expected event stream operation");
    }
    expect(frame.operation.value.streamId).toBe("events-dart-1");
    expect(frame.operation.value.eventSequence).toBe(9_007_199_254_740_997n);
    expect(frame.operation.value.event.case).toBe("heartbeat");
  });

  test("preserves unknown fields when decoded and re-encoded by Protobuf-ES", () => {
    const input = readFileSync(resolve(vectors, "unknown_field.pb"));
    const decoded = fromBinary(PiTransportFrameSchema, input);
    const output = toBinary(PiTransportFrameSchema, decoded);

    expect(containsSubsequence(output, unknownSuffix)).toBeTrue();
    expect(decodeTransportFrame(output).operation.case).toBe("healthResponse");
  });
});

function containsSubsequence(haystack: Uint8Array, needle: Uint8Array): boolean {
  outer: for (let start = 0; start <= haystack.length - needle.length; start++) {
    for (let offset = 0; offset < needle.length; offset++) {
      if (haystack[start + offset] !== needle[offset]) {
        continue outer;
      }
    }
    return true;
  }
  return false;
}
