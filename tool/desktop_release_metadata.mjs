#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { appendFile, readFile } from "node:fs/promises";
import { resolve } from "node:path";

const repositoryRoot = resolve(import.meta.dirname, "..");
const options = parseArguments(process.argv.slice(2));
const pubspec = await readFile(resolve(repositoryRoot, "pubspec.yaml"), "utf8");
const versionMatch =
  /^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$/mu.exec(pubspec);
if (!versionMatch)
  throw new Error("pubspec.yaml must contain MAJOR.MINOR.PATCH+BUILD.");
const [, version, buildNumber] = versionMatch;
const sourceCommit = runGit(["rev-parse", "HEAD"]).trim();
if (!/^[0-9a-f]{40}$/u.test(sourceCommit))
  throw new Error("Source commit is not immutable.");
const platformAsset = options.platform === "windows" ? "Windows" : "Linux";
const architectureAsset = options.architecture === "arm64" ? "arm64" : "x64";
const capsuleTarget =
  options.platform === "windows"
    ? "win32-x64"
    : `linux-${options.architecture}`;
const bundleDirectory =
  options.platform === "windows"
    ? "build/windows/x64/runner/Release"
    : `build/linux/${options.architecture}/release/bundle`;
const base = `Pi-Client-${version}-${platformAsset}-${architectureAsset}`;
const metadata = {
  version,
  buildNumber,
  sourceCommit,
  platform: options.platform,
  architecture: options.architecture,
  channel: options.channel,
  capsuleTarget,
  capsuleDirectory: `build/pi-node-runtime-capsule-${capsuleTarget}`,
  bundleDirectory,
  installerAsset:
    options.platform === "windows" ? `${base}-setup.exe` : `${base}.AppImage`,
  debAsset: options.platform === "linux" ? `${base}.deb` : "",
  checksumAsset: `${base}.sha256`,
  sbomAsset: `${base}.spdx.json`,
  licenseAsset: `${base}.licenses.json`,
  manifestAsset: `${base}.manifest.json`,
};
const outputIndex = process.argv.indexOf("--github-output");
if (outputIndex !== -1) {
  const outputPath = process.argv[outputIndex + 1];
  if (!outputPath) throw new Error("--github-output requires a path.");
  await appendFile(
    outputPath,
    `${Object.entries(metadata)
      .map(([key, value]) => `${key}=${value}`)
      .join("\n")}\n`,
  );
}
process.stdout.write(`${JSON.stringify(metadata, null, 2)}\n`);

function parseArguments(arguments_) {
  const values = new Map();
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (argument === "--github-output") {
      index += 1;
      continue;
    }
    if (!["--platform", "--architecture", "--channel"].includes(argument)) {
      throw new Error(`Unsupported metadata argument ${argument}.`);
    }
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    values.set(argument, value);
  }
  const platform = values.get("--platform");
  const architecture = values.get("--architecture");
  const channel = values.get("--channel");
  if (!new Set(["windows", "linux"]).has(platform))
    throw new Error("Invalid platform.");
  if (!new Set(["x64", "arm64"]).has(architecture))
    throw new Error("Invalid architecture.");
  if (platform === "windows" && architecture !== "x64") {
    throw new Error("The Windows release slice supports x64 only.");
  }
  if (!new Set(["candidate", "stable"]).has(channel))
    throw new Error("Invalid channel.");
  return { platform, architecture, channel };
}

function runGit(arguments_) {
  const result = spawnSync("git", ["-C", repositoryRoot, ...arguments_], {
    encoding: "utf8",
  });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(result.stderr.trim());
  return result.stdout;
}
