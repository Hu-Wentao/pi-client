#!/usr/bin/env node

import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";
import { spawn, spawnSync } from "node:child_process";
import { mkdir, rm, stat, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { delimiter, dirname, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

import {
  CAPSULE_MANIFEST_NAME,
  assertCapsuleFileModes,
  assertReadOnlyTree,
  isolatedRuntimeEnvironment,
  readJson,
  resolveCapsulePath,
  runCaptured,
  runtimeArgumentsForArchitecture,
  scanForbiddenArtifacts,
  validateManifestDocument,
  verifyLockCopies,
  verifyPackageLicenseInventories,
  verifyPackageMetadata,
  verifyPayloadIntegrity,
  verifyRuntimeMetadata,
} from "./runtime-capsule-lib.mjs";
import { currentCapsuleTargetId } from "./runtime-capsule-config.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const repositoryRoot = resolve(scriptDirectory, "../..");

async function main() {
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
  assertHostCanExecuteTarget(target);
  const expectedSourceCommit = process.env.PI_RUNTIME_CAPSULE_EXPECTED_SOURCE_COMMIT;
  if (expectedSourceCommit && manifest.sourceCommit !== expectedSourceCommit) {
    throw new Error(
      `Capsule source commit ${manifest.sourceCommit} does not match ${expectedSourceCommit}.`,
    );
  }

  await assertReadOnlyTree(capsuleRoot);
  await assertCapsuleFileModes(capsuleRoot, manifest.runtime.executable);
  await verifyPayloadIntegrity(capsuleRoot, manifest);
  await verifyLockCopies(capsuleRoot, manifest);
  const packages = await verifyPackageMetadata(capsuleRoot, manifest);
  const inventories = await verifyPackageLicenseInventories(capsuleRoot);
  await scanForbiddenArtifacts(capsuleRoot);
  for (const licensePath of manifest.runtime.licenses) {
    const metadata = await stat(resolveCapsulePath(capsuleRoot, licensePath, "runtime license"));
    if (!metadata.isFile() || metadata.size === 0) {
      throw new Error(`Capsule license is missing or empty: ${licensePath}.`);
    }
  }
  const runtime = await verifyRuntimeMetadata(capsuleRoot, manifest);
  const architectureFixtures = await runArchitectureFixtures(capsuleRoot, manifest, runtime);
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
        packageInventoryCount: inventories.packages.packageCount,
        licenseInventoryCount: inventories.licenses.packageCount,
        nodeVersion: manifest.versions.node,
        npmVersion: manifest.versions.npm,
        piSdkVersion: manifest.versions.piSdk,
        protocolVersion: manifest.versions.protocol,
        runtimeE2e: e2e,
        architectureFixtures,
        nativeCode: manifest.nativeCode,
        readOnly: true,
        path: runtime.isolatedEnvironment.PATH,
      },
      null,
      2,
    )}\n`,
  );
}

function assertHostCanExecuteTarget(target) {
  if (target.platform !== process.platform) {
    throw new Error(
      `Runtime E2E requires ${target.platform}; current platform is ${process.platform}.`,
    );
  }
  if (target.platform !== "darwin") return;
  for (const architecture of target.architectures) {
    const archName = architecture === "x64" ? "x86_64" : architecture;
    const result = spawnArchitectureSync("/usr/bin/true", [], architecture);
    if (result.status !== 0) {
      throw new Error(
        `Runtime E2E lacks executable ${archName} evidence for capsule ${target.id}.`,
      );
    }
  }
}

async function runArchitectureFixtures(capsule, manifest, runtime) {
  if (manifest.target.platform !== "darwin") {
    return [await runPortableNativeAddonFixture(capsule, manifest, runtime)];
  }
  const fixtures = [];
  const piTuiAddons = manifest.nativeCode.objects.filter(
    (entry) =>
      entry.kind === "native-addon" &&
      entry.path.includes("@earendil-works/pi-tui/native/darwin/prebuilds/") &&
      entry.format === "mach-o",
  );
  const clipboardAddon = manifest.nativeCode.objects.find(
    (entry) =>
      entry.kind === "native-addon" &&
      entry.path.includes("@mariozechner/clipboard-darwin-universal/") &&
      entry.format === "mach-o" &&
      manifest.target.architectures.every((architecture) =>
        entry.architectures.includes(architecture),
      ),
  );
  if (!clipboardAddon) {
    throw new Error("Capsule is missing the Universal clipboard native-addon fixture.");
  }

  for (const architecture of manifest.target.architectures) {
    const piTuiAddon = piTuiAddons.find(
      (entry) => entry.architectures.length === 1 && entry.architectures[0] === architecture,
    );
    if (!piTuiAddon) {
      throw new Error(`Capsule is missing a Pi TUI ${architecture} native-addon fixture.`);
    }
    const fixtureRoot = resolve(
      tmpdir(),
      `pi-capsule-architecture-${architecture}-${process.pid}-${randomUUID()}`,
    );
    const extensionPath = resolve(fixtureRoot, "native-addon-extension.js");
    await mkdir(fixtureRoot, { recursive: true });
    const piTuiAddonPath = resolveCapsulePath(capsule, piTuiAddon.path, "Pi TUI native addon");
    const clipboardPackagePath = resolve(
      capsule,
      "app/node_modules/@mariozechner/clipboard/index.js",
    );
    await writeFile(
      extensionPath,
      [
        'import { createRequire } from "node:module";',
        "const require = createRequire(import.meta.url);",
        `const addon = require(${JSON.stringify(piTuiAddonPath)});`,
        'if (typeof addon.isModifierPressed !== "function") throw new Error("native addon API missing");',
        "export default function capsuleNativeAddonExtension() {}",
      ].join("\n"),
      "utf8",
    );
    const architectureArguments = runtimeArgumentsForArchitecture(manifest, architecture);
    const environment = {
      ...runtime.isolatedEnvironment,
      HOME: fixtureRoot,
      TMPDIR: fixtureRoot,
    };
    const fixtureScript = [
      'import { createRequire } from "node:module";',
      "const require = createRequire(import.meta.url);",
      `const directAddon = require(${JSON.stringify(piTuiAddonPath)});`,
      'if (typeof directAddon.isModifierPressed !== "function") throw new Error("Pi TUI addon API missing");',
      `const clipboard = require(${JSON.stringify(clipboardPackagePath)});`,
      'if (typeof clipboard !== "object" || clipboard === null) throw new Error("clipboard addon load failed");',
      `const sdk = await import(${JSON.stringify(
        pathToFileURL(
          resolve(capsule, "app/node_modules/@earendil-works/pi-coding-agent/dist/index.js"),
        ).href,
      )});`,
      `const loader = new sdk.DefaultResourceLoader({cwd: ${JSON.stringify(fixtureRoot)}, agentDir: ${JSON.stringify(fixtureRoot)}, additionalExtensionPaths: [${JSON.stringify(extensionPath)}], noSkills: true, noPromptTemplates: true, noThemes: true, noContextFiles: true});`,
      "await loader.reload({resolveProjectTrust: async () => true});",
      "const loaded = loader.getExtensions();",
      "if (loaded.errors.length !== 0 || loaded.extensions.length !== 1) throw new Error(JSON.stringify(loaded.errors));",
      "process.stdout.write(JSON.stringify({architecture: process.arch, directNativeAddon: true, clipboardNativeAddon: true, extensionNativeAddon: true}));",
    ].join("\n");
    try {
      const nodeVersion = await runCapturedForArchitecture(
        runtime.executable,
        [...architectureArguments, "--version"],
        architecture,
        { cwd: fixtureRoot, env: environment },
      );
      if (nodeVersion.stdout.trim() !== `v${manifest.versions.node}`) {
        throw new Error(`${architecture} Node startup reported ${nodeVersion.stdout.trim()}.`);
      }
      const npmCli = resolveCapsulePath(capsule, manifest.runtime.npmCli, "runtime npm CLI");
      const npmVersion = await runCapturedForArchitecture(
        runtime.executable,
        [...architectureArguments, npmCli, "--version"],
        architecture,
        { cwd: fixtureRoot, env: environment },
      );
      if (npmVersion.stdout.trim() !== manifest.versions.npm) {
        throw new Error(`${architecture} npm startup reported ${npmVersion.stdout.trim()}.`);
      }
      const result = await runCapturedForArchitecture(
        runtime.executable,
        [...architectureArguments, "--input-type=module", "--eval", fixtureScript],
        architecture,
        { cwd: fixtureRoot, env: environment },
      );
      const loaded = JSON.parse(result.stdout);
      if (loaded.architecture !== architecture) {
        throw new Error(
          `Architecture fixture requested ${architecture} but Node reported ${loaded.architecture}.`,
        );
      }
      fixtures.push({
        ...loaded,
        nodeVersion: nodeVersion.stdout.trim(),
        npmVersion: npmVersion.stdout.trim(),
        piTuiAddon: piTuiAddon.path,
        clipboardAddon: clipboardAddon.path,
      });
    } finally {
      await rm(fixtureRoot, { recursive: true, force: true });
    }
  }
  return fixtures;
}

async function runPortableNativeAddonFixture(capsule, manifest, runtime) {
  const architecture = manifest.target.architectures[0];
  const clipboardAddon = manifest.nativeCode.objects.find(
    (entry) =>
      entry.kind === "native-addon" &&
      entry.path.includes("@mariozechner/clipboard-") &&
      entry.architectures.length === 1 &&
      entry.architectures[0] === architecture,
  );
  if (!clipboardAddon) {
    throw new Error(`Capsule is missing the ${manifest.target.id} clipboard native addon.`);
  }
  const piTuiAddon = manifest.nativeCode.objects.find(
    (entry) =>
      entry.kind === "native-addon" &&
      entry.path.includes("@earendil-works/pi-tui/native/win32/prebuilds/win32-x64/") &&
      entry.architectures.length === 1 &&
      entry.architectures[0] === architecture,
  );
  if (manifest.target.platform === "win32" && !piTuiAddon) {
    throw new Error("Windows Capsule is missing the x64 Pi TUI console-mode addon.");
  }
  const clipboardPackage = resolve(capsule, "app/node_modules/@mariozechner/clipboard/index.js");
  const fixtureScript = [
    'import { createRequire } from "node:module";',
    "const require = createRequire(import.meta.url);",
    `const clipboard = require(${JSON.stringify(clipboardPackage)});`,
    'if (typeof clipboard.getText !== "function") throw new Error("clipboard addon API missing");',
    ...(piTuiAddon
      ? [
          `const consoleMode = require(${JSON.stringify(resolveCapsulePath(capsule, piTuiAddon.path, "Pi TUI native addon"))});`,
          'if (typeof consoleMode.enableVirtualTerminalInput !== "function") throw new Error("Pi TUI addon API missing");',
        ]
      : []),
    "process.stdout.write(JSON.stringify({architecture: process.arch, clipboardNativeAddon: true, piTuiNativeAddon: " +
      `${Boolean(piTuiAddon)}}));`,
  ].join("\n");
  const result = await runCaptured(
    runtime.executable,
    [...runtime.runtimeArguments, "--input-type=module", "--eval", fixtureScript],
    { cwd: capsule, env: runtime.isolatedEnvironment },
  );
  const loaded = JSON.parse(result.stdout);
  if (loaded.architecture !== architecture) {
    throw new Error(
      `Native addon fixture expected ${architecture}; Node reported ${loaded.architecture}.`,
    );
  }
  return {
    ...loaded,
    clipboardAddon: clipboardAddon.path,
    piTuiAddon: piTuiAddon?.path ?? null,
  };
}

function runCapturedForArchitecture(executable, arguments_, architecture, options) {
  if (process.platform !== "darwin") return runCaptured(executable, arguments_, options);
  const archName = architecture === "x64" ? "x86_64" : architecture;
  return runCaptured("/usr/bin/arch", [`-${archName}`, executable, ...arguments_], options);
}

function spawnArchitectureSync(executable, arguments_, architecture) {
  const archName = architecture === "x64" ? "x86_64" : architecture;
  return spawnSync("/usr/bin/arch", [`-${archName}`, executable, ...arguments_], {
    stdio: "ignore",
  });
}

async function runRuntimeProtocolE2e(capsule, capsuleManifest, runtime) {
  const verificationRoot = resolve(tmpdir(), `pi-e2e-${process.pid}-${randomUUID().slice(0, 8)}`);
  const cwd = resolve(verificationRoot, "project");
  const agentDir = resolve(verificationRoot, "agent");
  const sessionDir = resolve(verificationRoot, "sessions");
  const home = resolve(verificationRoot, "home");
  const temporary = resolve(verificationRoot, "tmp");
  const toolBin = resolve(verificationRoot, "tool-bin");
  await Promise.all(
    [cwd, agentDir, sessionDir, home, temporary, toolBin].map((path) =>
      mkdir(path, { recursive: true }),
    ),
  );
  let gitDirectory = toolBin;
  if (process.platform === "darwin" || process.platform === "linux") {
    await symlink("/usr/bin/git", resolve(toolBin, "git"));
  } else if (process.platform === "win32") {
    const locatedGit = spawnSync("where.exe", ["git.exe"], { encoding: "utf8" });
    if (locatedGit.status !== 0) throw new Error("Windows runtime E2E requires Git for Windows.");
    gitDirectory = dirname(locatedGit.stdout.split(/\r?\n/u).find(Boolean));
  }
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
    PATH: `${runtime.runtimeBin}${delimiter}${gitDirectory}`,
  };
  assert.equal(environment.PATH, `${runtime.runtimeBin}${delimiter}${gitDirectory}`);
  const piSdkUrl = pathToFileURL(
    resolve(capsule, "app/node_modules/@earendil-works/pi-coding-agent/dist/index.js"),
  ).href;
  const trustScript = [
    `const sdk = await import(${JSON.stringify(piSdkUrl)});`,
    `new sdk.ProjectTrustStore(${JSON.stringify(agentDir)}).set(${JSON.stringify(cwd)}, true);`,
  ].join("\n");
  await runCaptured(
    runtime.executable,
    [...runtime.runtimeArguments, "--input-type=module", "--eval", trustScript],
    {
      cwd,
      env: environment,
    },
  );

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
    runtimeArguments: runtime.runtimeArguments,
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
          protocol.Capability.PROJECT_DISCOVERY,
          protocol.Capability.PROJECT_TRUST,
        ],
        clientInstanceId: "runtime-capsule-verifier",
        implementationName: "Pi Client Runtime Capsule Verifier",
        implementationVersion: capsuleManifest.versions.piNode,
        maxFrameBytes: protocol.MAX_FRAME_BYTES,
        maxTransferChunkBytes: protocol.MAX_TRANSFER_CHUNK_BYTES,
      },
    });
    expectOperation(await client.next(), "serverHandshakeAccepted");

    await client.send(2n, {
      case: "getProjectBootstrapRequest",
      value: { requestId: 1n },
    });
    const bootstrap = await client.next();
    expectOperation(bootstrap, "getProjectBootstrapResponse");
    const projectId = bootstrap.operation.value.defaultProject?.identity?.projectId;
    assert.equal(typeof projectId, "string");
    assert.notEqual(projectId.length, 0);

    await client.send(3n, {
      case: "listSessionsRequest",
      value: { requestId: 2n, projectId },
    });
    const listed = await client.next();
    expectOperation(listed, "listSessionsResponse");

    await client.send(4n, {
      case: "createSessionRequest",
      value: { requestId: 3n, projectId },
    });
    const created = await client.next(30_000);
    expectOperation(created, "createSessionResponse");
    const sessionId = created.operation.value.session?.summary?.sessionId;
    assert.equal(typeof sessionId, "string");
    assert.notEqual(sessionId.length, 0);

    await client.send(5n, {
      case: "getSessionRequest",
      value: { requestId: 4n, sessionId, projectId },
    });
    const loaded = await client.next(30_000);
    expectOperation(loaded, "getSessionResponse");
    assert.equal(loaded.operation.value.session?.summary?.sessionId, sessionId);

    client.endInput();
    const exit = await client.exit(30_000);
    assert.deepEqual(exit, { code: 0, signal: null });
    assert.match(client.stderrText, /handshake-accepted/u);
    return {
      handshake: "accepted",
      bootstrap: bootstrap.operation.case,
      list: listed.operation.case,
      create: created.operation.case,
      get: loaded.operation.case,
      childExitCode: exit.code,
      systemNodeExcludedFromPath: true,
      projectTrust: "explicit-synthetic-project-approval",
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
      [
        ...options.runtimeArguments,
        options.entrypoint,
        "--cwd",
        options.cwd,
        "--agent-dir",
        options.agentDir,
      ],
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

function expectOperation(frame, expectedCase) {
  if (frame.operation.case === expectedCase) {
    return;
  }
  const error = frame.operation.value?.error;
  const detail = error
    ? ` stable error code ${error.code}: ${error.safeMessage}`
    : ` operation ${frame.operation.case}`;
  throw new Error(`Expected ${expectedCase}; received${detail}.`);
}

function asError(error) {
  return error instanceof Error ? error : new Error("Unknown capsule protocol failure.");
}

await main();
