import { createHash } from "node:crypto";
import { spawnSync } from "node:child_process";
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { dirname, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const protocolRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const generatedRoots = [
  resolve(protocolRoot, "gen/ts"),
  resolve(protocolRoot, "dart/lib/src/gen"),
];

const before = snapshot();
runCodegen();
const afterFirst = snapshot();
if (before !== afterFirst) {
  console.error("generated output changed on the first regeneration");
  process.exit(1);
}
runCodegen();
const afterSecond = snapshot();
if (afterFirst !== afterSecond) {
  console.error("generated output changed on the second regeneration");
  process.exit(1);
}
console.log("generated output is checked in and deterministic across two runs");

function runCodegen() {
  const result = spawnSync("bun", ["run", "codegen"], {
    cwd: protocolRoot,
    stdio: "inherit",
  });
  if (result.error || result.status !== 0) {
    console.error(result.error?.message ?? "code generation failed");
    process.exit(result.status ?? 1);
  }
}

function snapshot() {
  const hash = createHash("sha256");
  for (const root of generatedRoots) {
    if (!existsSync(root)) {
      hash.update(`missing:${relative(protocolRoot, root)}\n`);
      continue;
    }
    for (const file of walk(root)) {
      hash.update(`${relative(protocolRoot, file)}\0`);
      hash.update(readFileSync(file));
      hash.update("\0");
    }
  }
  return hash.digest("hex");
}

function walk(directory) {
  const files = [];
  for (const entry of readdirSync(directory).sort()) {
    const path = resolve(directory, entry);
    if (statSync(path).isDirectory()) {
      files.push(...walk(path));
    } else {
      files.push(path);
    }
  }
  return files;
}
