#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { access, mkdir, readFile, rename, rm, stat, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  CAPSULE_SCHEMA_PATH,
  NODE_LOCK_PATH,
  PROTOCOL_LOCK_PATH,
  copyFileWithParents,
  copyRealPackage,
  createCapsuleManifest,
  makeTreeReadOnly,
  parseOfficialShasums,
  readJson,
  removeTreeEvenIfReadOnly,
  scanForbiddenArtifacts,
  sha256File,
  verifyPackageMetadata,
  writeDeterministicJson,
} from "./runtime-capsule-lib.mjs";
import {
  NODE_RUNTIME_VERSION,
  NODE_SHASUMS_URL,
  REQUIRED_BUN_VERSION,
  REQUIRED_PI_SDK_VERSION,
  REQUIRED_PROTOBUF_VERSION,
  currentCapsuleTargetId,
  resolveNodeDistribution,
} from "./runtime-capsule-config.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const nodeRoot = resolve(scriptDirectory, "..");
const repositoryRoot = resolve(nodeRoot, "..");
const protocolRoot = resolve(repositoryRoot, "protocol");
const buildRoot = resolve(repositoryRoot, "build");
const tempRoot = resolve(buildRoot, "temp");
const schemaSource = resolve(nodeRoot, "capsule/capsule-manifest.schema.json");
const verifyScript = resolve(scriptDirectory, "verify-runtime-capsule.mjs");

const targetId = parseTarget(process.argv.slice(2));
const target = resolveNodeDistribution(targetId);
const currentTarget = currentCapsuleTargetId();
if (target.id !== currentTarget) {
  throw new Error(
    `Runtime capsule assembly is host-targeted. Requested ${target.id}, current host is ${currentTarget}.`,
  );
}

await assertCleanCapsuleSources();
const source = await verifySourceMetadata();
await verifyBuilderToolchain();
await buildSourcePackages();

const cacheRoot = resolve(tempRoot, `node-v${NODE_RUNTIME_VERSION}`);
const archivePath = resolve(cacheRoot, target.archiveName);
const shasumsPath = resolve(cacheRoot, "SHASUMS256.txt");
await mkdir(cacheRoot, { recursive: true });
await ensureDownload(NODE_SHASUMS_URL, shasumsPath, { refresh: true });
const shasumsText = await readFile(shasumsPath, "utf8");
const officialArchiveSha256 = parseOfficialShasums(shasumsText, target.archiveName);
if (officialArchiveSha256 !== target.archiveSha256) {
  throw new Error(
    `Official Node checksum changed for ${target.archiveName}: expected ${target.archiveSha256}, found ${officialArchiveSha256}.`,
  );
}
await ensureVerifiedArchive(target.archiveUrl, archivePath, target.archiveSha256);

const capsuleRoot = resolve(buildRoot, `pi-node-runtime-capsule-${target.id}`);
const stageRoot = resolve(tempRoot, `runtime-capsule-stage-${target.id}`);
const extractRoot = resolve(tempRoot, `runtime-capsule-extract-${target.id}`);
await Promise.all([
  removeTreeEvenIfReadOnly(capsuleRoot),
  removeTreeEvenIfReadOnly(stageRoot),
  removeTreeEvenIfReadOnly(extractRoot),
]);
await Promise.all([
  mkdir(capsuleRoot, { recursive: true }),
  mkdir(stageRoot, { recursive: true }),
  mkdir(extractRoot, { recursive: true }),
]);

await extractRuntime(archivePath, extractRoot, target);
const extractedRuntime = resolve(extractRoot, target.archiveRoot);
await access(extractedRuntime);
await rename(extractedRuntime, resolve(capsuleRoot, "runtime"));

const npmPackagePath = resolve(capsuleRoot, dirname(target.npmCli), "..", "package.json");
const npmPackage = await readJson(npmPackagePath);
if (typeof npmPackage.version !== "string" || npmPackage.version.length === 0) {
  throw new Error("The official Node archive does not contain readable npm package metadata.");
}
for (const licensePath of [target.nodeLicense, target.npmLicense]) {
  await access(resolve(capsuleRoot, ...licensePath.split("/")));
}

