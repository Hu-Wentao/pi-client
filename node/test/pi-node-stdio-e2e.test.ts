import assert from "node:assert/strict";
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { fileURLToPath } from "node:url";
import test from "node:test";

import { create, type MessageInitShape } from "@bufbuild/protobuf";
import {
  Capability,
  ErrorCode,
  IpcLengthPrefixDecoder,
  MAX_FRAME_BYTES,
  MAX_TRANSFER_CHUNK_BYTES,
  PiTransportFrameSchema,
  decodeTransportFrame,
  encodeIpcLengthPrefixedFrame,
  encodeTransportFrame,
  type PiTransportFrame,
} from "@pi-client/protocol";

type FrameOperationInit = NonNullable<MessageInitShape<typeof PiTransportFrameSchema>["operation"]>;

const fixture = fileURLToPath(new URL("fixtures/stdio-fake-server.ts", import.meta.url));

function operationOffer(minor = 2): FrameOperationInit {
  return {
    case: "clientProtocolOffer",
    value: {
      protocolVersions: [{ major: 0, minor, patch: 0 }],
      capabilities: [
        Capability.SESSION_READ,
        Capability.SESSION_CREATE,
        Capability.PROMPT_COMMAND,
        Capability.ABORT_COMMAND,
        Capability.SESSION_EVENTS,
        Capability.PROJECT_DISCOVERY,
        Capability.PROJECT_TRUST,
        Capability.SESSION_ADMIN,
        Capability.SESSION_TREE,
      ],
      clientInstanceId: "stdio-e2e-client",
      implementationName: "Pi Client E2E",
      implementationVersion: "0.1.0-dev.0",
      maxFrameBytes: MAX_FRAME_BYTES,
      maxTransferChunkBytes: MAX_TRANSFER_CHUNK_BYTES,
    },
  };
}

