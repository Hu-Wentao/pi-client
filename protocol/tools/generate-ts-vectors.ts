import { create, toBinary } from "@bufbuild/protobuf";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import {
  HealthStatus,
  PiTransportFrameSchema,
} from "../gen/ts/pi/client/protocol/v0/protocol_pb.ts";
import { encodeTransportFrame } from "../src/frame_codec.ts";

const protocolRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const vectorDirectory = resolve(protocolRoot, "test-vectors");
mkdirSync(vectorDirectory, { recursive: true });

const healthFrame = create(PiTransportFrameSchema, {
  frameSequence: 9_007_199_254_740_993n,
  operation: {
    case: "healthResponse",
    value: {
      requestId: "health-ts-1",
      status: HealthStatus.SERVING,
      nodeVersion: "ts-vector-node-0",
      uptimeMillis: 9_007_199_254_741_111n,
    },
  },
});
const healthBytes = encodeTransportFrame(healthFrame);
writeFileSync(resolve(vectorDirectory, "ts_health_response.pb"), healthBytes);

// Unknown top-level field 19000, varint value 123. It is appended to a valid
// typed frame so both runtimes can prove decode/re-encode preservation.
const unknownSuffix = Uint8Array.from([
  ...encodeVarint(BigInt((19_000 << 3) | 0)),
  ...encodeVarint(123n),
]);
const unknownBytes = new Uint8Array(healthBytes.length + unknownSuffix.length);
unknownBytes.set(healthBytes);
unknownBytes.set(unknownSuffix, healthBytes.length);
writeFileSync(resolve(vectorDirectory, "unknown_field.pb"), unknownBytes);

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
