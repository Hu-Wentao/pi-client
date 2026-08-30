import assert from "node:assert/strict";
import { mkdir, mkdtemp, rm, symlink, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import test from "node:test";

import {
  createCapsuleManifest,
  stripTrailingCommas,
  validateManifestDocument,
  verifyPayloadIntegrity,
} from "../scripts/runtime-capsule-lib.mjs";
import {
  NODE_RUNTIME_VERSION,
  resolveNodeDistribution,
} from "../scripts/runtime-capsule-config.mjs";

const repositoryRoot = resolve(new URL("../..", import.meta.url).pathname);
const testTempRoot = resolve(repositoryRoot, "build/temp/runtime-capsule-tests");

const targetExpectations = {
  "darwin-arm64": {
    archive: `node-v${NODE_RUNTIME_VERSION}-darwin-arm64.tar.gz`,
    sha256: "c59006db713c770d6ec63ae16cb3edc11f49ee093b5c415d667bb4f436c6526d",
    executable: "runtime/bin/node",
  },
  "darwin-x64": {
    archive: `node-v${NODE_RUNTIME_VERSION}-darwin-x64.tar.gz`,
    sha256: "3cfed4795cd97277559763c5f56e711852d2cc2420bda1cea30c8aa9ac77ce0c",
    executable: "runtime/bin/node",
  },
  "linux-x64": {
    archive: `node-v${NODE_RUNTIME_VERSION}-linux-x64.tar.xz`,
    sha256: "c0649af18e6a24f6fe5535a3e86b341dd49a8e71117c8b68bde973ef834f16f2",
    executable: "runtime/bin/node",
  },
  "win32-x64": {
    archive: `node-v${NODE_RUNTIME_VERSION}-win-x64.zip`,
    sha256: "ea3fad0e67a991d8477d8c01344b56e69c676ccb733f065b22436994b1253f86",
    executable: "runtime/node.exe",
  },
};

for (const [targetId, expected] of Object.entries(targetExpectations)) {
  test(`official Node archive mapping is immutable for ${targetId}`, () => {
    const target = resolveNodeDistribution(targetId);
    assert.equal(target.archiveName, expected.archive);
    assert.equal(target.archiveUrl, `https://nodejs.org/dist/v22.19.0/${expected.archive}`);
    assert.equal(target.archiveSha256, expected.sha256);
    assert.equal(target.executable, expected.executable);
  });
}

test("archive mapping rejects unsupported targets", () => {
  assert.throws(
    () => resolveNodeDistribution("linux-arm64"),
    /Unsupported Pi Node capsule target/u,
  );
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

test("payload verification rejects hash tampering", async (t) => {
  const fixture = await createFixture(t);
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

async function createFixture(t) {
  await mkdir(testTempRoot, { recursive: true });
  const root = await mkdtemp(resolve(testTempRoot, "fixture-"));
  t.after(() => rm(root, { recursive: true, force: true }));
  await writeFile(resolve(root, "payload.txt"), "sealed\n", "utf8");
  const target = resolveNodeDistribution("darwin-arm64");
  const manifest = await createCapsuleManifest(root, {
    sourceCommit: "a".repeat(40),
    target,
    piNodeVersion: "0.1.0-dev.0",
    protocolVersion: "0.1.0-dev.0",
    npmVersion: "10.9.3",
    nodeLockSha256: "b".repeat(64),
    protocolLockSha256: "c".repeat(64),
    archiveSha256: target.archiveSha256,
    checksumsSha256: "e".repeat(64),
  });
  validateManifestDocument(manifest);
  return { root, manifest };
}
