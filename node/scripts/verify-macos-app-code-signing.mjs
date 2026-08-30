#!/usr/bin/env node

import { verifyMacosAppCodeSigning } from "./macos-code-signing-lib.mjs";

const options = parseArguments(process.argv.slice(2));
const result = await verifyMacosAppCodeSigning(options);
process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);

function parseArguments(arguments_) {
  const values = new Map();
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (
      !["--app", "--expected-source-commit", "--expected-signing-kind", "--gatekeeper"].includes(
        argument,
      )
    ) {
      throw new Error(`Unsupported macOS signing verification argument ${argument}.`);
    }
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    if (values.has(argument)) throw new Error(`${argument} may be supplied only once.`);
    values.set(argument, value);
  }
  const appBundle = values.get("--app");
  if (!appBundle) throw new Error("--app is required.");
  const expectedSigningKind = values.get("--expected-signing-kind");
  if (expectedSigningKind && !["ad-hoc", "developer-id"].includes(expectedSigningKind)) {
    throw new Error("--expected-signing-kind must be ad-hoc or developer-id.");
  }
  const gatekeeper = values.get("--gatekeeper") ?? "skip";
  if (!["accept", "reject", "skip"].includes(gatekeeper)) {
    throw new Error("--gatekeeper must be accept, reject, or skip.");
  }
  return {
    appBundle,
    expectedSourceCommit: values.get("--expected-source-commit"),
    expectedSigningKind,
    gatekeeper,
  };
}
