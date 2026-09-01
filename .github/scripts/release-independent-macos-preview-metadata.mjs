#!/usr/bin/env node

import { appendFile, readFile } from "node:fs/promises";
import { resolve } from "node:path";

import { resolveMacosArchitectureStrategy } from "../../node/scripts/macos-architecture-strategy.mjs";

const repositoryRoot = resolve(import.meta.dirname, "../..");
const [nodePackage, protocolPackage] = await Promise.all([
  readPackage("node/package.json"),
  readPackage("protocol/package.json"),
]);
const expectedDevelopmentVersion = "0.2.0-dev.0";
if (
  nodePackage.version !== expectedDevelopmentVersion ||
  protocolPackage.version !== expectedDevelopmentVersion
) {
  throw new Error(
    `The next independent preview requires node and protocol ${expectedDevelopmentVersion}.`,
  );
}

const releaseVersion = "0.1.0";
const buildNumber = "3";
const architecture = resolveMacosArchitectureStrategy();
const tag = `v${releaseVersion}`;
const asset = `Pi-Client-${releaseVersion}-macOS-${architecture.asset}-ad-hoc-preview.zip`;
const checksumAsset = `${asset}.sha256`;
const capsuleDirectory = `build/pi-node-runtime-capsule-${architecture.capsuleTarget}`;
const metadata = {
  version: releaseVersion,
  buildNumber,
  tag,
  asset,
  checksumAsset,
  capsuleTarget: architecture.capsuleTarget,
  capsuleDirectory,
  appArchitectures: architecture.xcodeArchitectures,
  architectures: architecture.architectures,
  architecture: architecture.asset,
  universal: architecture.universal,
  architectureEvidence: architecture.evidence,
  signingKind: "ad-hoc",
};

const outputArgument = process.argv.indexOf("--github-output");
if (outputArgument !== -1) {
  const outputPath = process.argv[outputArgument + 1];
  if (!outputPath) throw new Error("--github-output requires a path.");
  await appendFile(
    outputPath,
    `${Object.entries(metadata)
      .map(([key, value]) => `${key}=${value}`)
      .join("\n")}\n`,
  );
}
process.stdout.write(`${JSON.stringify(metadata, null, 2)}\n`);

async function readPackage(path) {
  return JSON.parse(await readFile(resolve(repositoryRoot, path), "utf8"));
}
