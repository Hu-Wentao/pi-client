#!/usr/bin/env node

import {
  existsSync,
  lstatSync,
  readFileSync,
  readdirSync,
  readlinkSync,
} from "node:fs";
import { dirname, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repositoryRoot = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const supportedPlatforms = new Set(["android", "ios", "web", "web-wasm"]);
const platform = process.argv[2];
const artifactRoot = resolve(process.argv[3] ?? "");

if (!supportedPlatforms.has(platform) || process.argv.length !== 4) {
  console.error(
    "Usage: node .github/scripts/assert-connect-only-artifact.mjs <android|ios|web|web-wasm> <artifact-directory>",
  );
  process.exit(2);
}

if (!existsSync(artifactRoot) || !lstatSync(artifactRoot).isDirectory()) {
  throw new Error(`Artifact directory does not exist: ${artifactRoot}`);
}

const platformFamily = platform === "web-wasm" ? "web" : platform;
const packagingFiles = {
  android: [
    "pubspec.yaml",
    "android/settings.gradle.kts",
    "android/app/build.gradle.kts",
    "android/app/src/main/AndroidManifest.xml",
  ],
  ios: [
    "pubspec.yaml",
    "ios/Podfile",
    "ios/Runner/Info.plist",
    "ios/Runner.xcodeproj/project.pbxproj",
  ],
  web: [
    "pubspec.yaml",
    "pubspec.lock",
    "web/index.html",
    "web/manifest.json",
    "lib/core/app_storage.dart",
    "lib/core/app_storage_web.dart",
    "packages/flutter_secure_storage_web_disabled/pubspec.yaml",
  ],
};

const forbiddenArtifactPaths = [
  { label: "Node package directory", pattern: /(^|\/)node_modules(\/|$)/i },
  { label: "Node runtime", pattern: /(^|\/)(?:node|nodejs)(?:\.exe)?(\/|$)/i },
  { label: "Pi Node sidecar", pattern: /(^|\/)pi[-_]?node(?:\.exe)?(\/|$)/i },
  { label: "generic sidecar directory", pattern: /(^|\/)sidecars?(\/|$)/i },
  { label: "Pi Node package", pattern: /@pi-client\/node/i },
];
const forbiddenPackagingReferences = [
  { label: "Node package reference", pattern: /@pi-client[\\/]node/i },
  {
    label: "Node directory reference",
    pattern: /(?:^|[\s"'=:([{])node[\\/]/im,
  },
  { label: "Node executable reference", pattern: /\bnode(?:js)?\.exe\b/i },
  { label: "Pi Node sidecar reference", pattern: /\bpi[-_]node\b/i },
  { label: "sidecar packaging reference", pattern: /\bsidecars?\b/i },
];
const forbiddenWebStorageSourceReferences = [
  { label: "fr_storage import", pattern: /package:fr_storage\//i },
  {
    label: "secure-storage import",
    pattern: /package:flutter_secure_storage(?:_web)?\//i,
  },
  { label: "native path-provider import", pattern: /package:path_provider\//i },
  { label: "native IO import", pattern: /dart:io/i },
  { label: "legacy browser API import", pattern: /dart:(?:html|js|js_util)/i },
];
const forbiddenWebRuntimeReferences = [
  {
    label: "fr_storage runtime",
    pattern: /FrStorage|fr_storage(?:_key_v1|_unsigned_preview)?/i,
  },
  {
    label: "secure-storage runtime",
    pattern: /FlutterSecureStorage|flutter_secure_storage/i,
  },
  {
    label: "native ObjectBox runtime",
    pattern: /objectbox(?:_flutter_libs)?/i,
  },
  {
    label: "desktop Pi Node capsule",
    pattern: /capsule-manifest\.json|PI_CLIENT_NODE_(?:EXECUTABLE|ENTRYPOINT)/i,
  },
];

const violations = [];
let artifactEntryCount = 0;
for (const entry of walk(artifactRoot)) {
  artifactEntryCount += 1;
  const normalizedPath = relative(artifactRoot, entry.path).replaceAll(
    "\\",
    "/",
  );
  checkValue(
    `artifact:${normalizedPath}`,
    normalizedPath,
    forbiddenArtifactPaths,
  );
  if (entry.linkTarget !== null) {
    checkValue(
      `artifact:${normalizedPath}->${entry.linkTarget}`,
      entry.linkTarget.replaceAll("\\", "/"),
      forbiddenArtifactPaths,
    );
  }
}

if (artifactEntryCount === 0) {
  throw new Error(`Artifact directory is empty: ${artifactRoot}`);
}

for (const repositoryPath of packagingFiles[platformFamily]) {
  const absolutePath = resolve(repositoryRoot, repositoryPath);
  if (!existsSync(absolutePath)) {
    throw new Error(
      `Required packaging configuration is missing: ${repositoryPath}`,
    );
  }
  const content = readFileSync(absolutePath, "utf8");
  checkValue(`source:${repositoryPath}`, content, forbiddenPackagingReferences);
}

if (platformFamily === "web") {
  assertWebStorageBoundary();
  scanWebExecutables();
}

if (violations.length > 0) {
  throw new Error(
    `Connect-only ${platform} packaging boundary violations:\n${violations.join("\n")}`,
  );
}

console.log(
  `Connect-only ${platform} scan passed for ${artifactEntryCount} artifact entries and ${packagingFiles[platformFamily].length} packaging files.`,
);
console.log(
  platformFamily === "web"
    ? "Bounded guarantee: no declared Node/Pi Node sidecar, registered secure-storage Web plugin, fr_storage runtime, or known native-host signature is present in the Web executable boundary."
    : "Bounded guarantee: no declared or path-visible Node/Pi Node sidecar is packaged; renamed or binary-embedded runtimes require a stronger future artifact manifest.",
);

function assertWebStorageBoundary() {
  const pluginDependenciesPath = resolve(
    repositoryRoot,
    ".flutter-plugins-dependencies",
  );
  if (!existsSync(pluginDependenciesPath)) {
    throw new Error(
      "Generated Flutter plugin dependencies are missing; run flutter pub get before the Web artifact scan.",
    );
  }

  const pluginDependencies = JSON.parse(
    readFileSync(pluginDependenciesPath, "utf8"),
  );
  const webPlugins = pluginDependencies.plugins?.web ?? [];
  for (const plugin of webPlugins) {
    if (/secure_storage|objectbox/i.test(plugin.name ?? "")) {
      violations.push(
        `generated:.flutter-plugins-dependencies: forbidden Web storage plugin ${plugin.name}`,
      );
    }
  }

  const commonStorageSource = readFileSync(
    resolve(repositoryRoot, "lib/core/app_storage.dart"),
    "utf8",
  );
  if (
    !commonStorageSource.includes("if (dart.library.js_interop)") ||
    !commonStorageSource.includes("app_storage_web.dart")
  ) {
    violations.push(
      "source:lib/core/app_storage.dart: missing explicit Web conditional import",
    );
  }

  const webStorageSource = readFileSync(
    resolve(repositoryRoot, "lib/core/app_storage_web.dart"),
    "utf8",
  );
  checkValue(
    "source:lib/core/app_storage_web.dart",
    webStorageSource,
    forbiddenWebStorageSourceReferences,
  );
  if (!webStorageSource.includes("webNoSecretNoPersistence")) {
    violations.push(
      "source:lib/core/app_storage_web.dart: missing no-secret/no-persistence semantics",
    );
  }

  const disabledPluginManifest = readFileSync(
    resolve(
      repositoryRoot,
      "packages/flutter_secure_storage_web_disabled/pubspec.yaml",
    ),
    "utf8",
  );
  if (/^flutter\s*:/m.test(disabledPluginManifest) || /^\s+plugin\s*:/m.test(disabledPluginManifest)) {
    violations.push(
      "source:packages/flutter_secure_storage_web_disabled/pubspec.yaml: disabled boundary must not declare a Flutter plugin",
    );
  }

  const lockfile = readFileSync(resolve(repositoryRoot, "pubspec.lock"), "utf8");
  if (
    !lockfile.includes('path: "packages/flutter_secure_storage_web_disabled"') ||
    !lockfile.includes('version: "1.2.1+pi-client.no-web.1"')
  ) {
    violations.push(
      "source:pubspec.lock: flutter_secure_storage_web is not pinned to the disabled local boundary",
    );
  }
}

function scanWebExecutables() {
  const requiredExecutables =
    platform === "web-wasm"
      ? ["main.dart.js", "main.dart.mjs", "main.dart.wasm"]
      : ["main.dart.js"];
  for (const artifactPath of requiredExecutables) {
    const absolutePath = resolve(artifactRoot, artifactPath);
    if (!existsSync(absolutePath)) {
      violations.push(`artifact:${artifactPath}: required Web executable missing`);
      continue;
    }
    const content = readFileSync(absolutePath).toString("latin1");
    checkValue(
      `artifact:${artifactPath}`,
      content,
      forbiddenWebRuntimeReferences,
    );
  }
}

function checkValue(location, value, rules) {
  for (const rule of rules) {
    if (rule.pattern.test(value)) {
      violations.push(`${location}: ${rule.label}`);
    }
  }
}

function walk(directory) {
  const entries = [];
  for (const name of readdirSync(directory).sort()) {
    const path = resolve(directory, name);
    const stat = lstatSync(path);
    if (stat.isSymbolicLink()) {
      entries.push({ path, linkTarget: readlinkSync(path) });
    } else if (stat.isDirectory()) {
      entries.push({ path, linkTarget: null });
      entries.push(...walk(path));
    } else {
      entries.push({ path, linkTarget: null });
    }
    if (entries.length > 100_000) {
      throw new Error(
        `Artifact scan exceeded 100000 entries under ${artifactRoot}.`,
      );
    }
  }
  return entries;
}
