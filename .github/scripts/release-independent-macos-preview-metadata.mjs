#!/usr/bin/env node

import { appendFile, readFile } from "node:fs/promises";
import { resolve } from "node:path";

const repositoryRoot = resolve(import.meta.dirname, "../..");
const [nodePackage, protocolPackage] = await Promise.all([
  readPackage("node/package.json"),
  readPackage("protocol/package.json"),
]);
const expectedDevelopmentVersion = "0.1.0-dev.0";
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
const architecture = resolveArchitecture(process.platform, process.arch);
const tag = `v${releaseVersion}`;
const asset = `Pi-Client-${releaseVersion}-macOS-${architecture.asset}-unsigned-preview.zip`;
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
  appArchitecture: architecture.xcode,
  architecture: architecture.asset,
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

function resolveArchitecture(platform, architecture) {
  if (platform !== "darwin") {
    throw new Error(
      `The independent macOS preview cannot build on ${platform}.`,
    );
  }
  if (architecture === "arm64") {
    return {
      asset: "arm64",
      capsuleTarget: "darwin-arm64",
      xcode: "arm64",
    };
  }
  if (architecture === "x64") {
    return {
      asset: "x64",
      capsuleTarget: "darwin-x64",
      xcode: "x86_64",
    };
  }
  throw new Error(`Unsupported macOS preview architecture ${architecture}.`);
}
