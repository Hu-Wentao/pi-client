#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { chmod, mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";

if (process.platform !== "linux")
  throw new Error("Linux signing requires a native Linux host.");
const files = parseArguments(process.argv.slice(2));
const encodedKey = (process.env.LINUX_GPG_PRIVATE_KEY_BASE64 ?? "").trim();
const passphrase = process.env.LINUX_GPG_PASSPHRASE ?? "";
if (!encodedKey || !passphrase)
  throw new Error("Linux GPG signing credentials are required.");
const home = await mkdtemp(resolve(tmpdir(), "pi-client-gnupg-"));
const keyPath = resolve(home, "private.key");
try {
  await chmod(home, 0o700);
  await writeFile(keyPath, Buffer.from(encodedKey, "base64"), { mode: 0o600 });
  run(["--batch", "--homedir", home, "--import", keyPath]);
  for (const file of files) {
    run(
      [
        "--batch",
        "--yes",
        "--homedir",
        home,
        "--pinentry-mode",
        "loopback",
        "--passphrase-fd",
        "0",
        "--armor",
        "--detach-sign",
        "--output",
        `${file}.asc`,
        file,
      ],
      `${passphrase}\n`,
    );
    run(["--batch", "--homedir", home, "--verify", `${file}.asc`, file]);
  }
} finally {
  await rm(home, { recursive: true, force: true });
}

function run(arguments_, input) {
  const result = spawnSync("gpg", arguments_, {
    input,
    encoding: "utf8",
    stdio: input ? ["pipe", "inherit", "inherit"] : "inherit",
  });
  if (result.error) throw result.error;
  if (result.status !== 0)
    throw new Error(`gpg failed with code ${result.status}.`);
}

function parseArguments(arguments_) {
  const files_ = [];
  for (let index = 0; index < arguments_.length; index += 1) {
    if (arguments_[index] !== "--file")
      throw new Error(
        `Unsupported Linux signing argument ${arguments_[index]}.`,
      );
    const value = arguments_[++index];
    if (!value) throw new Error("--file requires a value.");
    files_.push(resolve(value));
  }
  if (files_.length === 0) throw new Error("At least one --file is required.");
  return files_;
}
