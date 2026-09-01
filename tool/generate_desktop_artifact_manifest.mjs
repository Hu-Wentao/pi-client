#!/usr/bin/env node

import { createHash } from "node:crypto";
import { createReadStream } from "node:fs";
import { lstat, readdir, writeFile } from "node:fs/promises";
import { relative, resolve, sep } from "node:path";

const options = parseArguments(process.argv.slice(2));
const files = [];
await visit(options.artifactDirectory);
files.sort((left, right) => left.path.localeCompare(right.path));
const manifest = {
  schemaVersion: 1,
  sourceCommit: options.sourceCommit,
  version: options.version,
  platform: options.platform,
  architecture: options.architecture,
  channel: options.channel,
  signed: options.signed,
  files,
};
await writeFile(
  options.output,
  `${JSON.stringify(manifest, null, 2)}\n`,
  "utf8",
);
process.stdout.write(`${JSON.stringify(manifest, null, 2)}\n`);

async function visit(path) {
  const metadata = await lstat(path);
  if (metadata.isSymbolicLink())
    throw new Error(`Artifact directory contains symlink ${path}.`);
  if (metadata.isDirectory()) {
    for (const name of (await readdir(path)).sort()) {
      const child = resolve(path, name);
      if (resolve(child) === resolve(options.output)) continue;
      await visit(child);
    }
    return;
  }
  if (!metadata.isFile())
    throw new Error(`Unsupported artifact entry ${path}.`);
  const relativePath = relative(options.artifactDirectory, path)
    .split(sep)
    .join("/");
  if (/pi-web/iu.test(relativePath))
    throw new Error(`Forbidden artifact path ${relativePath}.`);
  files.push({
    path: relativePath,
    size: metadata.size,
    sha256: await sha256(path),
  });
}

async function sha256(path) {
  const hash = createHash("sha256");
  for await (const chunk of createReadStream(path)) hash.update(chunk);
  return hash.digest("hex");
}

function parseArguments(arguments_) {
  const values = new Map();
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (
      ![
        "--artifacts",
        "--output",
        "--source-commit",
        "--version",
        "--platform",
        "--architecture",
        "--channel",
        "--signed",
      ].includes(argument)
    ) {
      throw new Error(`Unsupported artifact-manifest argument ${argument}.`);
    }
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    values.set(argument, value);
  }
  const sourceCommit = values.get("--source-commit") ?? "";
  if (!/^[0-9a-f]{40}$/u.test(sourceCommit))
    throw new Error("--source-commit must be a full commit.");
  const signedValue = values.get("--signed");
  if (!new Set(["true", "false"]).has(signedValue))
    throw new Error("--signed must be true or false.");
  for (const required of [
    "--artifacts",
    "--output",
    "--version",
    "--platform",
    "--architecture",
    "--channel",
  ]) {
    if (!values.has(required)) throw new Error(`${required} is required.`);
  }
  return {
    artifactDirectory: resolve(values.get("--artifacts")),
    output: resolve(values.get("--output")),
    sourceCommit,
    version: values.get("--version"),
    platform: values.get("--platform"),
    architecture: values.get("--architecture"),
    channel: values.get("--channel"),
    signed: signedValue === "true",
  };
}