test("binary stdio E2E covers handshake, sessions, prompt events, abort, and disconnect", async (t) => {
  const client = spawnFixture();
  t.after(() => client.forceStop());

  await client.send(1n, operationOffer());
  assert.equal((await client.next()).operation.case, "serverHandshakeAccepted");

  await client.send(2n, {
    case: "getProjectBootstrapRequest",
    value: { requestId: 1n },
  });
  const bootstrap = await client.next();
  assert.equal(bootstrap.operation.case, "getProjectBootstrapResponse");
  const projectId =
    bootstrap.operation.case === "getProjectBootstrapResponse"
      ? bootstrap.operation.value.defaultProject?.identity?.projectId
      : undefined;
  assert.ok(projectId);

  await client.send(3n, {
    case: "listSessionsRequest",
    value: { requestId: 2n, projectId },
  });
  const listed = await client.next();
  assert.equal(listed.operation.case, "listSessionsResponse");
  if (listed.operation.case === "listSessionsResponse") {
    assert.equal(listed.operation.value.sessions[0]?.sessionId, "session-1");
  }

  await client.send(4n, {
    case: "createSessionRequest",
    value: { requestId: 3n, projectId },
  });
  const created = await client.next();
  assert.equal(created.operation.case, "createSessionResponse");
  const createdRevision =
    created.operation.case === "createSessionResponse"
      ? created.operation.value.session?.summary?.adminRevision
      : undefined;
  if (created.operation.case === "createSessionResponse") {
    assert.equal(created.operation.value.session?.summary?.sessionId, "created-1");
  }
  assert.ok(createdRevision);

  await client.send(5n, {
    case: "getSessionRequest",
    value: { requestId: 4n, sessionId: "session-1", projectId },
  });
  const loaded = await client.next();
  assert.equal(loaded.operation.case, "getSessionResponse");
  if (loaded.operation.case === "getSessionResponse") {
    assert.equal(loaded.operation.value.session?.summary?.sessionId, "session-1");
  }

  await client.send(6n, {
    case: "promptCommand",
    value: {
      requestId: 5n,
      commandId: "prompt-stdio",
      sessionId: "session-1",
      prompt: "Run the stdio test",
    },
  });
  assert.equal((await client.next()).operation.case, "commandAccepted");
  const promptEvents = await Promise.all([client.next(), client.next(), client.next()]);
  assert.deepEqual(
    promptEvents.map((frame) => frame.operation.case),
    ["sessionEventStream", "sessionEventStream", "sessionEventStream"],
  );

  await client.send(7n, {
    case: "abortCommand",
    value: {
      requestId: 6n,
      commandId: "abort-stdio",
      sessionId: "session-1",
    },
  });
  assert.equal((await client.next()).operation.case, "commandAccepted");
  const stopped = await client.next();
  const completed = await client.next();
  assert.equal(stopped.operation.case, "sessionEventStream");
  assert.equal(completed.operation.case, "sessionEventStream");
  if (completed.operation.case === "sessionEventStream") {
    assert.equal(completed.operation.value.event.case, "commandCompleted");
    if (completed.operation.value.event.case === "commandCompleted") {
      assert.equal(completed.operation.value.event.value.error?.code, ErrorCode.CANCELLED);
    }
  }

  await client.send(8n, {
    case: "renameSessionCommand",
    value: {
      requestId: 7n,
      commandId: "rename-stdio",
      projectId,
      sessionId: "created-1",
      name: "Renamed over stdio",
    },
  });
  const renamed = await client.next();
  assert.equal(renamed.operation.case, "sessionAdminCommandOutcome");
  const renamedRevision =
    renamed.operation.case === "sessionAdminCommandOutcome" &&
    renamed.operation.value.outcome.case === "session"
      ? renamed.operation.value.outcome.value.adminRevision
      : undefined;
  assert.ok(renamedRevision);

  await client.send(9n, {
    case: "autoNameSessionCommand",
    value: {
      requestId: 8n,
      commandId: "auto-name-stdio",
      projectId,
      sessionId: "created-1",
      timeoutMillis: 15_000,
    },
  });
  const autoNamed = await client.next();
  assert.equal(autoNamed.operation.case, "sessionAdminCommandOutcome");
  const autoNamedRevision =
    autoNamed.operation.case === "sessionAdminCommandOutcome" &&
    autoNamed.operation.value.outcome.case === "session"
      ? autoNamed.operation.value.outcome.value.adminRevision
      : undefined;
  assert.ok(autoNamedRevision);

  await client.send(10n, {
    case: "deleteSessionCommand",
    value: {
      requestId: 9n,
      commandId: "delete-stdio",
      projectId,
      sessionId: "created-1",
      confirmation: {
        sessionId: "created-1",
        adminRevision: autoNamedRevision,
        displayedTitle: "Generated session title",
        destructiveActionAcknowledged: true,
      },
    },
  });
  const deleted = await client.next();
  assert.equal(deleted.operation.case, "sessionAdminCommandOutcome");
  if (deleted.operation.case === "sessionAdminCommandOutcome") {
    assert.equal(deleted.operation.value.outcome.case, "deletion");
  }

  client.endInput();
  const exit = await client.exit();
  assert.deepEqual(exit, { code: 0, signal: null });
  assert.match(client.stderrText, /handshake-accepted/u);
  assert.equal(client.stderrText.includes("private runtime detail"), false);
});

