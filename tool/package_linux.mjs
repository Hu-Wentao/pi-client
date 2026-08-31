#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import {
  cp,
  chmod,
  lstat,
  mkdir,
  readFile,
  readdir,
  symlink,
  utimes,
  writeFile,
} from "node:fs/promises";
import { dirname, resolve } from "node:path";

import { removeTreeEvenIfReadOnly } from "../node/scripts/runtime-capsule-lib.mjs";

if (process.platform !== "linux")
  throw new Error("Linux packaging requires a native Linux host.");
const options = parseArguments(process.argv.slice(2));
const repositoryRoot = resolve(import.meta.dirname, "..");
const epoch = Number(process.env.SOURCE_DATE_EPOCH ?? "");
if (!Number.isSafeInteger(epoch) || epoch <= 0) {
  throw new Error(
    "SOURCE_DATE_EPOCH must be a positive committed-source timestamp.",
  );
}
const appDir = resolve(options.workDirectory, "PiClient.AppDir");
const debRoot = resolve(options.workDirectory, "deb-root");
await Promise.all([
  removeTreeEvenIfReadOnly(appDir),
  removeTreeEvenIfReadOnly(debRoot),
]);
await Promise.all([
  mkdir(appDir, { recursive: true }),
  mkdir(debRoot, { recursive: true }),
  mkdir(options.outputDirectory, { recursive: true }),
]);

const appImageBundle = resolve(appDir, "usr/lib/pi-client");
await cp(options.bundleRoot, appImageBundle, {
  recursive: true,
  dereference: false,
  preserveTimestamps: false,
  verbatimSymlinks: true,
});
await Promise.all([
  copyFile(
    resolve(repositoryRoot, "packaging/linux/AppRun"),
    resolve(appDir, "AppRun"),
    0o755,
  ),
  copyFile(
    resolve(
      repositoryRoot,
      "packaging/linux/io.github.huwentao.pi_client.desktop",
    ),
    resolve(appDir, "io.github.huwentao.pi_client.desktop"),
    0o644,
  ),
  copyFile(
    resolve(
      repositoryRoot,
      "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png",
    ),
    resolve(appDir, "io.github.huwentao.pi_client.png"),
    0o644,
  ),
]);
await symlink("io.github.huwentao.pi_client.png", resolve(appDir, ".DirIcon"));
await normalizeTimestamps(appDir, epoch);
const appImagePath = resolve(options.outputDirectory, options.appImageName);
run(options.appImageTool, [appDir, appImagePath], {
  ...process.env,
  ARCH: options.architecture === "arm64" ? "aarch64" : "x86_64",
  APPIMAGE_EXTRACT_AND_RUN: "1",
  SOURCE_DATE_EPOCH: String(epoch),
});

const installRoot = resolve(debRoot, "opt/pi-client");
await cp(options.bundleRoot, installRoot, {
  recursive: true,
  dereference: false,
  preserveTimestamps: false,
  verbatimSymlinks: true,
});
await Promise.all([
  mkdir(resolve(debRoot, "DEBIAN"), { recursive: true }),
  mkdir(resolve(debRoot, "usr/bin"), { recursive: true }),
  mkdir(resolve(debRoot, "usr/share/applications"), { recursive: true }),
  mkdir(resolve(debRoot, "usr/share/icons/hicolor/256x256/apps"), {
    recursive: true,
  }),
  mkdir(resolve(debRoot, "usr/share/doc/pi-client"), { recursive: true }),
]);
await Promise.all([
  writeFile(resolve(debRoot, "DEBIAN/control"), debianControl(options), {
    mode: 0o644,
  }),
  copyFile(
    resolve(
      repositoryRoot,
      "packaging/linux/io.github.huwentao.pi_client.desktop",
    ),
    resolve(
      debRoot,
      "usr/share/applications/io.github.huwentao.pi_client.desktop",
    ),
    0o644,
  ),
  copyFile(
    resolve(
      repositoryRoot,
      "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png",
    ),
    resolve(
      debRoot,
      "usr/share/icons/hicolor/256x256/apps/io.github.huwentao.pi_client.png",
    ),
    0o644,
  ),
  copyFile(
    resolve(repositoryRoot, "LICENSE"),
    resolve(debRoot, "usr/share/doc/pi-client/copyright"),
    0o644,
  ),
]);
await symlink(
  "/opt/pi-client/pi_client",
  resolve(debRoot, "usr/bin/pi-client"),
);
await normalizeTimestamps(debRoot, epoch);
const debPath = resolve(options.outputDirectory, options.debName);
run("dpkg-deb", ["--root-owner-group", "--build", debRoot, debPath], {
  ...process.env,
  SOURCE_DATE_EPOCH: String(epoch),
});
process.stdout.write(
  `${JSON.stringify({ appImagePath, debPath, sourceDateEpoch: epoch }, null, 2)}\n`,
);

async function copyFile(source, destination, mode) {
  await mkdir(dirname(destination), { recursive: true });
  await cp(source, destination, { preserveTimestamps: false });
  await chmod(destination, mode);
}

async function normalizeTimestamps(path, seconds) {
  const metadata = await lstat(path);
  if (!metadata.isSymbolicLink()) await utimes(path, seconds, seconds);
  if (!metadata.isDirectory() || metadata.isSymbolicLink()) return;
  for (const name of (await readdir(path)).sort())
    await normalizeTimestamps(resolve(path, name), seconds);
}

function debianControl(options_) {
  const architecture = options_.architecture === "arm64" ? "arm64" : "amd64";
  return [
    "Package: pi-client",
    `Version: ${options_.version}`,
    `Architecture: ${architecture}`,
    "Maintainer: Hu-Wentao <noreply@github.com>",
    "Depends: libgtk-3-0, libstdc++6, liblzma5",
    "Section: devel",
    "Priority: optional",
    "Homepage: https://github.com/Hu-Wentao/pi-client",
    "Description: Cross-platform client for the pi coding agent",
    " Pi Client bundles its verified first-party Pi Node runtime capsule.",
    "",
  ].join("\n");
}

function run(executable, arguments_, environment) {
  const result = spawnSync(executable, arguments_, {
    env: environment,
    encoding: "utf8",
    stdio: "inherit",
  });
  if (result.error) throw result.error;
  if (result.status !== 0)
    throw new Error(`${executable} failed with code ${result.status}.`);
}

function parseArguments(arguments_) {
  const values = new Map();
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (
      ![
        "--bundle",
        "--version",
        "--architecture",
        "--appimagetool",
        "--output",
        "--work",
        "--appimage-name",
        "--deb-name",
      ].includes(argument)
    )
      throw new Error(`Unsupported Linux packaging argument ${argument}.`);
    const value = arguments_[++index];
    if (!value) throw new Error(`${argument} requires a value.`);
    values.set(argument, value);
  }
  for (const required of [
    "--bundle",
    "--version",
    "--architecture",
    "--appimagetool",
    "--output",
    "--work",
    "--appimage-name",
    "--deb-name",
  ])
    if (!values.has(required)) throw new Error(`${required} is required.`);
  const architecture = values.get("--architecture");
  if (!new Set(["x64", "arm64"]).has(architecture))
    throw new Error("Unsupported Linux architecture.");
  return {
    bundleRoot: resolve(values.get("--bundle")),
    version: values.get("--version"),
    architecture,
    appImageTool: resolve(values.get("--appimagetool")),
    outputDirectory: resolve(values.get("--output")),
    workDirectory: resolve(values.get("--work")),
    appImageName: values.get("--appimage-name"),
    debName: values.get("--deb-name"),
  };
}