await stageProductionApplication(stageRoot, source);
await rename(resolve(stageRoot, "node"), resolve(capsuleRoot, "app"));
await Promise.all([
  copyFileWithParents(resolve(nodeRoot, "bun.lock"), resolve(capsuleRoot, NODE_LOCK_PATH)),
  copyFileWithParents(resolve(protocolRoot, "bun.lock"), resolve(capsuleRoot, PROTOCOL_LOCK_PATH)),
  copyFileWithParents(schemaSource, resolve(capsuleRoot, CAPSULE_SCHEMA_PATH)),
]);

await verifyPackageMetadata(capsuleRoot, {
  application: {
    packagePath: "app/package.json",
    protocolPackagePath: "app/node_modules/@pi-client/protocol",
  },
  versions: {
    piNode: source.nodePackage.version,
    protocol: source.protocolPackage.version,
  },
});
await scanForbiddenArtifacts(capsuleRoot, {
  absoluteBuildPaths: [repositoryRoot, stageRoot, extractRoot],
});
await assertCleanCapsuleSources();

const sourceCommit = run("git", ["-C", repositoryRoot, "rev-parse", "HEAD"]).stdout.trim();
const archiveSha256 = await sha256File(archivePath);
const manifest = await createCapsuleManifest(capsuleRoot, {
  sourceCommit,
  target,
  piNodeVersion: source.nodePackage.version,
  protocolVersion: source.protocolPackage.version,
  npmVersion: npmPackage.version,
  nodeLockSha256: await sha256File(resolve(nodeRoot, "bun.lock")),
  protocolLockSha256: await sha256File(resolve(protocolRoot, "bun.lock")),
  archiveSha256,
  checksumsSha256: await sha256File(shasumsPath),
});
await writeDeterministicJson(resolve(capsuleRoot, "capsule-manifest.json"), manifest);
await scanForbiddenArtifacts(capsuleRoot, {
  absoluteBuildPaths: [repositoryRoot, stageRoot, extractRoot],
});
await makeTreeReadOnly(capsuleRoot);

run(process.execPath, [verifyScript, capsuleRoot], {
  env: {
    ...process.env,
    PI_RUNTIME_CAPSULE_EXPECTED_SOURCE_COMMIT: sourceCommit,
  },
});
const manifestMetadata = await stat(resolve(capsuleRoot, "capsule-manifest.json"));
const capsuleSize = manifest.integrity.payloadSize + manifestMetadata.size;
process.stdout.write(
  `${JSON.stringify(
    {
      capsulePath: capsuleRoot,
      capsuleSize,
      payloadFileCount: manifest.integrity.payloadFileCount,
      sourceCommit,
      target: target.id,
      node: {
        version: NODE_RUNTIME_VERSION,
        archive: target.archiveName,
        archiveUrl: target.archiveUrl,
        sha256: archiveSha256,
        checksumsUrl: NODE_SHASUMS_URL,
      },
      npmVersion: npmPackage.version,
      piNodeVersion: source.nodePackage.version,
      protocolVersion: source.protocolPackage.version,
      piSdkVersion: REQUIRED_PI_SDK_VERSION,
    },
    null,
    2,
  )}\n`,
);

function parseTarget(arguments_) {
  let target = currentCapsuleTargetId();
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (argument === "--target") {
      target = arguments_[++index];
      if (!target) {
        throw new Error("--target requires a target identifier.");
      }
      continue;
    }
    if (argument.startsWith("--target=")) {
      target = argument.slice("--target=".length);
      continue;
    }
    throw new Error(`Unsupported runtime capsule build argument ${argument}.`);
  }
  return target;
}

async function assertCleanCapsuleSources() {
  const tracked = run("git", [
    "-C",
    repositoryRoot,
    "status",
    "--porcelain",
    "--untracked-files=normal",
    "--",
    "node",
    "protocol",
  ]).stdout.trim();
  if (tracked.length > 0) {
    throw new Error(
      `Runtime capsule source must be committed before assembly. Dirty paths:\n${tracked}`,
    );
  }
}

