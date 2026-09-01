#!/usr/bin/env node

import {
  installRuntimeCapsuleInDesktopBundle,
  removeRuntimeCapsuleFromDesktopBundle,
} from "./desktop-app-runtime-capsule-lib.mjs";

const options = parseArguments(process.argv.slice(2));
const result = options.remove
  ? await removeRuntimeCapsuleFromDesktopBundle(options.platform, options.bundleRoot)
  : await installRuntimeCapsuleInDesktopBundle(options);
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
    if (!["--platform", "--bundle", "--capsule", "--expected-source-commit"].includes(argument)) {
      throw new Error(`Unsupported desktop capsule installation argument ${argument}.`);
    }
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    if (values.has(argument)) throw new Error(`${argument} may be supplied only once.`);
    values.set(argument, value);
  }
  const platform = values.get("--platform");
  const bundleRoot = values.get("--bundle");
  const capsuleRoot = values.get("--capsule");
  if (!platform || !bundleRoot) throw new Error("--platform and --bundle are required.");
  if (remove && capsuleRoot) throw new Error("--remove cannot be combined with --capsule.");
  if (!remove && !capsuleRoot) throw new Error("--capsule is required unless --remove is used.");
  return {
    platform,
    bundleRoot,
    capsuleRoot,
    expectedSourceCommit: values.get("--expected-source-commit"),
    remove,
  };
}
