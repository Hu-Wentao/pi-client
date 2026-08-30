import { fromBinary, toBinary } from "@bufbuild/protobuf";
import { describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { PiTransportFrameSchema } from "../gen/ts/pi/client/protocol/v0/protocol_pb.ts";
import {
  decodeTransportFrame,
  FrameValidationError,
} from "../src/frame_codec.ts";

const vectors = resolve(import.meta.dir, "../test-vectors");
const unknownSuffix = Uint8Array.from([0xc0, 0xa3, 0x09, 0x7b]);
const maximumUint64 = 18_446_744_073_709_551_615n;

describe("cross-language Protobuf vectors", () => {
  test("decodes Dart session event and full-range uint64 values", () => {
    const frame = decodeTransportFrame(
      readFileSync(resolve(vectors, "dart_session_event.pb")),
    );

    expect(frame.frameSequence).toBe(maximumUint64);
    expect(frame.operation.case).toBe("sessionEventStream");
    if (frame.operation.case !== "sessionEventStream") {
      throw new Error("expected session event stream operation");
    }
    expect(frame.operation.value.streamId).toBe("session-events-dart-1");
    expect(frame.operation.value.eventSequence).toBe(maximumUint64);
    expect(frame.operation.value.event.case).toBe("commandCompleted");
  });

  test("decodes Dart bounded directory listings with canonical symlink targets", () => {
    const frame = decodeTransportFrame(
      readFileSync(resolve(vectors, "dart_directory_listing.pb")),
    );

    expect(frame.operation.case).toBe("browseDirectoryResponse");
    if (frame.operation.case !== "browseDirectoryResponse") {
      throw new Error("expected directory listing response");
    }
    expect(frame.operation.value.directory?.canonicalDirectory).toBe(
      "/tmp/pi-client-projects",
    );
    expect(frame.operation.value.directory?.children).toHaveLength(2);
    expect(frame.operation.value.directory?.children[1]?.isSymbolicLink).toBeTrue();
    expect(frame.operation.value.directory?.truncated).toBeTrue();
  });

  test("preserves unknown fields when decoded and re-encoded by Protobuf-ES", () => {
    const input = readFileSync(resolve(vectors, "unknown_field.pb"));
    const decoded = fromBinary(PiTransportFrameSchema, input);
    const output = toBinary(PiTransportFrameSchema, decoded);

    expect(containsSubsequence(output, unknownSuffix)).toBeTrue();
    expect(decodeTransportFrame(output).operation.case).toBe("getSessionResponse");
  });

  test("rejects unknown operation and enum vectors", () => {
    expect(() =>
      decodeTransportFrame(readFileSync(resolve(vectors, "unknown_operation.pb"))),
    ).toThrow(FrameValidationError);
    expect(() =>
      decodeTransportFrame(readFileSync(resolve(vectors, "unknown_enum.pb"))),
    ).toThrow(FrameValidationError);
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