test("binary stdio E2E covers session tree navigation, fork, and clone", async (t) => {
  const client = spawnFixture();
  t.after(() => client.forceStop());

  await client.send(1n, operationOffer());
  assert.equal((await client.next()).operation.case, "serverHandshakeAccepted");
  await client.send(2n, {
    case: "getProjectBootstrapRequest",
    value: { requestId: 1n },
  });
  const bootstrap = await client.next();
  const projectId =
    bootstrap.operation.case === "getProjectBootstrapResponse"
      ? bootstrap.operation.value.defaultProject?.identity?.projectId
      : undefined;
  assert.ok(projectId);
  await client.send(3n, {
    case: "getSessionRequest",
    value: { requestId: 2n, projectId, sessionId: "session-1" },
  });
  const loaded = await client.next();
  const revision =
    loaded.operation.case === "getSessionResponse"
      ? loaded.operation.value.session?.summary?.adminRevision
      : undefined;
  assert.ok(revision);
  await client.send(4n, {
    case: "getSessionTreeRequest",
    value: { requestId: 3n, projectId, sessionId: "session-1" },
  });
  const tree = await client.next();
  const userEntryId =
    tree.operation.case === "getSessionTreeResponse"
      ? tree.operation.value.tree?.nodes.find((node) => node.canFork)?.entryId
      : undefined;
  assert.ok(userEntryId);
  await client.send(5n, {
    case: "navigateSessionTreeCommand",
    value: {
      requestId: 4n,
      commandId: "stdio-tree-navigate",
      projectId,
      sessionId: "session-1",
      entryId: userEntryId,
      expectedAdminRevision: revision,
    },
  });
  const navigated = await client.next();
  assert.equal(navigated.operation.case, "sessionTreeMutationOutcome");
  await client.send(6n, {
    case: "forkSessionCommand",
    value: {
      requestId: 5n,
      commandId: "stdio-tree-fork",
      projectId,
      sessionId: "session-1",
      userEntryId,
      expectedAdminRevision: revision,
    },
  });
  const forked = await client.next();
  const forkedSessionId =
    forked.operation.case === "sessionTreeMutationOutcome" &&
    forked.operation.value.outcome.case === "result"
      ? forked.operation.value.outcome.value.session?.summary?.sessionId
      : undefined;
  const forkedRevision =
    forked.operation.case === "sessionTreeMutationOutcome" &&
    forked.operation.value.outcome.case === "result"
      ? forked.operation.value.outcome.value.session?.summary?.adminRevision
      : undefined;
  assert.ok(forkedSessionId);
  assert.ok(forkedRevision);
  await client.send(7n, {
    case: "cloneSessionCommand",
    value: {
      requestId: 6n,
      commandId: "stdio-tree-clone",
      projectId,
      sessionId: forkedSessionId,
      expectedAdminRevision: forkedRevision,
    },
  });
  const cloned = await client.next();
  assert.equal(cloned.operation.case, "sessionTreeMutationOutcome");
  client.endInput();
  assert.deepEqual(await client.exit(), { code: 0, signal: null });
});

test("binary stdio rejects unsupported unpublished v0 versions", async (t) => {
  const client = spawnFixture();
  t.after(() => client.forceStop());

  await client.send(1n, operationOffer(99));
  const rejected = await client.next();
  assert.equal(rejected.operation.case, "serverHandshakeRejected");
  if (rejected.operation.case === "serverHandshakeRejected") {
    assert.equal(rejected.operation.value.error?.code, ErrorCode.PROTOCOL_VERSION_UNSUPPORTED);
    assert.deepEqual(
      rejected.operation.value.supportedProtocolVersions.map(
        (version) => `${version.major}.${version.minor}.${version.patch}`,
      ),
      ["0.2.0"],
    );
  }
  assert.deepEqual(await client.exit(), { code: 2, signal: null });
});

test("binary stdio reports malformed Protobuf without contaminating stdout", async (t) => {
  const client = spawnFixture();
  t.after(() => client.forceStop());

  await client.send(1n, operationOffer());
  assert.equal((await client.next()).operation.case, "serverHandshakeAccepted");
  await client.sendRawPayload(Uint8Array.of(0x80));

  const error = await client.next();
  assert.equal(error.operation.case, "error");
  if (error.operation.case === "error") {
    assert.equal(error.operation.value.error?.code, ErrorCode.PROTOCOL_VIOLATION);
  }
  assert.deepEqual(await client.exit(), { code: 2, signal: null });
  assert.match(client.stderrText, /protocol-violation/u);
});

