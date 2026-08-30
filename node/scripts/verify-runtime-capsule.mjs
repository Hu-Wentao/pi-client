#!/usr/bin/env node

import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";
import { spawn } from "node:child_process";
import { mkdir, rm, stat, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

import {
  CAPSULE_MANIFEST_NAME,
  assertReadOnlyTree,
  isolatedRuntimeEnvironment,
  readJson,
  resolveCapsulePath,
  scanForbiddenArtifacts,
  validateManifestDocument,
  verifyLockCopies,
  verifyPackageMetadata,
  verifyPayloadIntegrity,
  verifyRuntimeMetadata,
} from "./runtime-capsule-lib.mjs";
import { currentCapsuleTargetId } from "./runtime-capsule-config.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const repositoryRoot = resolve(scriptDirectory, "../..");
const capsuleRoot = resolve(
  process.argv[2] ??
    resolve(repositoryRoot, "build", `pi-node-runtime-capsule-${currentCapsuleTargetId()}`),
);
if (process.argv.length > 3) {
  throw new Error("verify-runtime-capsule.mjs accepts at most one capsule directory path.");
}

const rootMetadata = await stat(capsuleRoot);
if (!rootMetadata.isDirectory()) {
  throw new Error(`Runtime capsule path is not a directory: ${capsuleRoot}`);
}
const manifest = await readJson(resolve(capsuleRoot, CAPSULE_MANIFEST_NAME));
const target = validateManifestDocument(manifest);
if (target.id !== currentCapsuleTargetId()) {
  throw new Error(
    `Runtime E2E verification requires host target ${currentCapsuleTargetId()}; capsule is ${target.id}.`,
  );
}
const expectedSourceCommit = process.env.PI_RUNTIME_CAPSULE_EXPECTED_SOURCE_COMMIT;
if (expectedSourceCommit && manifest.sourceCommit !== expectedSourceCommit) {
  throw new Error(
    `Capsule source commit ${manifest.sourceCommit} does not match ${expectedSourceCommit}.`,
  );
}

await assertReadOnlyTree(capsuleRoot);
await verifyPayloadIntegrity(capsuleRoot, manifest);
await verifyLockCopies(capsuleRoot, manifest);
const packages = await verifyPackageMetadata(capsuleRoot, manifest);
await scanForbiddenArtifacts(capsuleRoot);
for (const licensePath of manifest.runtime.licenses) {
  const metadata = await stat(resolveCapsulePath(capsuleRoot, licensePath, "runtime license"));
  if (!metadata.isFile() || metadata.size === 0) {
    throw new Error(`Capsule license is missing or empty: ${licensePath}.`);
  }
}
const runtime = await verifyRuntimeMetadata(capsuleRoot, manifest);
const e2e = await runRuntimeProtocolE2e(capsuleRoot, manifest, runtime);

process.stdout.write(
  `${JSON.stringify(
    {
      capsulePath: capsuleRoot,
      sourceCommit: manifest.sourceCommit,
      target: target.id,
      payloadFileCount: manifest.integrity.payloadFileCount,
      payloadSize: manifest.integrity.payloadSize,
      installedPackageCount: packages.length,
      nodeVersion: manifest.versions.node,
      npmVersion: manifest.versions.npm,
      piSdkVersion: manifest.versions.piSdk,
      protocolVersion: manifest.versions.protocol,
      runtimeE2e: e2e,
      readOnly: true,
      path: runtime.isolatedEnvironment.PATH,
    },
    null,
    2,
  )}\n`,
);

async function runRuntimeProtocolE2e(capsule, capsuleManifest, runtime) {
  const verificationRoot = resolve(
    repositoryRoot,
    "build/temp",
    `runtime-capsule-e2e-${process.pid}-${randomUUID()}`,
  );
  const cwd = resolve(verificationRoot, "project");
  const agentDir = resolve(verificationRoot, "agent");
  const sessionDir = resolve(verificationRoot, "sessions");
  const home = resolve(verificationRoot, "home");
  const temporary = resolve(verificationRoot, "tmp");
  await Promise.all(
    [cwd, agentDir, sessionDir, home, temporary].map((path) => mkdir(path, { recursive: true })),
  );
  await writeFile(
    resolve(agentDir, "settings.json"),
    `${JSON.stringify({ sessionDir, enableAnalytics: false })}\n`,
    "utf8",
  );

  const protocol = await import(
    pathToFileURL(resolve(capsule, "app/node_modules/@pi-client/protocol/dist/src/index.js")).href
  );
  const protobuf = await import(
    pathToFileURL(resolve(capsule, "app/node_modules/@bufbuild/protobuf/dist/esm/index.js")).href
  );
  const environment = {
    ...isolatedRuntimeEnvironment(runtime.runtimeBin, {
      ...process.env,
      HOME: home,
      TMPDIR: temporary,
    }),
    HOME: home,
    TMPDIR: temporary,
    PI_CODING_AGENT_DIR: agentDir,
  };
  assert.equal(environment.PATH, runtime.runtimeBin);

  const client = new CapsuleProtocolClient({
    executable: runtime.executable,
    entrypoint: resolveCapsulePath(
      capsule,
      capsuleManifest.application.entrypoint,
      "application entrypoint",
    ),
    cwd,
    agentDir,
    environment,
    protocol,
    protobuf,
  });
  try {
    await client.send(1n, {
      case: "clientProtocolOffer",
      value: {
        protocolVersions: [{ major: 0, minor: 1, patch: 0 }],
        capabilities: [
          protocol.Capability.SESSION_READ,
          protocol.Capability.SESSION_CREATE,
          protocol.Capability.SESSION_EVENTS,
        ],
        clientInstanceId: "runtime-capsule-verifier",
        implementationName: "Pi Client Runtime Capsule Verifier",
        implementationVersion: capsuleManifest.versions.piNode,
        maxFrameBytes: protocol.MAX_FRAME_BYTES,
        maxTransferChunkBytes: protocol.MAX_TRANSFER_CHUNK_BYTES,
      },
    });
    assert.equal((await client.next()).operation.case, "serverHandshakeAccepted");

    await client.send(2n, { case: "listSessionsRequest", value: { requestId: 1n } });
    const listed = await client.next();
    assert.equal(listed.operation.case, "listSessionsResponse");

    await client.send(3n, {
      case: "createSessionRequest",
      value: { requestId: 2n, workingDirectory: cwd },
    });
    const created = await client.next(30_000);
    assert.equal(created.operation.case, "createSessionResponse");
    const sessionId = created.operation.value.session?.summary?.sessionId;
    assert.equal(typeof sessionId, "string");
    assert.notEqual(sessionId.length, 0);

    await client.send(4n, {
      case: "getSessionRequest",
      value: { requestId: 3n, sessionId },
    });
    const loaded = await client.next(30_000);
    assert.equal(loaded.operation.case, "getSessionResponse");
    assert.equal(loaded.operation.value.session?.summary?.sessionId, sessionId);

    client.endInput();
    const exit = await client.exit(30_000);
    assert.deepEqual(exit, { code: 0, signal: null });
    assert.match(client.stderrText, /handshake-accepted/u);
    return {
      handshake: "accepted",
      list: listed.operation.case,
      create: created.operation.case,
      get: loaded.operation.case,
      childExitCode: exit.code,
      systemNodeExcludedFromPath: true,
    };
  } finally {
    client.forceStop();
    await rm(verificationRoot, { recursive: true, force: true });
  }
}

class CapsuleProtocolClient {
  constructor(options) {
    this.protocol = options.protocol;
    this.protobuf = options.protobuf;
    this.decoder = new options.protocol.IpcLengthPrefixDecoder();
    this.frames = [];
    this.waiters = [];
    this.stderr = [];
    this.streamError = undefined;
    this.child = spawn(
      options.executable,
      [options.entrypoint, "--cwd", options.cwd, "--agent-dir", options.agentDir],
      {
        cwd: options.cwd,
        env: options.environment,
        stdio: ["pipe", "pipe", "pipe"],
      },
    );
    this.child.stdout.on("data", (chunk) => this.acceptStdout(chunk));
    this.child.stderr.on("data", (chunk) => this.stderr.push(Buffer.from(chunk)));
    this.child.once("error", (error) => this.fail(error));
    this.child.once("close", () => {
      try {
        this.decoder.finish();
      } catch (error) {
        this.fail(asError(error));
      }
      this.fail(new Error("The capsule runtime closed before the expected frame arrived."));
    });
  }

  get stderrText() {
    return Buffer.concat(this.stderr).toString("utf8");
  }

  send(frameSequence, operation) {
    const frame = this.protobuf.create(this.protocol.PiTransportFrameSchema, {
      frameSequence,
      operation,
    });
    const payload = this.protocol.encodeTransportFrame(frame);
    return new Promise((resolvePromise, rejectPromise) => {
      this.child.stdin.write(this.protocol.encodeIpcLengthPrefixedFrame(payload), (error) =>
        error ? rejectPromise(error) : resolvePromise(),
      );
    });
  }

  next(timeoutMillis = 10_000) {
    const queued = this.frames.shift();
    if (queued) {
      return Promise.resolve(queued);
    }
    if (this.streamError) {
      return Promise.reject(this.streamError);
    }
    return new Promise((resolvePromise, rejectPromise) => {
      const waiter = {
        resolve: (frame) => {
          clearTimeout(timeout);
          resolvePromise(frame);
        },
        reject: (error) => {
          clearTimeout(timeout);
          rejectPromise(error);
        },
      };
      const timeout = setTimeout(() => {
        const index = this.waiters.indexOf(waiter);
        if (index >= 0) {
          this.waiters.splice(index, 1);
        }
        rejectPromise(new Error("Timed out waiting for a capsule protocol frame."));
      }, timeoutMillis);
      this.waiters.push(waiter);
    });
  }

  endInput() {
    this.child.stdin.end();
  }

  exit(timeoutMillis) {
    if (this.child.exitCode !== null || this.child.signalCode !== null) {
      return Promise.resolve({ code: this.child.exitCode, signal: this.child.signalCode });
    }
    return new Promise((resolvePromise, rejectPromise) => {
      const timeout = setTimeout(() => {
        rejectPromise(new Error("Timed out waiting for the capsule runtime to exit."));
      }, timeoutMillis);
      this.child.once("exit", (code, signal) => {
        clearTimeout(timeout);
        resolvePromise({ code, signal });
      });
    });
  }

  forceStop() {
    if (this.child.exitCode === null && this.child.signalCode === null) {
      this.child.kill("SIGTERM");
    }
  }

  acceptStdout(chunk) {
    try {
      for (const payload of this.decoder.push(chunk)) {
        const frame = this.protocol.decodeTransportFrame(payload);
        const waiter = this.waiters.shift();
        if (waiter) {
          waiter.resolve(frame);
        } else {
          this.frames.push(frame);
        }
      }
    } catch (error) {
      this.fail(asError(error));
    }
  }

  fail(error) {
    if (!this.streamError) {
      this.streamError = error;
    }
    for (const waiter of this.waiters.splice(0)) {
      waiter.reject(error);
    }
  }
}

function asError(error) {
  return error instanceof Error ? error : new Error("Unknown capsule protocol failure.");
}