async function verifySourceMetadata() {
  const [nodePackage, protocolPackage, nodeLock, protocolLock] = await Promise.all([
    readJson(resolve(nodeRoot, "package.json")),
    readJson(resolve(protocolRoot, "package.json")),
    readJson(resolve(nodeRoot, "bun.lock")),
    readJson(resolve(protocolRoot, "bun.lock")),
  ]);
  requireExact(nodePackage.packageManager, `bun@${REQUIRED_BUN_VERSION}`, "Node packageManager");
  requireExact(
    protocolPackage.packageManager,
    `bun@${REQUIRED_BUN_VERSION}`,
    "protocol packageManager",
  );
  requireExact(nodePackage.engines?.node, `>=${NODE_RUNTIME_VERSION}`, "Node engine");
  requireExact(protocolPackage.engines?.node, `>=${NODE_RUNTIME_VERSION}`, "protocol Node engine");
  requireExact(
    nodePackage.dependencies?.["@earendil-works/pi-coding-agent"],
    REQUIRED_PI_SDK_VERSION,
    "Pi SDK dependency",
  );
  requireExact(
    nodePackage.dependencies?.["@bufbuild/protobuf"],
    REQUIRED_PROTOBUF_VERSION,
    "Node protobuf dependency",
  );
  requireExact(
    nodePackage.dependencies?.["@pi-client/protocol"],
    "file:../protocol",
    "local protocol dependency",
  );
  requireExact(
    protocolPackage.dependencies?.["@bufbuild/protobuf"],
    REQUIRED_PROTOBUF_VERSION,
    "protocol protobuf dependency",
  );
  requireExact(
    nodeLock.workspaces?.[""]?.dependencies?.["@earendil-works/pi-coding-agent"],
    REQUIRED_PI_SDK_VERSION,
    "Node lock Pi SDK dependency",
  );
  requireExact(
    nodeLock.workspaces?.[""]?.dependencies?.["@pi-client/protocol"],
    "file:../protocol",
    "Node lock protocol dependency",
  );
  requireResolution(
    nodeLock.packages?.["@earendil-works/pi-coding-agent"]?.[0],
    `@earendil-works/pi-coding-agent@${REQUIRED_PI_SDK_VERSION}`,
    "Node lock Pi SDK resolution",
  );
  requireResolution(
    nodeLock.packages?.["@pi-client/protocol"]?.[0],
    "@pi-client/protocol@file:../protocol",
    "Node lock protocol resolution",
  );
  requireExact(
    protocolLock.workspaces?.[""]?.dependencies?.["@bufbuild/protobuf"],
    REQUIRED_PROTOBUF_VERSION,
    "protocol lock protobuf dependency",
  );
  requireResolution(
    protocolLock.packages?.["@bufbuild/protobuf"]?.[0],
    `@bufbuild/protobuf@${REQUIRED_PROTOBUF_VERSION}`,
    "protocol lock protobuf resolution",
  );
  return { nodePackage, protocolPackage };
}

async function verifyBuilderToolchain() {
  const bunVersion = run("bun", ["--version"]).stdout.trim();
  requireExact(bunVersion, REQUIRED_BUN_VERSION, "Bun builder version");
  const [major, minor, patch] = process.versions.node.split(".").map(Number);
  if (major < 22 || (major === 22 && minor < 19) || (major === 22 && minor === 19 && patch < 0)) {
    throw new Error(`Capsule builder requires host Node.js >=22.19.0; found ${process.version}.`);
  }
}

async function buildSourcePackages() {
  await Promise.all([
    rm(resolve(protocolRoot, "dist"), { recursive: true, force: true }),
    rm(resolve(nodeRoot, "dist"), { recursive: true, force: true }),
  ]);
  run("bun", ["install", "--cwd", protocolRoot, "--frozen-lockfile"]);
  run("bun", ["run", "--cwd", protocolRoot, "build:package"]);
  run("bun", ["install", "--cwd", nodeRoot, "--frozen-lockfile"]);
  run("bun", ["run", "--cwd", nodeRoot, "build:raw"]);
  await Promise.all([
    access(resolve(protocolRoot, "dist/src/index.js")),
    access(resolve(nodeRoot, "dist/stdio-main.js")),
    access(resolve(nodeRoot, "dist/index.js")),
  ]);
}

