import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const protocolRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
for (const root of ["gen/ts", "dart/lib/src/gen"]) {
  for (const file of walk(resolve(protocolRoot, root))) {
    const content = readFileSync(file, "utf8");
    const normalized = `${content.trimEnd()}\n`;
    if (content !== normalized) {
      writeFileSync(file, normalized);
    }
  }
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