class StdioProtocolClient {
  readonly child: ChildProcessWithoutNullStreams;
  readonly #decoder = new IpcLengthPrefixDecoder();
  readonly #frames: PiTransportFrame[] = [];
  readonly #waiters: Array<{
    readonly resolve: (frame: PiTransportFrame) => void;
    readonly reject: (error: Error) => void;
  }> = [];
  readonly #stderr: Uint8Array[] = [];
  #streamError: Error | undefined;

  constructor() {
    this.child = spawn(process.execPath, ["--import", "tsx", fixture], {
      cwd: fileURLToPath(new URL("..", import.meta.url)),
      env: {
        ...process.env,
        PI_OFFLINE: "1",
        PI_SKIP_VERSION_CHECK: "1",
        PI_TELEMETRY: "0",
      },
      stdio: ["pipe", "pipe", "pipe"],
    });
    this.child.stdout.on("data", (chunk: Buffer) => this.#acceptStdout(chunk));
    this.child.stderr.on("data", (chunk: Buffer) => this.#stderr.push(Uint8Array.from(chunk)));
    this.child.once("error", (error) => this.#fail(error));
    this.child.once("close", () => {
      try {
        this.#decoder.finish();
      } catch (error) {
        this.#fail(asError(error));
      }
      this.#fail(new Error("The stdio fixture closed before the expected frame arrived."));
    });
  }

  get stderrText(): string {
    const length = this.#stderr.reduce((total, chunk) => total + chunk.length, 0);
    const bytes = new Uint8Array(length);
    let offset = 0;
    for (const chunk of this.#stderr) {
      bytes.set(chunk, offset);
      offset += chunk.length;
    }
    return new TextDecoder().decode(bytes);
  }

  send(frameSequence: bigint, operation: FrameOperationInit): Promise<void> {
    const payload = encodeTransportFrame(
      create(PiTransportFrameSchema, { frameSequence, operation }),
    );
    return this.sendRawPayload(payload);
  }

  sendRawPayload(payload: Uint8Array): Promise<void> {
    return new Promise((resolve, reject) => {
      this.child.stdin.write(encodeIpcLengthPrefixedFrame(payload), (error) => {
        if (error) {
          reject(error);
        } else {
          resolve();
        }
      });
    });
  }

  next(timeoutMillis = 5_000): Promise<PiTransportFrame> {
    const queued = this.#frames.shift();
    if (queued) {
      return Promise.resolve(queued);
    }
    if (this.#streamError) {
      return Promise.reject(this.#streamError);
    }

    return new Promise((resolve, reject) => {
      const waiter = {
        resolve: (frame: PiTransportFrame) => {
          clearTimeout(timeout);
          resolve(frame);
        },
        reject: (error: Error) => {
          clearTimeout(timeout);
          reject(error);
        },
      };
      const timeout = setTimeout(() => {
        const index = this.#waiters.indexOf(waiter);
        if (index >= 0) {
          this.#waiters.splice(index, 1);
        }
        reject(new Error("Timed out waiting for a stdio protocol frame."));
      }, timeoutMillis);
      this.#waiters.push(waiter);
    });
  }

  endInput(): void {
    this.child.stdin.end();
  }

  exit(timeoutMillis = 5_000): Promise<{ code: number | null; signal: NodeJS.Signals | null }> {
    if (this.child.exitCode !== null || this.child.signalCode !== null) {
      return Promise.resolve({ code: this.child.exitCode, signal: this.child.signalCode });
    }
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error("Timed out waiting for the stdio fixture to exit."));
      }, timeoutMillis);
      this.child.once("exit", (code, signal) => {
        clearTimeout(timeout);
        resolve({ code, signal });
      });
    });
  }

  forceStop(): void {
    if (this.child.exitCode === null && this.child.signalCode === null) {
      this.child.kill("SIGTERM");
    }
  }

  #acceptStdout(chunk: Uint8Array): void {
    try {
      for (const payload of this.#decoder.push(chunk)) {
        const frame = decodeTransportFrame(payload);
        const waiter = this.#waiters.shift();
        if (waiter) {
          waiter.resolve(frame);
        } else {
          this.#frames.push(frame);
        }
      }
    } catch (error) {
      this.#fail(asError(error));
    }
  }

  #fail(error: Error): void {
    if (!this.#streamError) {
      this.#streamError = error;
    }
    for (const waiter of this.#waiters.splice(0)) {
      waiter.reject(error);
    }
  }
}

function spawnFixture(): StdioProtocolClient {
  return new StdioProtocolClient();
}

function asError(error: unknown): Error {
  return error instanceof Error ? error : new Error("Unknown stdio test failure.");
}
