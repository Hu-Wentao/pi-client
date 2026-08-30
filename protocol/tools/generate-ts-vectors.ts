import { create, toBinary } from "@bufbuild/protobuf";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import {
  HealthStatus,
  MessageRole,
  PiTransportFrameSchema,
  ProjectTrustReason,
  ProjectTrustStatus,
  SessionAdminOperation,
} from "../gen/ts/pi/client/protocol/v0/protocol_pb.ts";
import { encodeTransportFrame } from "../src/frame_codec.ts";

const protocolRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const vectorDirectory = resolve(protocolRoot, "test-vectors");
mkdirSync(vectorDirectory, { recursive: true });

const sessionResponse = create(PiTransportFrameSchema, {
  frameSequence: 18_446_744_073_709_551_615n,
  operation: {
    case: "getSessionResponse",
    value: {
      requestId: 18_446_744_073_709_551_615n,
      session: {
        summary: {
          sessionId: "session-ts-1",
          title: "Cross-language session",
          workingDirectory: "/tmp/pi-client-vector",
          createdAtUnixMillis: 9_007_199_254_740_993n,
          updatedAtUnixMillis: 9_007_199_254_740_999n,
          isRunning: true,
          hasUnread: false,
          adminRevision: "revision-session-ts-1",
          hasCustomName: true,
        },
        messages: [
          {
            messageId: "message-ts-1",
            role: MessageRole.ASSISTANT,
            text: "Typed Protobuf response",
            createdAtUnixMillis: 9_007_199_254_741_001n,
            isStreaming: true,
          },
        ],
      },
    },
  },
});
const sessionBytes = encodeTransportFrame(sessionResponse);
writeFileSync(
  resolve(vectorDirectory, "ts_session_response.pb"),
  sessionBytes,
);

const projectSnapshot = create(PiTransportFrameSchema, {
  frameSequence: 7n,
  operation: {
    case: "validateProjectResponse",
    value: {
      requestId: 11n,
      project: {
        identity: {
          projectId: "project-vector-ts",
          canonicalWorkingDirectory: "/tmp/pi-client-project-vector",
          isGitRepository: true,
          gitRoot: "/tmp/pi-client-project-vector",
          mainWorktreeRoot: "/tmp/pi-client-main-vector",
          branch: "feature/vector",
          isLinkedWorktree: true,
          isDetachedHead: false,
          worktreeId: "worktree-vector-ts",
          mainProjectId: "main-project-vector-ts",
        },
        trust: {
          status: ProjectTrustStatus.APPROVAL_REQUIRED,
          reasons: [
            ProjectTrustReason.PI_SETTINGS,
            ProjectTrustReason.AGENT_SKILLS,
          ],
          revision: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        },
      },
    },
  },
});
writeFileSync(
  resolve(vectorDirectory, "ts_project_snapshot.pb"),
  encodeTransportFrame(projectSnapshot),
);

const sessionAdminOutcome = create(PiTransportFrameSchema, {
  frameSequence: 19n,
  operation: {
    case: "sessionAdminCommandOutcome",
    value: {
      requestId: 23n,
      commandId: "admin-command-ts-1",
      operation: SessionAdminOperation.AUTO_NAME,
      outcome: {
        case: "session",
        value: {
          sessionId: "session-ts-admin-1",
          title: "Generated cross-language title",
          workingDirectory: "/tmp/pi-client-admin-vector",
          createdAtUnixMillis: 1_700_000_000_000n,
          updatedAtUnixMillis: 1_700_000_000_001n,
          isRunning: false,
          hasUnread: false,
          adminRevision: "revision-session-ts-admin-2",
          hasCustomName: true,
        },
      },
    },
  },
});
writeFileSync(
  resolve(vectorDirectory, "ts_session_admin_outcome.pb"),
  encodeTransportFrame(sessionAdminOutcome),
);

// Unknown top-level field 19000, varint value 123. It is appended to a valid
// typed frame so both runtimes can prove decode/re-encode preservation.
const unknownSuffix = Uint8Array.from([
  ...encodeVarint(BigInt((19_000 << 3) | 0)),
  ...encodeVarint(123n),
]);
const unknownBytes = new Uint8Array(sessionBytes.length + unknownSuffix.length);
unknownBytes.set(sessionBytes);
unknownBytes.set(unknownSuffix, sessionBytes.length);
writeFileSync(resolve(vectorDirectory, "unknown_field.pb"), unknownBytes);

// The generated runtime can encode an unknown enum number. The bounded codec
// must reject it instead of treating it as a future known status.
const unknownEnum = create(PiTransportFrameSchema, {
  frameSequence: 1n,
  operation: {
    case: "healthResponse",
    value: {
      requestId: 1n,
      status: 99 as HealthStatus,
      nodeVersion: "0.1.0",
    },
  },
});
writeFileSync(
  resolve(vectorDirectory, "unknown_enum.pb"),
  toBinary(PiTransportFrameSchema, unknownEnum),
);

// Unknown top-level length-delimited operation 19001. frame_sequence remains
// valid, but no known operation is selected after decoding.
writeFileSync(
  resolve(vectorDirectory, "unknown_operation.pb"),
  Uint8Array.from([
    0x08,
    0x01,
    ...encodeVarint(BigInt((19_001 << 3) | 2)),
    0x00,
  ]),
);

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
