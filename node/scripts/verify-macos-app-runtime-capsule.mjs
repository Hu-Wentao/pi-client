#!/usr/bin/env node

import { verifyInstalledRuntimeCapsule } from "./macos-app-runtime-capsule-lib.mjs";

const options = parseArguments(process.argv.slice(2));
const result = await verifyInstalledRuntimeCapsule(options);
process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);

function parseArguments(arguments_) {
  const values = new Map();
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (!["--app", "--expected-source-commit"].includes(argument)) {
      throw new Error(`Unsupported installed capsule verification argument ${argument}.`);
    }
    const value = arguments_[++index];
    if (!value) {
      throw new Error(`${argument} requires a value.`);
    }
    if (values.has(argument)) {
      throw new Error(`${argument} may be supplied only once.`);
    }
    values.set(argument, value);
  }
  const appBundle = values.get("--app");
  if (!appBundle) {
    throw new Error("--app is required.");
  }
  return {
    appBundle,
    expectedSourceCommit: values.get("--expected-source-commit"),
  };
}
