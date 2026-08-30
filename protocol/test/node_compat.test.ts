import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import { resolve } from "node:path";
import { decodeTransportFrame, encodeTransportFrame } from "../src/frame_codec.ts";

const vector = resolve(process.cwd(), "test-vectors/dart_event_stream.pb");

test("Node decodes and re-encodes the Dart Protobuf vector", () => {
  const decoded = decodeTransportFrame(readFileSync(vector));
  assert.equal(decoded.frameSequence, 9_007_199_254_740_995n);
  assert.equal(decoded.operation.case, "eventStream");
  const encoded = encodeTransportFrame(decoded);
  assert.ok(encoded.length > 0);
});
