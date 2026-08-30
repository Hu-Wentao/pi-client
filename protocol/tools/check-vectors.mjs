import { createHash } from "node:crypto";
import { spawnSync } from "node:child_process";
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { dirname, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const protocolRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const vectorRoot = resolve(protocolRoot, "test-vectors");
const before = snapshot();
runVectors();
const afterFirst = snapshot();
if (before !== afterFirst) {
  console.error("cross-language vectors changed on regeneration");
  process.exit(1);
}
runVectors();
const afterSecond = snapshot();
if (afterFirst !== afterSecond) {
  console.error("cross-language vectors changed on the second regeneration");
  process.exit(1);
}
console.log("cross-language vectors are checked in and deterministic");

function runVectors() {
  const result = spawnSync("bun", ["run", "vectors"], {
    cwd: protocolRoot,
    stdio: "inherit",
  });
  if (result.error || result.status !== 0) {
    console.error(result.error?.message ?? "vector generation failed");
    process.exit(result.status ?? 1);
  }
}

function snapshot() {
  const hash = createHash("sha256");
  if (!existsSync(vectorRoot)) {
    return "missing";
  }
  for (const file of walk(vectorRoot)) {
    hash.update(`${relative(protocolRoot, file)}\0`);
    hash.update(readFileSync(file));
    hash.update("\0");
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
