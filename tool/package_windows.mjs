#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { access, mkdir } from "node:fs/promises";
import { resolve } from "node:path";

if (process.platform !== "win32")
  throw new Error("Windows packaging requires a native Windows host.");
const options = parseArguments(process.argv.slice(2));
const repositoryRoot = resolve(import.meta.dirname, "..");
await mkdir(options.outputDirectory, { recursive: true });
const definition = resolve(repositoryRoot, "packaging/windows/pi-client.iss");
const result = spawnSync(
  options.iscc,
  [
    "/Qp",
    `/DAppVersion=${options.version}`,
    `/DBundleRoot=${options.bundleRoot}`,
    `/DOutputDirectory=${options.outputDirectory}`,
    `/DOutputBaseFilename=${options.outputBaseFilename}`,
    definition,
  ],
  { encoding: "utf8", stdio: "inherit" },
);
if (result.error) throw result.error;
if (result.status !== 0)
  throw new Error(`Inno Setup failed with code ${result.status}.`);
const installerPath = resolve(
  options.outputDirectory,
  `${options.outputBaseFilename}.exe`,
);
await access(installerPath);
process.stdout.write(`${JSON.stringify({ installerPath }, null, 2)}\n`);

function parseArguments(arguments_) {
  const values = new Map();
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (
      ![
        "--bundle",
        "--version",
        "--iscc",
        "--output",
        "--output-base-filename",
      ].includes(argument)
    )
      throw new Error(`Unsupported Windows packaging argument ${argument}.`);
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    values.set(argument, value);
  }
  for (const required of [
    "--bundle",
    "--version",
    "--iscc",
    "--output",
    "--output-base-filename",
  ])
    if (!values.has(required)) throw new Error(`${required} is required.`);
  return {
    bundleRoot: resolve(values.get("--bundle")),
    version: values.get("--version"),
    iscc: resolve(values.get("--iscc")),
    outputDirectory: resolve(values.get("--output")),
    outputBaseFilename: values.get("--output-base-filename"),
  };
}
