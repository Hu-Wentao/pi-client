#!/usr/bin/env node

import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { chmod, mkdtemp, readFile, rm, stat, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";

import {
  CAPSULE_MANIFEST_NAME,
  readJson,
  resolveCapsulePath,
  verifyPayloadIntegrity,
} from "./runtime-capsule-lib.mjs";
import {
  MACOS_SIGNING_MANIFEST_RELATIVE_PATH,
  verifyMacosAppCodeSigning,
} from "./macos-code-signing-lib.mjs";
import { resolveMacosAppCapsulePath } from "./macos-app-runtime-capsule-lib.mjs";

if (process.platform !== "darwin") throw new Error("The signing tamper test requires macOS.");
const options = parseArguments(process.argv.slice(2));
await verifyMacosAppCodeSigning({
  appBundle: options.appBundle,
  expectedSourceCommit: options.expectedSourceCommit,
  expectedSigningKind: options.expectedSigningKind,
  gatekeeper: "skip",
});
const capsuleRoot = resolveMacosAppCapsulePath(options.appBundle);
const capsuleManifestPath = resolve(capsuleRoot, CAPSULE_MANIFEST_NAME);
const capsuleManifest = await readJson(capsuleManifestPath);
const signingManifestPath = resolve(
  options.appBundle,
  ...MACOS_SIGNING_MANIFEST_RELATIVE_PATH.split("/"),
);

const dataEntry = capsuleManifest.integrity.files.find(
  (entry) => entry.type === "file" && !entry.executable && entry.path.endsWith(".js"),
);
assert.ok(dataEntry, "Capsule must contain a non-executable JavaScript tamper fixture.");
const dataPath = resolveCapsulePath(capsuleRoot, dataEntry.path);
const dataMode = (await stat(dataPath)).mode & 0o777;
await chmod(dataPath, 0o555);
await assert.rejects(
  verifyPayloadIntegrity(capsuleRoot, capsuleManifest),
  /payload integrity mismatch/u,
);
await chmod(dataPath, dataMode);
await verifyPayloadIntegrity(capsuleRoot, capsuleManifest);

const signingManifestBytes = await readFile(signingManifestPath);
await chmod(signingManifestPath, 0o644);
await writeFile(signingManifestPath, Buffer.concat([signingManifestBytes, Buffer.from("\n")]));
assert.equal(codeSignatureAccepted(options.appBundle), false);
await writeFile(signingManifestPath, signingManifestBytes);
await chmod(signingManifestPath, 0o444);
assert.equal(codeSignatureAccepted(options.appBundle), true);

const nativeAddon = capsuleManifest.nativeCode.objects.find(
  (entry) => entry.kind === "native-addon" && entry.format === "mach-o",
);
assert.ok(nativeAddon, "Capsule must contain a Mach-O native-addon tamper fixture.");
const nativeAddonPath = resolveCapsulePath(capsuleRoot, nativeAddon.path);
const nativeAddonBytes = await readFile(nativeAddonPath);
const nativeAddonMode = (await stat(nativeAddonPath)).mode & 0o777;
await chmod(nativeAddonPath, 0o644);
await writeFile(nativeAddonPath, Buffer.concat([nativeAddonBytes, Buffer.from([0])]));
assert.equal(codeSignatureAccepted(nativeAddonPath), false);
await assert.rejects(
  verifyPayloadIntegrity(capsuleRoot, capsuleManifest),
  /payload integrity mismatch/u,
);
await writeFile(nativeAddonPath, nativeAddonBytes);
await chmod(nativeAddonPath, nativeAddonMode);
assert.equal(codeSignatureAccepted(nativeAddonPath), true);
await verifyPayloadIntegrity(capsuleRoot, capsuleManifest);
assert.equal(codeSignatureAccepted(options.appBundle), true);

process.stdout.write(
  `${JSON.stringify(
    {
      appBundle: options.appBundle,
      fileModeTamperRejected: true,
      signingManifestTamperRejected: true,
      nativeCodeTamperRejected: true,
      restoredSignatureValid: true,
    },
    null,
    2,
  )}\n`,
);

function codeSignatureAccepted(path) {
  const result = spawnSync("/usr/bin/codesign", ["--verify", "--strict", "--verbose=4", path], {
    stdio: "ignore",
  });
  if (result.error) throw result.error;
  return result.status === 0;
}

function parseArguments(arguments_) {
  const values = new Map();
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (!["--app", "--expected-source-commit", "--expected-signing-kind"].includes(argument)) {
      throw new Error(`Unsupported signing tamper-test argument ${argument}.`);
    }
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    values.set(argument, value);
  }
  const appBundle = values.get("--app");
  if (!appBundle) throw new Error("--app is required.");
  return {
    appBundle: resolve(appBundle),
    expectedSourceCommit: values.get("--expected-source-commit"),
    expectedSigningKind: values.get("--expected-signing-kind") ?? "ad-hoc",
  };
}
