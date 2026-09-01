#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const toolDirectory = dirname(fileURLToPath(import.meta.url));
const dartPackage = resolve(toolDirectory, "../dart");
const result = spawnSync(
  "fvm",
  ["dart", "run", "protoc_plugin:protoc_plugin"],
  {
    cwd: dartPackage,
    stdio: "inherit",
  },
);

if (result.error) {
  console.error(`failed to start the local Dart generator: ${result.error.message}`);
  process.exit(1);
}

process.exit(result.status ?? 1);