async function stageProductionApplication(stageRoot, source) {
  const stageNode = resolve(stageRoot, "node");
  const stageProtocol = resolve(stageRoot, "protocol");
  await Promise.all([
    mkdir(stageNode, { recursive: true }),
    mkdir(stageProtocol, { recursive: true }),
  ]);
  await Promise.all([
    copyFileWithParents(resolve(nodeRoot, "package.json"), resolve(stageNode, "package.json")),
    copyFileWithParents(resolve(nodeRoot, "bun.lock"), resolve(stageNode, "bun.lock")),
    copyRealPackage(resolve(nodeRoot, "dist"), resolve(stageNode, "dist")),
    copyRealPackage(resolve(protocolRoot, "dist"), resolve(stageProtocol, "dist")),
  ]);
  await writeDeterministicJson(
    resolve(stageProtocol, "package.json"),
    runtimeProtocolPackage(source.protocolPackage),
  );

  run(
    "bun",
    [
      "install",
      "--cwd",
      stageNode,
      "--frozen-lockfile",
      "--production",
      "--ignore-scripts",
      "--backend=copyfile",
    ],
    {
      env: {
        ...process.env,
        BUN_INSTALL_CACHE_DIR: resolve(tempRoot, "bun-cache", target.id),
      },
    },
  );

  await copyRealPackage(stageProtocol, resolve(stageNode, "node_modules/@pi-client/protocol"));
  await writeDeterministicJson(
    resolve(stageNode, "package.json"),
    runtimeNodePackage(source.nodePackage, source.protocolPackage.version),
  );
  await rm(resolve(stageNode, "bun.lock"), { force: true });
}

function runtimeNodePackage(sourcePackage, protocolVersion) {
  return {
    name: sourcePackage.name,
    version: sourcePackage.version,
    private: true,
    type: "module",
    engines: { node: `>=${NODE_RUNTIME_VERSION}` },
    exports: sourcePackage.exports,
    bin: sourcePackage.bin,
    dependencies: {
      "@bufbuild/protobuf": REQUIRED_PROTOBUF_VERSION,
      "@earendil-works/pi-coding-agent": REQUIRED_PI_SDK_VERSION,
      "@pi-client/protocol": protocolVersion,
    },
  };
}

function runtimeProtocolPackage(sourcePackage) {
  return {
    name: sourcePackage.name,
    version: sourcePackage.version,
    private: true,
    type: "module",
    engines: { node: `>=${NODE_RUNTIME_VERSION}` },
    exports: sourcePackage.exports,
    dependencies: {
      "@bufbuild/protobuf": REQUIRED_PROTOBUF_VERSION,
    },
  };
}

async function ensureDownload(url, destination, options = {}) {
  if (!options.refresh) {
    try {
      const metadata = await stat(destination);
      if (metadata.isFile() && metadata.size > 0) {
        return;
      }
    } catch (error) {
      if (!error || error.code !== "ENOENT") {
        throw error;
      }
    }
  }
  const response = await fetch(url, { redirect: "follow" });
  if (!response.ok) {
    throw new Error(`Download failed for ${url}: HTTP ${response.status}.`);
  }
  const bytes = Buffer.from(await response.arrayBuffer());
  await mkdir(dirname(destination), { recursive: true });
  const temporary = `${destination}.partial-${process.pid}`;
  await writeFile(temporary, bytes);
  await rename(temporary, destination);
}

async function ensureVerifiedArchive(url, destination, expectedSha256) {
  await ensureDownload(url, destination);
  let actualSha256 = await sha256File(destination);
  if (actualSha256 !== expectedSha256) {
    await rm(destination, { force: true });
    await ensureDownload(url, destination);
    actualSha256 = await sha256File(destination);
  }
  if (actualSha256 !== expectedSha256) {
    throw new Error(
      `Official Node archive checksum mismatch for ${target.archiveName}: expected ${expectedSha256}, found ${actualSha256}.`,
    );
  }
}

async function extractRuntime(archivePath, destination, distribution) {
  if (!["tar.gz", "tar.xz", "zip"].includes(distribution.archiveKind)) {
    throw new Error(`Unsupported Node archive kind ${distribution.archiveKind}.`);
  }
  run("tar", ["-xf", archivePath, "-C", destination]);
}

function run(executable, arguments_, options = {}) {
  const result = spawnSync(executable, arguments_, {
    cwd: options.cwd ?? repositoryRoot,
    env: options.env ?? process.env,
    encoding: "utf8",
    stdio: options.capture === false ? "inherit" : ["ignore", "pipe", "pipe"],
  });
  if (result.error) {
    throw result.error;
  }
  if (result.status !== 0) {
    throw new Error(
      `Command failed (${result.status}): ${executable} ${arguments_.join(" ")}\n${result.stderr ?? ""}`,
    );
  }
  return { stdout: result.stdout ?? "", stderr: result.stderr ?? "" };
}

function requireExact(actual, expected, field) {
  if (actual !== expected) {
    throw new Error(`${field} must be ${expected}; found ${actual}.`);
  }
}

function requireResolution(actual, expected, field) {
  requireExact(actual, expected, field);
}
