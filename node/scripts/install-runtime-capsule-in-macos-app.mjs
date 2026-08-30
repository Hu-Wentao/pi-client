#!/usr/bin/env node

import {
  installRuntimeCapsuleInMacosApp,
  removeRuntimeCapsuleFromMacosApp,
} from "./macos-app-runtime-capsule-lib.mjs";

const options = parseArguments(process.argv.slice(2));
const result = options.remove
  ? await removeRuntimeCapsuleFromMacosApp(options.appBundle)
  : await installRuntimeCapsuleInMacosApp(options);
process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);

function parseArguments(arguments_) {
  const values = new Map();
  let remove = false;
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (argument === "--remove") {
      remove = true;
      continue;
    }
    if (!["--app", "--capsule", "--expected-source-commit"].includes(argument)) {
      throw new Error(`Unsupported capsule installation argument ${argument}.`);
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
  const capsuleRoot = values.get("--capsule");
  if (!appBundle) {
    throw new Error("--app is required.");
  }
  if (remove && capsuleRoot) {
    throw new Error("--remove cannot be combined with --capsule.");
  }
  if (!remove && !capsuleRoot) {
    throw new Error("--capsule is required unless --remove is used.");
  }
  return {
    appBundle,
    capsuleRoot,
    expectedSourceCommit: values.get("--expected-source-commit"),
    remove,
  };
}
