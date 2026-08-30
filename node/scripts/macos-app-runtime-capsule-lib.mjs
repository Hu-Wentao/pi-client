import { spawnSync } from "node:child_process";
import { cp, lstat, mkdir, readFile, rename } from "node:fs/promises";
import { dirname, extname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  CAPSULE_MANIFEST_NAME,
  makeTreeReadOnly,
  removeTreeEvenIfReadOnly,
} from "./runtime-capsule-lib.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const verifyRuntimeCapsuleScript = resolve(scriptDirectory, "verify-runtime-capsule.mjs");

export const MACOS_APP_CAPSULE_RELATIVE_PATH = "Contents/Helpers/PiNode";

export function resolveMacosAppCapsulePath(appBundle) {
  const app = resolve(appBundle);
  if (extname(app) !== ".app") {
    throw new Error("The macOS application bundle must end in .app.");
  }
  return resolve(app, ...MACOS_APP_CAPSULE_RELATIVE_PATH.split("/"));
}

export async function assertMacosAppBundle(appBundle) {
  const app = resolve(appBundle);
  const appMetadata = await lstat(app);
  if (!appMetadata.isDirectory() || appMetadata.isSymbolicLink()) {
    throw new Error("The macOS application bundle is not a real directory.");
  }
  const contents = resolve(app, "Contents");
  const contentsMetadata = await lstat(contents);
  if (!contentsMetadata.isDirectory() || contentsMetadata.isSymbolicLink()) {
    throw new Error("The macOS application bundle has no real Contents directory.");
  }
  return app;
}

export async function installRuntimeCapsuleInMacosApp(options) {
  const app = await assertMacosAppBundle(options.appBundle);
  const source = resolve(options.capsuleRoot);
  const verifyCapsule = options.verifyCapsule ?? verifyRuntimeCapsule;
  await verifyCapsule(source, options.expectedSourceCommit);

  const destination = resolveMacosAppCapsulePath(app);
  const helpers = dirname(destination);
  const staging = resolve(helpers, `.PiNode.installing-${process.pid}`);
  await mkdir(helpers, { recursive: true });
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
    return await installedCapsuleMetadata(app, destination);
  } catch (error) {
    await removeTreeEvenIfReadOnly(staging);
    if (destinationReplaced) {
      await removeTreeEvenIfReadOnly(destination);
    }
    throw error;
  }
}

export async function removeRuntimeCapsuleFromMacosApp(appBundle) {
  const app = await assertMacosAppBundle(appBundle);
  const destination = resolveMacosAppCapsulePath(app);
  await removeTreeEvenIfReadOnly(destination);
  return { appBundle: app, capsulePath: destination, removed: true };
}

export async function verifyInstalledRuntimeCapsule(options) {
  const app = await assertMacosAppBundle(options.appBundle);
  const capsule = resolveMacosAppCapsulePath(app);
  const verifyCapsule = options.verifyCapsule ?? verifyRuntimeCapsule;
  await verifyCapsule(capsule, options.expectedSourceCommit);
  return await installedCapsuleMetadata(app, capsule);
}

export async function installedCapsuleMetadata(appBundle, capsuleRoot) {
  const manifest = JSON.parse(await readFile(resolve(capsuleRoot, CAPSULE_MANIFEST_NAME), "utf8"));
  return {
    appBundle: resolve(appBundle),
    capsulePath: resolve(capsuleRoot),
    layout: MACOS_APP_CAPSULE_RELATIVE_PATH,
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
  if (result.error) {
    throw result.error;
  }
  if (result.status !== 0) {
    throw new Error(
      `Runtime capsule verification failed with code ${result.status}: ${(result.stderr ?? "").trim()}`,
    );
  }
  return JSON.parse(result.stdout);
}
