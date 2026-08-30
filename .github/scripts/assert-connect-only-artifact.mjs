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

const repositoryRoot = resolve(
  dirname(fileURLToPath(import.meta.url)),
  "../..",
);
const supportedPlatforms = new Set(["android", "ios", "web"]);
const platform = process.argv[2];
const artifactRoot = resolve(process.argv[3] ?? "");

if (!supportedPlatforms.has(platform) || process.argv.length !== 4) {
  console.error(
    "Usage: node .github/scripts/assert-connect-only-artifact.mjs <android|ios|web> <artifact-directory>",
  );
  process.exit(2);
}

if (!existsSync(artifactRoot) || !lstatSync(artifactRoot).isDirectory()) {
  throw new Error(`Artifact directory does not exist: ${artifactRoot}`);
}

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
  web: ["pubspec.yaml", "web/index.html", "web/manifest.json"],
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

for (const repositoryPath of packagingFiles[platform]) {
  const absolutePath = resolve(repositoryRoot, repositoryPath);
  if (!existsSync(absolutePath)) {
    throw new Error(
      `Required packaging configuration is missing: ${repositoryPath}`,
    );
  }
  const content = readFileSync(absolutePath, "utf8");
  checkValue(`source:${repositoryPath}`, content, forbiddenPackagingReferences);
}

if (violations.length > 0) {
  throw new Error(
    `Connect-only ${platform} packaging boundary violations:\n${violations.join("\n")}`,
  );
}

console.log(
  `Connect-only ${platform} scan passed for ${artifactEntryCount} artifact entries and ${packagingFiles[platform].length} packaging files.`,
);
console.log(
  "Bounded guarantee: no declared or path-visible Node/Pi Node sidecar is packaged; renamed or binary-embedded runtimes require a stronger future artifact manifest.",
);

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
