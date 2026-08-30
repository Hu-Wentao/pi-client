import assert from "node:assert/strict";
import test from "node:test";

import { create, type MessageInitShape } from "@bufbuild/protobuf";
import {
  Capability,
  ErrorCode,
  MAX_FRAME_BYTES,
  MAX_TRANSFER_CHUNK_BYTES,
  PiTransportFrameSchema,
  decodeTransportFrame,
  encodeTransportFrame,
  type PiTransportFrame,
} from "@pi-client/protocol";

import { PiNodeProtobufConnection } from "../src/protocol/pi-node-protobuf-connection.js";
import { FakeProtocolDomain } from "./support/fake-protocol-domain.js";

type FrameOperationInit = NonNullable<MessageInitShape<typeof PiTransportFrameSchema>["operation"]>;

function clientFrame(frameSequence: bigint, operation: FrameOperationInit): Uint8Array {
  return encodeTransportFrame(create(PiTransportFrameSchema, { frameSequence, operation }));
}

function protocolOffer(
  versions: readonly {
    readonly major: number;
    readonly minor: number;
    readonly patch: number;
  }[] = [{ major: 0, minor: 1, patch: 0 }],
  capabilities: readonly Capability[] = [
    Capability.SESSION_READ,
    Capability.SESSION_CREATE,
    Capability.PROMPT_COMMAND,
    Capability.ABORT_COMMAND,
    Capability.SESSION_EVENTS,
  ],
): FrameOperationInit {
  return {
    case: "clientProtocolOffer",
    value: {
      protocolVersions: [...versions],
      capabilities: [...capabilities],
      clientInstanceId: "test-client",
      implementationName: "Pi Client Test",
      implementationVersion: "0.1.0-dev.0",
      maxFrameBytes: MAX_FRAME_BYTES,
      maxTransferChunkBytes: MAX_TRANSFER_CHUNK_BYTES,
    },
  };
}

function connection(domain = new FakeProtocolDomain()) {
  const output: PiTransportFrame[] = [];
  const server = new PiNodeProtobufConnection({
    domain,
    workingDirectory: "/project",
    nodeInstanceId: "test-node",
    implementationVersion: "0.1.0-dev.0",
    streamIdFactory: (_sessionId, ordinal) => `stream-${ordinal}`,
    writeFrame: (payload) => {
      output.push(decodeTransportFrame(payload));
    },
  });
  return { domain, output, server };
}

async function handshake(
  server: PiNodeProtobufConnection,
  operation: FrameOperationInit = protocolOffer(),
): Promise<void> {
  const result = await server.receive(clientFrame(1n, operation));
  assert.equal(result.close, false);
}

test("handshake selects the first explicitly supported offered v0 version and capability subset", async () => {
  const { output, server } = connection();
  try {
    await handshake(
      server,
      protocolOffer(
        [
          { major: 0, minor: 9, patch: 0 },
          { major: 0, minor: 1, patch: 0 },
          { major: 0, minor: 0, patch: 9 },
        ],
        [
          Capability.TRANSFER,
          Capability.ABORT_COMMAND,
          Capability.SESSION_READ,
          Capability.SESSION_EVENTS,
        ],
      ),
    );

    const accepted = output[0];
    assert.equal(accepted?.frameSequence, 1n);
    assert.equal(accepted?.operation.case, "serverHandshakeAccepted");
    if (accepted?.operation.case === "serverHandshakeAccepted") {
      assert.deepEqual(accepted.operation.value.selectedProtocolVersion, {
        $typeName: "pi.client.protocol.v0.ProtocolVersion",
        major: 0,
        minor: 1,
        patch: 0,
      });
      assert.deepEqual(accepted.operation.value.capabilities, [
        Capability.ABORT_COMMAND,
        Capability.SESSION_READ,
        Capability.SESSION_EVENTS,
      ]);
    }
  } finally {
    await server.dispose();
  }
});

test("establishes one observation and sends its response before synchronous events", async () => {
  const domain = new FakeProtocolDomain();
  domain.emitOnObserve = true;
  const { output, server } = connection(domain);
  try {
    await handshake(server);
    await server.receive(
      clientFrame(2n, {
        case: "getSessionRequest",
        value: { requestId: 1n, sessionId: "session-1" },
      }),
    );

    assert.deepEqual(
      output.map((frame) => frame.operation.case),
      ["serverHandshakeAccepted", "getSessionResponse", "sessionEventStream"],
    );
    assert.equal(domain.observedCount.get("session-1"), 1);
  } finally {
    await server.dispose();
  }
  assert.equal(domain.unsubscribedCount.get("session-1"), 1);
});

