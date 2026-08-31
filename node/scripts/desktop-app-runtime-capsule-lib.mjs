import { spawnSync } from "node:child_process";
import { cp, lstat, mkdir, readFile, rename } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  CAPSULE_MANIFEST_NAME,
  makeTreeReadOnly,
  removeTreeEvenIfReadOnly,
} from "./runtime-capsule-lib.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const verifyRuntimeCapsuleScript = resolve(scriptDirectory, "verify-runtime-capsule.mjs");

export const DESKTOP_APP_CAPSULE_LAYOUTS = Object.freeze({
  linux: Object.freeze({
    capsule: "lib/pi-client/PiNode",
    executable: "pi_client",
    manifestPlatform: "linux",
  }),
  windows: Object.freeze({
    capsule: "PiNode",
    executable: "pi_client.exe",
    manifestPlatform: "win32",
  }),
});

export function resolveDesktopAppCapsulePath(platform, bundleRoot) {
  const layout = resolveDesktopLayout(platform);
  return resolve(bundleRoot, ...layout.capsule.split("/"));
}

export async function assertDesktopBundle(platform, bundleRoot) {
  const layout = resolveDesktopLayout(platform);
  const bundle = resolve(bundleRoot);
  const metadata = await lstat(bundle);
  if (!metadata.isDirectory() || metadata.isSymbolicLink()) {
    throw new Error(`The ${platform} application bundle is not a real directory.`);
  }
  const executable = resolve(bundle, layout.executable);
  const executableMetadata = await lstat(executable);
  if (!executableMetadata.isFile() || executableMetadata.isSymbolicLink()) {
    throw new Error(`The ${platform} application bundle has no real ${layout.executable}.`);
  }
  return { bundle, executable, layout };
}

export async function installRuntimeCapsuleInDesktopBundle(options) {
  const app = await assertDesktopBundle(options.platform, options.bundleRoot);
  const source = resolve(options.capsuleRoot);
  const verifyCapsule = options.verifyCapsule ?? verifyRuntimeCapsule;
  await verifyCapsule(source, options.expectedSourceCommit);
  await assertCapsulePlatform(source, app.layout.manifestPlatform);

  const destination = resolveDesktopAppCapsulePath(options.platform, app.bundle);
  const parent = dirname(destination);
  const staging = resolve(parent, `.PiNode.installing-${process.pid}`);
  await mkdir(parent, { recursive: true });
  await removeTreeEvenIfReadOnly(staging);
  let destinationReplaced = false;
  try {
    await cp(source, staging, {
      recursive: true,
      dereference: false,
      errorOnExist: true,
      force: false,
      preserveTimestamps: false,
      verbatimSymlinks: true,
    });
    await makeTreeReadOnly(staging);
    await removeTreeEvenIfReadOnly(destination);
    destinationReplaced = true;
    await rename(staging, destination);
    await verifyCapsule(destination, options.expectedSourceCommit);
    await assertCapsulePlatform(destination, app.layout.manifestPlatform);
    return await installedDesktopCapsuleMetadata(options.platform, app.bundle, destination);
  } catch (error) {
    await removeTreeEvenIfReadOnly(staging);
    if (destinationReplaced) await removeTreeEvenIfReadOnly(destination);
    throw error;
  }
}

export async function removeRuntimeCapsuleFromDesktopBundle(platform, bundleRoot) {
  const app = await assertDesktopBundle(platform, bundleRoot);
  const destination = resolveDesktopAppCapsulePath(platform, app.bundle);
  await removeTreeEvenIfReadOnly(destination);
  return { platform, bundleRoot: app.bundle, capsulePath: destination, removed: true };
}

export async function verifyInstalledDesktopRuntimeCapsule(options) {
  const app = await assertDesktopBundle(options.platform, options.bundleRoot);
  const capsule = resolveDesktopAppCapsulePath(options.platform, app.bundle);
  const verifyCapsule = options.verifyCapsule ?? verifyRuntimeCapsule;
  await verifyCapsule(capsule, options.expectedSourceCommit);
  await assertCapsulePlatform(capsule, app.layout.manifestPlatform);
  return await installedDesktopCapsuleMetadata(options.platform, app.bundle, capsule);
}

export async function installedDesktopCapsuleMetadata(platform, bundleRoot, capsuleRoot) {
  const layout = resolveDesktopLayout(platform);
  const manifest = JSON.parse(await readFile(resolve(capsuleRoot, CAPSULE_MANIFEST_NAME), "utf8"));
  return {
    platform,
    bundleRoot: resolve(bundleRoot),
    bundleExecutable: resolve(bundleRoot, layout.executable),
    capsulePath: resolve(capsuleRoot),
    layout: layout.capsule,
    sourceCommit: manifest.sourceCommit,
    target: manifest.target?.id,
    payloadFileCount: manifest.integrity?.payloadFileCount,
    payloadSize: manifest.integrity?.payloadSize,
    runtimeExecutable: resolve(capsuleRoot, ...manifest.runtime.executable.split("/")),
    applicationEntrypoint: resolve(capsuleRoot, ...manifest.application.entrypoint.split("/")),
  };
}

export async function verifyRuntimeCapsule(capsuleRoot, expectedSourceCommit) {
  const result = spawnSync(process.execPath, [verifyRuntimeCapsuleScript, resolve(capsuleRoot)], {
    env: {
      ...process.env,
      ...(expectedSourceCommit
        ? { PI_RUNTIME_CAPSULE_EXPECTED_SOURCE_COMMIT: expectedSourceCommit }
        : {}),
    },
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
    maxBuffer: 10 * 1024 * 1024,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(
      `Runtime capsule verification failed with code ${result.status}: ${(result.stderr ?? "").trim()}`,
    );
  }
  return JSON.parse(result.stdout);
}

async function assertCapsulePlatform(capsuleRoot, expectedPlatform) {
  const manifest = JSON.parse(await readFile(resolve(capsuleRoot, CAPSULE_MANIFEST_NAME), "utf8"));
  if (manifest.target?.platform !== expectedPlatform) {
    throw new Error(
      `Capsule target platform ${manifest.target?.platform ?? "<missing>"} cannot be installed for ${expectedPlatform}.`,
    );
  }
}

function resolveDesktopLayout(platform) {
  const layout = DESKTOP_APP_CAPSULE_LAYOUTS[platform];
  if (!layout) {
    throw new Error(`Unsupported desktop capsule platform ${JSON.stringify(platform)}.`);
  }
  return layout;
}
