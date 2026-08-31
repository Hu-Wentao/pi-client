import assert from "node:assert/strict";
import { chmod, copyFile, mkdir, mkdtemp, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, resolve } from "node:path";
import test from "node:test";

import {
  assertCapsuleFileModes,
  createCapsuleManifest,
  inspectNativeBinaryBytes,
  makeTreeReadOnly,
  normalizeCapsuleFileModes,
  removeTreeEvenIfReadOnly,
  stripTrailingCommas,
  validateManifestDocument,
  verifyPayloadIntegrity,
  writeDeterministicJson,
} from "../scripts/runtime-capsule-lib.mjs";
import {
  NODE_RUNTIME_VERSION,
  currentCapsuleTargetId,
  resolveNodeDistribution,
} from "../scripts/runtime-capsule-config.mjs";

const repositoryRoot = resolve(new URL("../..", import.meta.url).pathname);
const testTempRoot = resolve(repositoryRoot, "build/temp/runtime-capsule-tests");

const targetExpectations = {
  "darwin-arm64": {
    architecture: "arm64",
    archive: `node-v${NODE_RUNTIME_VERSION}-darwin-arm64.tar.gz`,
    sha256: "c59006db713c770d6ec63ae16cb3edc11f49ee093b5c415d667bb4f436c6526d",
  },
  "darwin-x64": {
    architecture: "x64",
    archive: `node-v${NODE_RUNTIME_VERSION}-darwin-x64.tar.gz`,
    sha256: "3cfed4795cd97277559763c5f56e711852d2cc2420bda1cea30c8aa9ac77ce0c",
  },
  "linux-arm64": {
    architecture: "arm64",
    archive: `node-v${NODE_RUNTIME_VERSION}-linux-arm64.tar.xz`,
    sha256: "0b2d9f564b6594222a62c82e1df2efe119dd4a4aff29644f4dd325bf360b6bcc",
  },
  "linux-x64": {
    architecture: "x64",
    archive: `node-v${NODE_RUNTIME_VERSION}-linux-x64.tar.xz`,
    sha256: "c0649af18e6a24f6fe5535a3e86b341dd49a8e71117c8b68bde973ef834f16f2",
  },
  "win32-x64": {
    architecture: "x64",
    archive: `node-v${NODE_RUNTIME_VERSION}-win-x64.zip`,
    sha256: "ea3fad0e67a991d8477d8c01344b56e69c676ccb733f065b22436994b1253f86",
  },
};

for (const [targetId, expected] of Object.entries(targetExpectations)) {
  test(`official Node archive mapping is immutable for ${targetId}`, () => {
    const target = resolveNodeDistribution(targetId);
    assert.deepEqual(target.architectures, [expected.architecture]);
    assert.equal(target.distributions.length, 1);
    assert.equal(target.distributions[0].archiveName, expected.archive);
    assert.equal(
      target.distributions[0].archiveUrl,
      `https://nodejs.org/dist/v22.19.0/${expected.archive}`,
    );
    assert.equal(target.distributions[0].archiveSha256, expected.sha256);
  });
}

test("Universal macOS target preserves both official architecture archives", () => {
  const target = resolveNodeDistribution("darwin-universal");
  assert.equal(target.architecture, "universal");
  assert.deepEqual(target.architectures, ["arm64", "x64"]);
  assert.deepEqual(
    target.distributions.map((entry) => entry.id),
    ["darwin-arm64", "darwin-x64"],
  );
  assert.equal(target.executable, "runtime/bin/node");
});

test("archive mapping rejects unsupported targets", () => {
  assert.throws(
    () => resolveNodeDistribution("linux-riscv64"),
    /Unsupported Pi Node capsule target/u,
  );
});

test("portable native binary inspection recognizes ELF and PE architectures", () => {
  const elfX64 = Buffer.alloc(64);
  Buffer.from([0x7f, 0x45, 0x4c, 0x46]).copy(elfX64);
  elfX64[5] = 1;
  elfX64.writeUInt16LE(0x3e, 18);
  assert.deepEqual(inspectNativeBinaryBytes(elfX64), {
    format: "elf",
    architectures: ["x64"],
  });

  const peArm64 = Buffer.alloc(256);
  peArm64.write("MZ", 0, "binary");
  peArm64.writeUInt32LE(128, 0x3c);
  peArm64.write("PE\0\0", 128, "binary");
  peArm64.writeUInt16LE(0xaa64, 132);
  assert.deepEqual(inspectNativeBinaryBytes(peArm64), {
    format: "pe-coff",
    architectures: ["arm64"],
  });
});

