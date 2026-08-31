import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import test from "node:test";

const repositoryRoot = resolve(new URL("../..", import.meta.url).pathname);

test("desktop release metadata binds platform assets to the exact source commit", () => {
  const result = spawnSync(
    process.execPath,
    [
      resolve(repositoryRoot, "tool/desktop_release_metadata.mjs"),
      "--platform",
      "windows",
      "--architecture",
      "x64",
      "--channel",
      "candidate",
    ],
    { cwd: repositoryRoot, encoding: "utf8" },
  );
  assert.equal(result.status, 0, result.stderr);
  const metadata = JSON.parse(result.stdout);
  assert.match(metadata.sourceCommit, /^[0-9a-f]{40}$/u);
  assert.equal(metadata.capsuleTarget, "win32-x64");
  assert.match(metadata.installerAsset, /Windows-x64-setup\.exe$/u);
});

test("stable packaging fails closed without signing credentials", () => {
  const environment = { ...process.env };
  for (const name of [
    "WINDOWS_SIGNING_CERTIFICATE_BASE64",
    "WINDOWS_SIGNING_CERTIFICATE_PASSWORD",
  ]) {
    delete environment[name];
  }
  const result = spawnSync(
    process.execPath,
    [
      resolve(repositoryRoot, "tool/require_desktop_signing.mjs"),
      "--platform",
      "windows",
      "--channel",
      "stable",
    ],
    { cwd: repositoryRoot, env: environment, encoding: "utf8" },
  );
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /requires signing credentials/u);
});

test("candidate packaging truthfully records absent signing credentials", () => {
  const environment = { ...process.env };
  delete environment.LINUX_GPG_PRIVATE_KEY_BASE64;
  delete environment.LINUX_GPG_PASSPHRASE;
  const result = spawnSync(
    process.execPath,
    [
      resolve(repositoryRoot, "tool/require_desktop_signing.mjs"),
      "--platform",
      "linux",
      "--channel",
      "candidate",
    ],
    { cwd: repositoryRoot, env: environment, encoding: "utf8" },
  );
  assert.equal(result.status, 0, result.stderr);
  assert.equal(JSON.parse(result.stdout).credentialsAvailable, false);
});

test("Windows installer definition owns shortcuts and uninstall metadata", async () => {
  const definition = await readFile(
    resolve(repositoryRoot, "packaging/windows/pi-client.iss"),
    "utf8",
  );
  for (const evidence of [
    "CreateUninstallRegKey=yes",
    "UninstallDisplayIcon={app}\\pi_client.exe",
    "{autoprograms}\\Pi Client",
    "recursesubdirs createallsubdirs",
  ]) {
    assert.match(definition, new RegExp(escapeRegExp(evidence), "u"));
  }
});

test("desktop build integration and production locator use fixed Capsule layouts", async () => {
  const [windowsCmake, linuxCmake, locator] = await Promise.all([
    readFile(resolve(repositoryRoot, "windows/CMakeLists.txt"), "utf8"),
    readFile(resolve(repositoryRoot, "linux/CMakeLists.txt"), "utf8"),
    readFile(
      resolve(repositoryRoot, "lib/platform/agent_host/pi_node_runtime_locator_io.dart"),
      "utf8",
    ),
  ]);
  assert.ok(windowsCmake.includes("${CMAKE_INSTALL_PREFIX}/PiNode"));
  assert.ok(linuxCmake.includes("${INSTALL_BUNDLE_LIB_DIR}/pi-client/PiNode"));
  assert.match(locator, /executable\.parent\.path.*PiNode/su);
  assert.match(locator, /lib.*pi-client.*PiNode/su);
  assert.doesNotMatch(locator, /Process\.run\([^)]*["']node["']/u);
});

test("Linux package definitions own desktop and pinned native tooling metadata", async () => {
  const [desktop, appRun, toolchain] = await Promise.all([
    readFile(
      resolve(repositoryRoot, "packaging/linux/io.github.huwentao.pi_client.desktop"),
      "utf8",
    ),
    readFile(resolve(repositoryRoot, "packaging/linux/AppRun"), "utf8"),
    readFile(resolve(repositoryRoot, "packaging/toolchain.json"), "utf8").then(JSON.parse),
  ]);
  assert.match(desktop, /^Exec=pi-client$/mu);
  assert.match(desktop, /^Categories=Development;Utility;$/mu);
  assert.match(appRun, /usr\/lib\/pi-client\/pi_client/u);
  assert.match(toolchain.appImageTool.architectures.x64.sha256, /^[0-9a-f]{64}$/u);
  assert.match(toolchain.appImageTool.architectures.arm64.sha256, /^[0-9a-f]{64}$/u);
  assert.match(toolchain.innoSetup.sha256, /^[0-9a-f]{64}$/u);
  assert.equal(toolchain.syft.version, "1.51.1");
});

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}