test("routes session requests and admits commands before forwarding ordered session events", async () => {
  const { domain, output, server } = connection();
  try {
    await handshake(server);
    await server.receive(
      clientFrame(2n, { case: "listSessionsRequest", value: { requestId: 1n } }),
    );
    await server.receive(
      clientFrame(3n, {
        case: "getSessionRequest",
        value: { requestId: 2n, sessionId: "session-1" },
      }),
    );
    await server.receive(
      clientFrame(4n, {
        case: "getSessionRequest",
        value: { requestId: 3n, sessionId: "session-1" },
      }),
    );
    await server.receive(
      clientFrame(5n, {
        case: "createSessionRequest",
        value: { requestId: 4n, workingDirectory: "/new-project" },
      }),
    );

    const promptOutputStart = output.length;
    await server.receive(
      clientFrame(6n, {
        case: "promptCommand",
        value: {
          requestId: 5n,
          commandId: "prompt-1",
          sessionId: "session-1",
          prompt: "Continue",
        },
      }),
    );
    const promptCases = output.slice(promptOutputStart).map((frame) => frame.operation.case);
    assert.deepEqual(promptCases, [
      "commandAccepted",
      "sessionEventStream",
      "sessionEventStream",
      "sessionEventStream",
    ]);

    const abortOutputStart = output.length;
    await server.receive(
      clientFrame(7n, {
        case: "abortCommand",
        value: {
          requestId: 6n,
          commandId: "abort-1",
          sessionId: "session-1",
        },
      }),
    );
    assert.deepEqual(
      output.slice(abortOutputStart).map((frame) => frame.operation.case),
      ["commandAccepted", "sessionEventStream", "sessionEventStream"],
    );

    assert.equal(domain.observedCount.get("session-1"), 1);
    assert.equal(domain.observedCount.get("created-1"), 1);
    assert.deepEqual(
      output.map((frame) => frame.frameSequence),
      output.map((_frame, index) => BigInt(index + 1)),
    );
    const sessionEvents = output.filter(
      (
        frame,
      ): frame is PiTransportFrame & {
        operation: Extract<PiTransportFrame["operation"], { case: "sessionEventStream" }>;
      } => frame.operation.case === "sessionEventStream",
    );
    assert.deepEqual(
      sessionEvents.map((frame) => frame.operation.value.eventSequence),
      [1n, 2n, 3n, 4n, 5n],
    );
    const completed = sessionEvents.at(-1);
    assert.equal(completed?.operation.value.event.case, "commandCompleted");
    if (completed?.operation.value.event.case === "commandCompleted") {
      assert.equal(completed.operation.value.event.value.succeeded, false);
      assert.equal(completed.operation.value.event.value.error?.code, ErrorCode.CANCELLED);
      assert.equal(
        completed.operation.value.event.value.error?.safeMessage,
        "The command was aborted.",
      );
    }
  } finally {
    await server.dispose();
  }

  assert.equal(domain.unsubscribedCount.get("session-1"), 1);
  assert.equal(domain.unsubscribedCount.get("created-1"), 1);
});

test("rejects reused request and command identifiers without invoking the domain twice", async () => {
  const { output, server } = connection();
  try {
    await handshake(server);
    await server.receive(
      clientFrame(2n, { case: "listSessionsRequest", value: { requestId: 9n } }),
    );
    await server.receive(
      clientFrame(3n, { case: "listSessionsRequest", value: { requestId: 9n } }),
    );
    await server.receive(
      clientFrame(4n, {
        case: "getSessionRequest",
        value: { requestId: 10n, sessionId: "session-1" },
      }),
    );
    await server.receive(
      clientFrame(5n, {
        case: "promptCommand",
        value: {
          requestId: 11n,
          commandId: "same-command",
          sessionId: "session-1",
          prompt: "One",
        },
      }),
    );
    await server.receive(
      clientFrame(6n, {
        case: "promptCommand",
        value: {
          requestId: 12n,
          commandId: "same-command",
          sessionId: "session-1",
          prompt: "Two",
        },
      }),
    );

    const duplicateRequest = output.find(
      (frame) =>
        frame.operation.case === "requestRejected" && frame.operation.value.requestId === 9n,
    );
    assert.equal(
      duplicateRequest?.operation.case === "requestRejected"
        ? duplicateRequest.operation.value.error?.code
        : undefined,
      ErrorCode.ALREADY_EXISTS,
    );
    const duplicateCommand = output.find(
      (frame) =>
        frame.operation.case === "commandRejected" && frame.operation.value.requestId === 12n,
    );
    assert.equal(
      duplicateCommand?.operation.case === "commandRejected"
        ? duplicateCommand.operation.value.error?.code
        : undefined,
      ErrorCode.ALREADY_EXISTS,
    );
  } finally {
    await server.dispose();
  }
});

test("maps unknown domain failures to redacted stable errors", async () => {
  const domain = new FakeProtocolDomain();
  domain.listError = new Error("provider-token=secret-value /private/project/path");
  const { output, server } = connection(domain);
  try {
    await handshake(server);
    await server.receive(
      clientFrame(2n, { case: "listSessionsRequest", value: { requestId: 1n } }),
    );

    const rejection = output[1];
    assert.equal(rejection?.operation.case, "requestRejected");
    if (rejection?.operation.case === "requestRejected") {
      assert.equal(rejection.operation.value.error?.code, ErrorCode.INTERNAL);
      assert.equal(rejection.operation.value.error?.safeMessage, "The Pi Node operation failed.");
      assert.equal(rejection.operation.value.error?.safeMessage.includes("secret-value"), false);
    }
  } finally {
    await server.dispose();
  }
});

test("closes the connection on a non-contiguous client frame sequence", async () => {
  const { output, server } = connection();
  try {
    await handshake(server);
    const result = await server.receive(
      clientFrame(3n, { case: "listSessionsRequest", value: { requestId: 1n } }),
    );
    assert.deepEqual(result, { close: true, reason: "protocol-error" });
    const lastFrame = output.at(-1);
    assert.equal(lastFrame?.operation.case, "error");
    if (lastFrame?.operation.case === "error") {
      assert.equal(lastFrame.operation.value.error?.code, ErrorCode.PROTOCOL_VIOLATION);
    }
  } finally {
    await server.dispose();
  }
});