test("Bun lock parsing removes only trailing commas outside strings", () => {
  const parsed = JSON.parse(
    stripTrailingCommas('{"value":"literal,}","array":[1,2,],"object":{"ok":true,},}'),
  );
  assert.deepEqual(parsed, {
    value: "literal,}",
    array: [1, 2],
    object: { ok: true },
  });
});

test("manifest validation rejects unexpected mutable fields", async (t) => {
  const fixture = await createFixture(t);
  fixture.manifest.mutableFiles = ["app/package.json"];
  assert.throws(() => validateManifestDocument(fixture.manifest), /missing or unexpected fields/u);
});

test("manifest validation rejects absolute entrypoint tampering", async (t) => {
  const fixture = await createFixture(t);
  fixture.manifest.application.entrypoint = "/tmp/injected-entrypoint.js";
  assert.throws(() => validateManifestDocument(fixture.manifest), /application entrypoint/u);
});

test("manifest validation rejects traversal path tampering", async (t) => {
  const fixture = await createFixture(t);
  fixture.manifest.integrity.files[0].path = "../payload.txt";
  assert.throws(() => validateManifestDocument(fixture.manifest), /forbidden path segment/u);
});

test("manifest validation rejects executable-bit expansion", async (t) => {
  const fixture = await createFixture(t);
  const payload = fixture.manifest.integrity.files.find((entry) => entry.path === "payload.txt");
  payload.executable = true;
  assert.throws(() => validateManifestDocument(fixture.manifest), /executable-mode allowlist/u);
});

test("manifest validation rejects native signing-order tampering", async (t) => {
  if (process.platform !== "darwin") return;
  const fixture = await createFixture(t);
  fixture.manifest.nativeCode.signingOrder.reverse();
  assert.throws(
    () => validateManifestDocument(fixture.manifest),
    /deterministic inside-out order/u,
  );
});

test("payload verification rejects hash tampering", async (t) => {
  const fixture = await createFixture(t);
  await chmod(resolve(fixture.root, "payload.txt"), 0o644);
  await writeFile(resolve(fixture.root, "payload.txt"), "tampered\n", "utf8");
  await assert.rejects(
    verifyPayloadIntegrity(fixture.root, fixture.manifest),
    /payload integrity mismatch/u,
  );
});

test("payload verification rejects mutable unlisted files", async (t) => {
  const fixture = await createFixture(t);
  await writeFile(resolve(fixture.root, "unlisted.txt"), "mutable\n", "utf8");
  await assert.rejects(
    verifyPayloadIntegrity(fixture.root, fixture.manifest),
    /payload inventory changed/u,
  );
});

test("payload verification rejects symlink escape", async (t) => {
  const fixture = await createFixture(t);
  const outside = resolve(fixture.root, "../outside.txt");
  await writeFile(outside, "outside\n", "utf8");
  t.after(() => rm(outside, { force: true }));
  await symlink(outside, resolve(fixture.root, "escape"));
  await assert.rejects(
    verifyPayloadIntegrity(fixture.root, fixture.manifest),
    /absolute target|escapes its root directory/u,
  );
});

test("mode normalization leaves only Node executable and all data read-only", async (t) => {
  const fixture = await createFixture(t);
  await writeDeterministicJson(resolve(fixture.root, "capsule-manifest.json"), fixture.manifest);
  await normalizeCapsuleFileModes(fixture.root, fixture.target.executable);
  await makeTreeReadOnly(fixture.root);
  await assertCapsuleFileModes(fixture.root, fixture.target.executable);
});

async function createFixture(t) {
  await mkdir(testTempRoot, { recursive: true });
  const root = await mkdtemp(resolve(testTempRoot, "fixture-"));
  t.after(() => removeTreeEvenIfReadOnly(root));
  const target = resolveNodeDistribution(currentCapsuleTargetId());
  const runtimeExecutable = resolve(root, ...target.executable.split("/"));
  await mkdir(dirname(runtimeExecutable), { recursive: true });
  await copyFile(process.execPath, runtimeExecutable);
  if (process.platform === "darwin") {
    await mkdir(resolve(root, "app/native"), { recursive: true });
    await copyFile(process.execPath, resolve(root, "app/native/fixture.node"));
  }
  await writeFile(resolve(root, "payload.txt"), "sealed\n", "utf8");
  await normalizeCapsuleFileModes(root, target.executable);
  const manifest = await createCapsuleManifest(root, {
    sourceCommit: "a".repeat(40),
    target,
    piNodeVersion: "0.1.0-dev.0",
    protocolVersion: "0.1.0-dev.0",
    npmVersion: "10.9.3",
    nodeLockSha256: "b".repeat(64),
    protocolLockSha256: "c".repeat(64),
    checksumsSha256: "e".repeat(64),
  });
  validateManifestDocument(manifest);
  return { root, manifest, target };
}
