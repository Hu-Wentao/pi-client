import assert from "node:assert/strict";
import { access, mkdir, mkdtemp, readFile, rm, stat, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import test from "node:test";

import {
  installRuntimeCapsuleInMacosApp,
  removeRuntimeCapsuleFromMacosApp,
  resolveMacosAppCapsulePath,
  verifyInstalledRuntimeCapsule,
} from "../scripts/macos-app-runtime-capsule-lib.mjs";

test("installs a verified capsule at the fixed macOS app-bundle layout", async (t) => {
  const fixture = await createFixture(t);
  const verified = [];
  const verifyCapsule = async (capsuleRoot, expectedSourceCommit) => {
    const manifest = JSON.parse(
      await readFile(resolve(capsuleRoot, "capsule-manifest.json"), "utf8"),
    );
    assert.equal(manifest.sourceCommit, expectedSourceCommit);
    verified.push(capsuleRoot);
  };

  const installed = await installRuntimeCapsuleInMacosApp({
    appBundle: fixture.app,
    capsuleRoot: fixture.capsule,
    expectedSourceCommit: fixture.sourceCommit,
    verifyCapsule,
  });

  assert.equal(installed.capsulePath, resolve(fixture.app, "Contents/Helpers/PiNode"));
  assert.equal(installed.layout, "Contents/Helpers/PiNode");
  assert.equal(installed.sourceCommit, fixture.sourceCommit);
  assert.deepEqual(verified, [fixture.capsule, resolve(fixture.app, "Contents/Helpers/PiNode")]);
  assert.equal(
    await readFile(resolve(installed.capsulePath, "runtime/bin/node"), "utf8"),
    "node\n",
  );
  const installedMode = (await stat(resolve(installed.capsulePath, "runtime/bin/node"))).mode;
  assert.equal(installedMode & 0o222, 0);
  assert.notEqual(installedMode & 0o111, 0);

  const verifiedInstalled = await verifyInstalledRuntimeCapsule({
    appBundle: fixture.app,
    expectedSourceCommit: fixture.sourceCommit,
    verifyCapsule,
  });
  assert.equal(verifiedInstalled.capsulePath, installed.capsulePath);

  await removeRuntimeCapsuleFromMacosApp(fixture.app);
  await assert.rejects(access(installed.capsulePath));
});

test("removes a failed installed copy instead of leaving mutable runtime bytes", async (t) => {
  const fixture = await createFixture(t);
  let verificationCount = 0;
  await assert.rejects(
    installRuntimeCapsuleInMacosApp({
      appBundle: fixture.app,
      capsuleRoot: fixture.capsule,
      expectedSourceCommit: fixture.sourceCommit,
      verifyCapsule: async () => {
        verificationCount += 1;
        if (verificationCount == 2) {
          throw new Error("installed capsule rejected");
        }
      },
    }),
    /installed capsule rejected/u,
  );
  await assert.rejects(access(resolveMacosAppCapsulePath(fixture.app)));
});

async function createFixture(t) {
  const root = await mkdtemp(resolve(tmpdir(), "pi-client-macos-capsule-"));
  t.after(() => rm(root, { recursive: true, force: true }));
  const app = resolve(root, "Pi Client.app");
  const capsule = resolve(root, "capsule");
  await Promise.all([
    mkdir(resolve(app, "Contents"), { recursive: true }),
    mkdir(resolve(capsule, "runtime/bin"), { recursive: true }),
    mkdir(resolve(capsule, "app/dist"), { recursive: true }),
  ]);
  await writeFile(resolve(capsule, "runtime/bin/node"), "node\n", { mode: 0o755 });
  await writeFile(resolve(capsule, "app/dist/stdio-main.js"), "entrypoint\n");
  const sourceCommit = "a".repeat(40);
  await writeFile(
    resolve(capsule, "capsule-manifest.json"),
    `${JSON.stringify({
      sourceCommit,
      target: { id: "darwin-arm64" },
      runtime: { executable: "runtime/bin/node" },
      application: { entrypoint: "app/dist/stdio-main.js" },
      integrity: { payloadFileCount: 2, payloadSize: 16 },
    })}\n`,
  );
  return { root, app, capsule, sourceCommit };
}
