#!/usr/bin/env node

import { verifyInstalledDesktopRuntimeCapsule } from "./desktop-app-runtime-capsule-lib.mjs";

const options = parseArguments(process.argv.slice(2));
const result = await verifyInstalledDesktopRuntimeCapsule(options);
process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);

function parseArguments(arguments_) {
  const values = new Map();
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (!["--platform", "--bundle", "--expected-source-commit"].includes(argument)) {
      throw new Error(`Unsupported desktop capsule verification argument ${argument}.`);
    }
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    if (values.has(argument)) throw new Error(`${argument} may be supplied only once.`);
    values.set(argument, value);
  }
  const platform = values.get("--platform");
  const bundleRoot = values.get("--bundle");
  if (!platform || !bundleRoot) throw new Error("--platform and --bundle are required.");
  return {
    platform,
    bundleRoot,
    expectedSourceCommit: values.get("--expected-source-commit"),
  };
}
