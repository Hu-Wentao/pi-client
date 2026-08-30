import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import test from "node:test";

const repositoryRoot = resolve(new URL("../..", import.meta.url).pathname);

const entitlementKeys = (xml) =>
  [...xml.matchAll(/<key>([^<]+)<\/key>/gu)].map((match) => match[1]).sort();

test("Release app and Pi Node entitlements remain least-privilege", async () => {
  const [app, adHocApp, node, adHocNode] = await Promise.all([
    readFile(resolve(repositoryRoot, "macos/Runner/Release.entitlements"), "utf8"),
    readFile(resolve(repositoryRoot, "macos/Runner/ReleaseAdHoc.entitlements"), "utf8"),
    readFile(resolve(repositoryRoot, "macos/Runner/PiNode.entitlements"), "utf8"),
    readFile(resolve(repositoryRoot, "macos/Runner/PiNodeAdHoc.entitlements"), "utf8"),
  ]);
  assert.deepEqual(entitlementKeys(app), []);
  assert.deepEqual(entitlementKeys(adHocApp), ["com.apple.security.cs.disable-library-validation"]);
  assert.deepEqual(entitlementKeys(node), [
    "com.apple.security.cs.allow-jit",
    "com.apple.security.cs.allow-unsigned-executable-memory",
  ]);
  assert.deepEqual(entitlementKeys(adHocNode), [
    "com.apple.security.cs.allow-jit",
    "com.apple.security.cs.allow-unsigned-executable-memory",
    "com.apple.security.cs.disable-library-validation",
  ]);
});

test("signing tools and workflow never rely on codesign deep traversal", async () => {
  const paths = [
    "node/scripts/macos-code-signing-lib.mjs",
    "node/scripts/sign-macos-app.mjs",
    "node/scripts/verify-macos-app-code-signing.mjs",
    ".github/workflows/release-macos.yml",
  ];
  for (const path of paths) {
    const source = await readFile(resolve(repositoryRoot, path), "utf8");
    assert.doesNotMatch(source, /codesign[^\n]*--deep|--deep[^\n]*codesign/u, path);
  }
});
