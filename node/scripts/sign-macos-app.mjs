#!/usr/bin/env node

import { signMacosAppInsideOut } from "./macos-code-signing-lib.mjs";

const options = parseArguments(process.argv.slice(2));
const result = await signMacosAppInsideOut(options);
process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);

function parseArguments(arguments_) {
  const values = new Map();
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (
      ![
        "--app",
        "--identity",
        "--expected-source-commit",
        "--app-entitlements",
        "--node-entitlements",
        "--ad-hoc-node-entitlements",
        "--timestamp",
        "--gatekeeper",
      ].includes(argument)
    ) {
      throw new Error(`Unsupported macOS signing argument ${argument}.`);
    }
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    if (values.has(argument)) throw new Error(`${argument} may be supplied only once.`);
    values.set(argument, value);
  }
  const appBundle = values.get("--app");
  if (!appBundle) throw new Error("--app is required.");
  const gatekeeper = values.get("--gatekeeper") ?? undefined;
  if (gatekeeper && !["accept", "reject", "skip"].includes(gatekeeper)) {
    throw new Error("--gatekeeper must be accept, reject, or skip.");
  }
  const timestamp = values.get("--timestamp") ?? undefined;
  if (timestamp && timestamp !== "none") {
    throw new Error(
      "--timestamp currently accepts only none; omit it for Developer ID timestamping.",
    );
  }
  return {
    appBundle,
    identity: values.get("--identity") ?? "-",
    expectedSourceCommit: values.get("--expected-source-commit"),
    appEntitlements: values.get("--app-entitlements"),
    nodeEntitlements: values.get("--node-entitlements"),
    adHocNodeEntitlements: values.get("--ad-hoc-node-entitlements"),
    timestamp,
    gatekeeper,
  };
}
