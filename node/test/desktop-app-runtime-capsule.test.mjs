import assert from "node:assert/strict";
import { access, mkdir, mkdtemp, readFile, rm, stat, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import test from "node:test";

import {
  installRuntimeCapsuleInDesktopBundle,
  removeRuntimeCapsuleFromDesktopBundle,
  resolveDesktopAppCapsulePath,
  verifyInstalledDesktopRuntimeCapsule,
} from "../scripts/desktop-app-runtime-capsule-lib.mjs";

for (const fixturePlatform of ["windows", "linux"]) {
  test(`installs a verified capsule at the fixed ${fixturePlatform} bundle layout`, async (t) => {
    const fixture = await createFixture(t, fixturePlatform);
    const verified = [];
    const verifyCapsule = async (capsuleRoot, expectedSourceCommit) => {
      const manifest = JSON.parse(
        await readFile(resolve(capsuleRoot, "capsule-manifest.json"), "utf8"),
      );
      assert.equal(manifest.sourceCommit, expectedSourceCommit);
      verified.push(capsuleRoot);
    };

    const installed = await installRuntimeCapsuleInDesktopBundle({
      platform: fixturePlatform,
      bundleRoot: fixture.bundle,
      capsuleRoot: fixture.capsule,
      expectedSourceCommit: fixture.sourceCommit,
      verifyCapsule,
    });

    assert.equal(
      installed.capsulePath,
      resolveDesktopAppCapsulePath(fixturePlatform, fixture.bundle),
    );
    assert.equal(installed.sourceCommit, fixture.sourceCommit);
    assert.equal(verified.length, 2);
    assert.equal(await readFile(resolve(installed.capsulePath, fixture.runtime), "utf8"), "node\n");
    if (process.platform !== "win32") {
      assert.equal(
        (await stat(resolve(installed.capsulePath, fixture.runtime))).mode & 0o777,
        0o555,
      );
    }

    const verifiedInstalled = await verifyInstalledDesktopRuntimeCapsule({
      platform: fixturePlatform,
      bundleRoot: fixture.bundle,
      expectedSourceCommit: fixture.sourceCommit,
      verifyCapsule,
    });
    assert.equal(verifiedInstalled.capsulePath, installed.capsulePath);

    await removeRuntimeCapsuleFromDesktopBundle(fixturePlatform, fixture.bundle);
    await assert.rejects(access(installed.capsulePath));
  });
}

test("rejects a target-platform mismatch before installing bytes", async (t) => {
  const fixture = await createFixture(t, "windows");
  const manifestPath = resolve(fixture.capsule, "capsule-manifest.json");
  const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
  manifest.target.platform = "linux";
  await writeFile(manifestPath, `${JSON.stringify(manifest)}\n`);
  await assert.rejects(
    installRuntimeCapsuleInDesktopBundle({
      platform: "windows",
      bundleRoot: fixture.bundle,
      capsuleRoot: fixture.capsule,
      expectedSourceCommit: fixture.sourceCommit,
      verifyCapsule: async () => {},
    }),
    /cannot be installed/u,
  );
});

async function createFixture(t, platform) {
  const root = await mkdtemp(resolve(tmpdir(), `pi-client-${platform}-capsule-`));
  t.after(() => rm(root, { recursive: true, force: true }));
  const bundle = resolve(root, "bundle");
  const capsule = resolve(root, "capsule");
  const executable = platform === "windows" ? "pi_client.exe" : "pi_client";
  const runtime = platform === "windows" ? "runtime/node.exe" : "runtime/bin/node";
  const targetPlatform = platform === "windows" ? "win32" : "linux";
  await Promise.all([
    mkdir(bundle, { recursive: true }),
    mkdir(resolve(capsule, "app/dist"), { recursive: true }),
    mkdir(resolve(capsule, runtime.split("/").slice(0, -1).join("/")), { recursive: true }),
  ]);
  await writeFile(resolve(bundle, executable), "app\n", { mode: 0o755 });
  await writeFile(resolve(capsule, runtime), "node\n", { mode: 0o755 });
  await writeFile(resolve(capsule, "app/dist/stdio-main.js"), "entrypoint\n");
  const sourceCommit = "a".repeat(40);
  await writeFile(
    resolve(capsule, "capsule-manifest.json"),
    `${JSON.stringify({
      sourceCommit,
      target: { id: platform === "windows" ? "win32-x64" : "linux-x64", platform: targetPlatform },
      runtime: { executable: runtime },
      application: { entrypoint: "app/dist/stdio-main.js" },
      integrity: { payloadFileCount: 2, payloadSize: 16 },
    })}\n`,
  );
  return { root, bundle, capsule, sourceCommit, runtime };
}
