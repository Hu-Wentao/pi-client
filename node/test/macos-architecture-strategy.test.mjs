import assert from "node:assert/strict";
import test from "node:test";

import { resolveMacosArchitectureStrategy } from "../scripts/macos-architecture-strategy.mjs";

test("selects Universal only when both architecture executions are proven", () => {
  const strategy = resolveMacosArchitectureStrategy({
    platform: "darwin",
    canExecute: () => true,
  });
  assert.deepEqual(strategy, {
    asset: "universal",
    capsuleTarget: "darwin-universal",
    xcodeArchitectures: "arm64 x86_64",
    architectures: "arm64,x64",
    universal: "true",
    evidence: "arm64-and-x64-node-startup-required",
  });
});

test("keeps architecture-specific assets without Rosetta/x64 evidence", () => {
  const strategy = resolveMacosArchitectureStrategy({
    platform: "darwin",
    canExecute: (architecture) => architecture === "arm64",
  });
  assert.equal(strategy.asset, "arm64");
  assert.equal(strategy.capsuleTarget, "darwin-arm64");
  assert.equal(strategy.universal, "false");
  assert.match(strategy.evidence, /no-x64-rosetta-evidence/u);
});

test("keeps x64-specific assets without arm64 execution evidence", () => {
  const strategy = resolveMacosArchitectureStrategy({
    platform: "darwin",
    canExecute: (architecture) => architecture === "x64",
  });
  assert.equal(strategy.asset, "x64");
  assert.equal(strategy.capsuleTarget, "darwin-x64");
  assert.equal(strategy.universal, "false");
});
