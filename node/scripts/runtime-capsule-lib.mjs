import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { createReadStream } from "node:fs";
import {
  chmod,
  cp,
  lstat,
  mkdir,
  open,
  readFile,
  readdir,
  readlink,
  realpath,
  rm,
  stat,
  writeFile,
} from "node:fs/promises";
import { dirname, isAbsolute, relative, resolve, sep } from "node:path";
import { pathToFileURL } from "node:url";

import {
  CAPSULE_SCHEMA_VERSION,
  NODE_RUNTIME_VERSION,
  NODE_SHASUMS_URL,
  REQUIRED_BUN_VERSION,
  REQUIRED_PI_SDK_VERSION,
  REQUIRED_PROTOBUF_VERSION,
  resolveNodeDistribution,
} from "./runtime-capsule-config.mjs";

export const CAPSULE_MANIFEST_NAME = "capsule-manifest.json";
export const CAPSULE_SCHEMA_PATH = "metadata/schemas/capsule-manifest.schema.json";
export const NODE_LOCK_PATH = "metadata/locks/node.bun.lock";
export const PROTOCOL_LOCK_PATH = "metadata/locks/protocol.bun.lock";
export const APPLICATION_ENTRYPOINT = "app/dist/stdio-main.js";
export const APPLICATION_PACKAGE_PATH = "app/package.json";
export const PROTOCOL_PACKAGE_PATH = "app/node_modules/@pi-client/protocol";
export const PACKAGE_INVENTORY_PATH = "metadata/packages.json";
export const LICENSE_INVENTORY_PATH = "metadata/licenses.json";

export async function readJson(path) {
  return JSON.parse(await readFile(path, "utf8"));
}

export async function readBunLock(path) {
  return JSON.parse(stripTrailingCommas(await readFile(path, "utf8")));
}

export function stripTrailingCommas(text) {
  let output = "";
  let inString = false;
  let escaped = false;
  for (let index = 0; index < text.length; index += 1) {
    const character = text[index];
    if (inString) {
      output += character;
      if (escaped) {
        escaped = false;
      } else if (character === "\\") {
        escaped = true;
      } else if (character === '"') {
        inString = false;
      }
      continue;
    }
    if (character === '"') {
      inString = true;
      output += character;
      continue;
    }
    if (character === ",") {
      let lookahead = index + 1;
      while (lookahead < text.length && /\s/u.test(text[lookahead])) {
        lookahead += 1;
      }
      if (text[lookahead] === "}" || text[lookahead] === "]") {
        continue;
      }
    }
    output += character;
  }
  if (inString || escaped) {
    throw new Error("Bun lock contains an unterminated JSON string.");
  }
  return output;
}

export async function writeDeterministicJson(path, value) {
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, `${stableStringify(value)}\n`, "utf8");
}

export function stableStringify(value) {
  return JSON.stringify(sortJson(value), null, 2);
}

function sortJson(value) {
  if (Array.isArray(value)) {
    return value.map(sortJson);
  }
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.keys(value)
        .sort()
        .map((key) => [key, sortJson(value[key])]),
    );
  }
  return value;
}

export async function sha256File(path) {
  const hash = createHash("sha256");
  for await (const chunk of createReadStream(path)) {
    hash.update(chunk);
  }
  return hash.digest("hex");
}

export function sha256Text(value) {
  return createHash("sha256").update(value).digest("hex");
}

export function normalizeCapsulePath(value, field = "capsule path") {
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`${field} must be a non-empty relative path.`);
  }
  if (
    isAbsolute(value) ||
    /^[A-Za-z]:[\\/]/u.test(value) ||
    value.includes("\\") ||
    value.startsWith("./") ||
    value.endsWith("/")
  ) {
    throw new Error(`${field} must be a normalized relative POSIX path: ${value}`);
  }
  const segments = value.split("/");
  if (segments.some((segment) => segment.length === 0 || segment === "." || segment === "..")) {
    throw new Error(`${field} contains a forbidden path segment: ${value}`);
  }
  return value;
}

export function resolveCapsulePath(capsuleRoot, manifestPath, field = "capsule path") {
  const normalized = normalizeCapsulePath(manifestPath, field);
  const absolute = resolve(capsuleRoot, ...normalized.split("/"));
  assertPathInside(capsuleRoot, absolute, field);
  return absolute;
}

export function assertPathInside(root, candidate, field = "path") {
  const relativePath = relative(resolve(root), resolve(candidate));
  if (relativePath === "" || (!relativePath.startsWith(`..${sep}`) && relativePath !== "..")) {
    return;
  }
  throw new Error(`${field} escapes its root directory.`);
}

export async function collectPayloadEntries(capsuleRoot) {
  const entries = [];
  await collectDirectory(capsuleRoot, "", entries);
  return entries
    .filter((entry) => entry.path !== CAPSULE_MANIFEST_NAME)
    .sort((left, right) => compareText(left.path, right.path));
}

async function collectDirectory(root, relativeDirectory, output) {
  const directory = relativeDirectory ? resolveCapsulePath(root, relativeDirectory) : root;
  const names = await readdir(directory, { withFileTypes: true });
  names.sort((left, right) => compareText(left.name, right.name));
  for (const name of names) {
    const relativePath = relativeDirectory ? `${relativeDirectory}/${name.name}` : name.name;
    normalizeCapsulePath(relativePath);
    const absolutePath = resolveCapsulePath(root, relativePath);
    const metadata = await lstat(absolutePath);
    if (metadata.isSymbolicLink()) {
      const target = await readlink(absolutePath);
      if (isAbsolute(target) || /^[A-Za-z]:[\\/]/u.test(target)) {
        throw new Error(`Capsule symlink ${relativePath} has an absolute target.`);
      }
      const resolvedTarget = resolve(dirname(absolutePath), target);
      assertPathInside(root, resolvedTarget, `Capsule symlink ${relativePath}`);
      const realTarget = await realpath(absolutePath).catch(() => {
        throw new Error(`Capsule symlink ${relativePath} is dangling.`);
      });
      assertPathInside(root, realTarget, `Capsule symlink ${relativePath} resolved target`);
      output.push({
        path: relativePath,
        type: "symlink",
        target,
        size: Buffer.byteLength(target),
        sha256: sha256Text(target),
      });
      continue;
    }
    if (metadata.isDirectory()) {
      await collectDirectory(root, relativePath, output);
      continue;
    }
    if (!metadata.isFile()) {
      throw new Error(`Capsule payload contains unsupported filesystem entry ${relativePath}.`);
    }
    output.push({
      path: relativePath,
      type: "file",
      size: metadata.size,
      sha256: await sha256File(absolutePath),
      executable:
        process.platform === "win32"
          ? relativePath === "runtime/node.exe"
          : (metadata.mode & 0o111) !== 0,
    });
  }
}

export async function normalizeCapsuleFileModes(capsuleRoot, runtimeExecutable, options = {}) {
  if (process.platform === "win32") return;
  const normalizedExecutable = normalizeCapsulePath(runtimeExecutable, "runtime executable");
  await visitTree(capsuleRoot, async (path, metadata) => {
    if (metadata.isSymbolicLink()) return;
    if (metadata.isDirectory()) {
      await chmod(path, 0o755);
      return;
    }
    const relativePath = relative(capsuleRoot, path).split(sep).join("/");
    if (options.leaveManifestWritable && relativePath === CAPSULE_MANIFEST_NAME) {
      await chmod(path, 0o644);
      return;
    }
    await chmod(path, relativePath === normalizedExecutable ? 0o555 : 0o444);
  });
}

export async function assertCapsuleFileModes(capsuleRoot, runtimeExecutable) {
  if (process.platform === "win32") return;
  const normalizedExecutable = normalizeCapsulePath(runtimeExecutable, "runtime executable");
  await visitTree(capsuleRoot, async (path, metadata) => {
    if (metadata.isSymbolicLink()) return;
    const relativePath = relative(capsuleRoot, path).split(sep).join("/");
    const mode = metadata.mode & 0o777;
    if (metadata.isDirectory()) {
      if (mode !== 0o555) {
        throw new Error(`Capsule directory mode must be 0555: ${relativePath || "."}.`);
      }
      return;
    }
    const expectedMode = relativePath === normalizedExecutable ? 0o555 : 0o444;
    if (mode !== expectedMode) {
      throw new Error(
        `Capsule file mode mismatch at ${relativePath}: expected ${expectedMode.toString(8)}, found ${mode.toString(8)}.`,
      );
    }
  });
}

export async function collectNativeCodeInventory(capsuleRoot, target) {
  const objects = [];
  await visitTree(capsuleRoot, async (path, metadata) => {
    if (!metadata.isFile() || metadata.isSymbolicLink()) return;
    const relativePath = relative(capsuleRoot, path).split(sep).join("/");
    const nativeAddon = relativePath.endsWith(".node");
    const runtimeExecutable = relativePath === target.executable;
    const nativeBinary = await inspectNativeBinary(path);
    if (!nativeAddon && !runtimeExecutable && nativeBinary.format === "unknown") return;
    const dynamicLibrary = /\.(?:dll|dylib|so(?:\.[0-9]+)*)$/iu.test(relativePath);
    objects.push({
      path: relativePath,
      kind: runtimeExecutable
        ? "runtime-executable"
        : nativeAddon
          ? "native-addon"
          : dynamicLibrary
            ? "dynamic-library"
            : "executable",
      format: nativeBinary.format,
      architectures: nativeBinary.architectures,
    });
  });
  objects.sort((left, right) => compareText(left.path, right.path));
  return {
    format: target.platform === "darwin" ? "mach-o" : "platform-native",
    objects,
    signingOrder: expectedNativeSigningOrder(objects),
  };
}

export async function pruneNativeAddonsForTarget(appRoot, target) {
  const removed = [];
  const retained = [];
  await visitTree(appRoot, async (path, metadata) => {
    if (!metadata.isFile() || metadata.isSymbolicLink() || !path.endsWith(".node")) return;
    const nativeBinary = await inspectNativeBinary(path);
    const matchesPlatform = nativeBinary.format === expectedBinaryFormat(target.platform);
    const matchesArchitecture = nativeBinary.architectures.some((architecture) =>
      target.architectures.includes(architecture),
    );
    const relativePath = relative(appRoot, path).split(sep).join("/");
    if (!matchesPlatform || !matchesArchitecture) {
      await rm(path, { force: true });
      removed.push(relativePath);
    } else {
      retained.push(relativePath);
    }
  });
  removed.sort(compareText);
  retained.sort(compareText);
  return { removed, retained };
}

export async function inspectNativeBinary(path) {
  if (process.platform === "darwin") {
    const description = runFileDescription(path);
    if (description.includes("Mach-O")) {
      return { format: "mach-o", architectures: readMachOArchitectures(path) };
    }
  }
  const handle = await open(path, "r");
  try {
    const header = Buffer.alloc(4096);
    const { bytesRead } = await handle.read(header, 0, header.length, 0);
    return inspectNativeBinaryBytes(header.subarray(0, bytesRead));
  } finally {
    await handle.close();
  }
}

export function inspectNativeBinaryBytes(bytes) {
  if (bytes.length >= 20 && bytes.subarray(0, 4).equals(Buffer.from([0x7f, 0x45, 0x4c, 0x46]))) {
    const littleEndian = bytes[5] === 1;
    const machine = littleEndian ? bytes.readUInt16LE(18) : bytes.readUInt16BE(18);
    const architecture = machine === 0x3e ? "x64" : machine === 0xb7 ? "arm64" : undefined;
    return { format: "elf", architectures: architecture ? [architecture] : [] };
  }
  if (bytes.length >= 0x40 && bytes[0] === 0x4d && bytes[1] === 0x5a) {
    const peOffset = bytes.readUInt32LE(0x3c);
    if (
      peOffset + 6 <= bytes.length &&
      bytes.subarray(peOffset, peOffset + 4).equals(Buffer.from("PE\0\0", "binary"))
    ) {
      const machine = bytes.readUInt16LE(peOffset + 4);
      const architecture = machine === 0x8664 ? "x64" : machine === 0xaa64 ? "arm64" : undefined;
      return { format: "pe-coff", architectures: architecture ? [architecture] : [] };
    }
  }
  return { format: "unknown", architectures: [] };
}

function expectedBinaryFormat(platform) {
  return platform === "darwin" ? "mach-o" : platform === "linux" ? "elf" : "pe-coff";
}

function expectedNativeSigningOrder(objects) {
  return objects
    .filter((entry) => entry.format === "mach-o")
    .sort((left, right) => {
      const leftRuntime = left.kind === "runtime-executable";
      const rightRuntime = right.kind === "runtime-executable";
      if (leftRuntime !== rightRuntime) return leftRuntime ? 1 : -1;
      const depthDifference = right.path.split("/").length - left.path.split("/").length;
      return depthDifference || compareText(left.path, right.path);
    })
    .map((entry) => entry.path);
}

function runFileDescription(path) {
  const executable = process.platform === "darwin" ? "/usr/bin/file" : "file";
  const result = spawnSync(executable, ["-b", path], { encoding: "utf8" });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`file failed for ${path}: ${(result.stderr ?? "").trim()}`);
  }
  return result.stdout.trim();
}

function readMachOArchitectures(path) {
  if (process.platform !== "darwin") {
    throw new Error("Mach-O architecture inventory requires macOS lipo.");
  }
  const result = spawnSync("/usr/bin/lipo", ["-archs", path], { encoding: "utf8" });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`lipo failed for ${path}: ${(result.stderr ?? "").trim()}`);
  }
  const discovered = new Set(
    result.stdout
      .trim()
      .split(/\s+/u)
      .filter(Boolean)
      .map((architecture) => (architecture === "x86_64" ? "x64" : architecture)),
  );
  const ordered = ["arm64", "x64"].filter((architecture) => discovered.delete(architecture));
  return [...ordered, ...[...discovered].sort(compareText)];
}

export async function createCapsuleManifest(capsuleRoot, metadata) {
  const integrity = await createIntegrityRecord(capsuleRoot);
  const nativeCode = await collectNativeCodeInventory(capsuleRoot, metadata.target);
  return {
    schemaVersion: CAPSULE_SCHEMA_VERSION,
    capsuleKind: "pi-node-runtime",
    sourceCommit: metadata.sourceCommit,
    target: {
      id: metadata.target.id,
      platform: metadata.target.platform,
      architecture: metadata.target.architecture,
      architectures: [...metadata.target.architectures],
    },
    versions: {
      piNode: metadata.piNodeVersion,
      protocol: metadata.protocolVersion,
      piSdk: REQUIRED_PI_SDK_VERSION,
      protobuf: REQUIRED_PROTOBUF_VERSION,
      node: NODE_RUNTIME_VERSION,
      npm: metadata.npmVersion,
      bunBuilder: REQUIRED_BUN_VERSION,
    },
    locks: [
      {
        name: "node",
        sourcePath: "node/bun.lock",
        capsulePath: NODE_LOCK_PATH,
        sha256: metadata.nodeLockSha256,
      },
      {
        name: "protocol",
        sourcePath: "protocol/bun.lock",
        capsulePath: PROTOCOL_LOCK_PATH,
        sha256: metadata.protocolLockSha256,
      },
    ],
    runtime: {
      distributions: metadata.target.distributions.map((distribution) => ({
        architecture: distribution.architecture,
        archiveName: distribution.archiveName,
        archiveUrl: distribution.archiveUrl,
        checksumsUrl: NODE_SHASUMS_URL,
        archiveSha256: distribution.archiveSha256,
        checksumsSha256: metadata.checksumsSha256,
      })),
      architectureArguments: metadata.target.architectureArguments.map((entry) => ({
        architecture: entry.architecture,
        arguments: [...entry.arguments],
      })),
      executable: metadata.target.executable,
      npmCli: metadata.target.npmCli,
      licenses: [metadata.target.nodeLicense, metadata.target.npmLicense],
    },
    application: {
      packagePath: APPLICATION_PACKAGE_PATH,
      entrypoint: APPLICATION_ENTRYPOINT,
      protocolPackagePath: PROTOCOL_PACKAGE_PATH,
      launch: [metadata.target.executable, APPLICATION_ENTRYPOINT],
    },
    nativeCode,
    integrity,
  };
}

export async function resealCapsuleManifest(capsuleRoot) {
  const manifestPath = resolve(capsuleRoot, CAPSULE_MANIFEST_NAME);
  const manifest = await readJson(manifestPath);
  const target = validateManifestDocument(manifest);
  await normalizeCapsuleFileModes(capsuleRoot, target.executable, {
    leaveManifestWritable: true,
  });
  const nativeCode = await collectNativeCodeInventory(capsuleRoot, target);
  if (stableStringify(nativeCode) !== stableStringify(manifest.nativeCode)) {
    throw new Error("Capsule native-code inventory changed while signing.");
  }
  const resealed = {
    ...manifest,
    nativeCode,
    integrity: await createIntegrityRecord(capsuleRoot),
  };
  await writeDeterministicJson(manifestPath, resealed);
  if (process.platform !== "win32") {
    await chmod(manifestPath, 0o444);
  }
  return resealed;
}

async function createIntegrityRecord(capsuleRoot) {
  const files = await collectPayloadEntries(capsuleRoot);
  return {
    algorithm: "sha256",
    manifestExcludedPath: CAPSULE_MANIFEST_NAME,
    payloadFileCount: files.length,
    payloadSize: files.reduce((total, entry) => total + entry.size, 0),
    files,
  };
}

export function validateManifestDocument(manifest) {
  requireRecord(manifest, "manifest");
  requireExactKeys(
    manifest,
    [
      "schemaVersion",
      "capsuleKind",
      "sourceCommit",
      "target",
      "versions",
      "locks",
      "runtime",
      "application",
      "nativeCode",
      "integrity",
    ],
    "manifest",
  );
  if (manifest.schemaVersion !== CAPSULE_SCHEMA_VERSION) {
    throw new Error(`Unsupported capsule manifest schema version ${manifest.schemaVersion}.`);
  }
  if (manifest.capsuleKind !== "pi-node-runtime") {
    throw new Error("Capsule manifest kind is not pi-node-runtime.");
  }
  if (!/^[0-9a-f]{40}$/u.test(manifest.sourceCommit ?? "")) {
    throw new Error("Capsule sourceCommit must be a full lowercase Git commit.");
  }

  requireRecord(manifest.target, "manifest.target");
  requireExactKeys(
    manifest.target,
    ["id", "platform", "architecture", "architectures"],
    "manifest.target",
  );
  const target = resolveNodeDistribution(manifest.target.id);
  if (
    manifest.target.platform !== target.platform ||
    manifest.target.architecture !== target.architecture ||
    !Array.isArray(manifest.target.architectures) ||
    stableStringify(manifest.target.architectures) !== stableStringify(target.architectures)
  ) {
    throw new Error("Capsule target metadata does not match its target identifier.");
  }

  requireRecord(manifest.versions, "manifest.versions");
  requireExactKeys(
    manifest.versions,
    ["piNode", "protocol", "piSdk", "protobuf", "node", "npm", "bunBuilder"],
    "manifest.versions",
  );
  requireExactString(manifest.versions.node, NODE_RUNTIME_VERSION, "manifest.versions.node");
  requireExactString(
    manifest.versions.bunBuilder,
    REQUIRED_BUN_VERSION,
    "manifest.versions.bunBuilder",
  );
  requireExactString(manifest.versions.piSdk, REQUIRED_PI_SDK_VERSION, "manifest.versions.piSdk");
  requireExactString(
    manifest.versions.protobuf,
    REQUIRED_PROTOBUF_VERSION,
    "manifest.versions.protobuf",
  );
  for (const field of ["piNode", "protocol", "npm"]) {
    if (typeof manifest.versions[field] !== "string" || manifest.versions[field].length === 0) {
      throw new Error(`manifest.versions.${field} must be non-empty.`);
    }
  }

  if (!Array.isArray(manifest.locks) || manifest.locks.length !== 2) {
    throw new Error("Capsule manifest must seal exactly the node and protocol locks.");
  }
  const expectedLocks = new Map([
    ["node", { sourcePath: "node/bun.lock", capsulePath: NODE_LOCK_PATH }],
    ["protocol", { sourcePath: "protocol/bun.lock", capsulePath: PROTOCOL_LOCK_PATH }],
  ]);
  for (const [lockIndex, lock] of manifest.locks.entries()) {
    requireRecord(lock, "manifest lock");
    requireExactKeys(lock, ["name", "sourcePath", "capsulePath", "sha256"], "manifest lock");
    if (lock.name !== ["node", "protocol"][lockIndex]) {
      throw new Error("Capsule locks must remain in deterministic node/protocol order.");
    }
    const expected = expectedLocks.get(lock.name);
    if (!expected) {
      throw new Error(`Capsule manifest contains an unexpected lock ${lock.name}.`);
    }
    normalizeCapsulePath(lock.sourcePath, "lock sourcePath");
    normalizeCapsulePath(lock.capsulePath, "lock capsulePath");
    if (lock.sourcePath !== expected.sourcePath || lock.capsulePath !== expected.capsulePath) {
      throw new Error(`Capsule lock ${lock.name} uses an unexpected path.`);
    }
    requireSha256(lock.sha256, `lock ${lock.name} sha256`);
    expectedLocks.delete(lock.name);
  }
  if (expectedLocks.size !== 0) {
    throw new Error("Capsule manifest omits a required lock.");
  }

  requireRecord(manifest.runtime, "manifest.runtime");
  requireExactKeys(
    manifest.runtime,
    ["distributions", "architectureArguments", "executable", "npmCli", "licenses"],
    "manifest.runtime",
  );
  if (
    !Array.isArray(manifest.runtime.distributions) ||
    manifest.runtime.distributions.length !== target.distributions.length
  ) {
    throw new Error("Capsule runtime distribution provenance is incomplete.");
  }
  for (const [index, runtimeDistribution] of manifest.runtime.distributions.entries()) {
    const expectedDistribution = target.distributions[index];
    requireRecord(runtimeDistribution, "runtime distribution");
    requireExactKeys(
      runtimeDistribution,
      [
        "architecture",
        "archiveName",
        "archiveUrl",
        "checksumsUrl",
        "archiveSha256",
        "checksumsSha256",
      ],
      "runtime distribution",
    );
    requireExactString(
      runtimeDistribution.architecture,
      expectedDistribution.architecture,
      "runtime distribution architecture",
    );
    requireExactString(
      runtimeDistribution.archiveName,
      expectedDistribution.archiveName,
      "runtime archiveName",
    );
    requireExactString(
      runtimeDistribution.archiveUrl,
      expectedDistribution.archiveUrl,
      "runtime archiveUrl",
    );
    requireExactString(runtimeDistribution.checksumsUrl, NODE_SHASUMS_URL, "runtime checksumsUrl");
    requireExactString(
      runtimeDistribution.archiveSha256,
      expectedDistribution.archiveSha256,
      "runtime archiveSha256",
    );
    requireSha256(runtimeDistribution.checksumsSha256, "runtime checksumsSha256");
  }
  if (
    !Array.isArray(manifest.runtime.architectureArguments) ||
    manifest.runtime.architectureArguments.length !== target.architectureArguments.length
  ) {
    throw new Error("Capsule runtime architecture arguments are incomplete.");
  }
  for (const [index, architectureArguments] of manifest.runtime.architectureArguments.entries()) {
    const expected = target.architectureArguments[index];
    requireRecord(architectureArguments, "runtime architecture arguments");
    requireExactKeys(
      architectureArguments,
      ["architecture", "arguments"],
      "runtime architecture arguments",
    );
    requireExactString(
      architectureArguments.architecture,
      expected.architecture,
      "runtime argument architecture",
    );
    if (stableStringify(architectureArguments.arguments) !== stableStringify(expected.arguments)) {
      throw new Error("Capsule runtime arguments exceed the architecture policy.");
    }
  }
  requireExactString(manifest.runtime.executable, target.executable, "runtime executable");
  requireExactString(manifest.runtime.npmCli, target.npmCli, "runtime npmCli");
  if (
    !Array.isArray(manifest.runtime.licenses) ||
    manifest.runtime.licenses.length !== 2 ||
    manifest.runtime.licenses[0] !== target.nodeLicense ||
    manifest.runtime.licenses[1] !== target.npmLicense
  ) {
    throw new Error("Capsule runtime license paths are incomplete or mutable.");
  }
  normalizeCapsulePath(manifest.runtime.executable, "runtime executable");
  normalizeCapsulePath(manifest.runtime.npmCli, "runtime npmCli");
  manifest.runtime.licenses.forEach((path) => normalizeCapsulePath(path, "runtime license"));

  requireRecord(manifest.application, "manifest.application");
  requireExactKeys(
    manifest.application,
    ["packagePath", "entrypoint", "protocolPackagePath", "launch"],
    "manifest.application",
  );
  requireExactString(
    manifest.application.packagePath,
    APPLICATION_PACKAGE_PATH,
    "application packagePath",
  );
  requireExactString(
    manifest.application.entrypoint,
    APPLICATION_ENTRYPOINT,
    "application entrypoint",
  );
  requireExactString(
    manifest.application.protocolPackagePath,
    PROTOCOL_PACKAGE_PATH,
    "application protocolPackagePath",
  );
  const expectedLaunch = [target.executable, APPLICATION_ENTRYPOINT];
  if (
    !Array.isArray(manifest.application.launch) ||
    manifest.application.launch.length !== expectedLaunch.length ||
    manifest.application.launch.some((value, index) => value !== expectedLaunch[index])
  ) {
    throw new Error("Capsule launch command is not the sealed runtime entrypoint.");
  }
  for (const path of [
    manifest.application.packagePath,
    manifest.application.entrypoint,
    manifest.application.protocolPackagePath,
    ...manifest.application.launch,
  ]) {
    normalizeCapsulePath(path, "application path");
  }

  validateNativeCodeDocument(manifest.nativeCode, target);

  requireRecord(manifest.integrity, "manifest.integrity");
  requireExactKeys(
    manifest.integrity,
    ["algorithm", "manifestExcludedPath", "payloadFileCount", "payloadSize", "files"],
    "manifest.integrity",
  );
  if (
    manifest.integrity.algorithm !== "sha256" ||
    manifest.integrity.manifestExcludedPath !== CAPSULE_MANIFEST_NAME
  ) {
    throw new Error("Capsule integrity policy contains a mutable omission.");
  }
  if (!Array.isArray(manifest.integrity.files)) {
    throw new Error("Capsule integrity files must be an array.");
  }
  if (
    !Number.isSafeInteger(manifest.integrity.payloadFileCount) ||
    manifest.integrity.payloadFileCount !== manifest.integrity.files.length
  ) {
    throw new Error("Capsule payloadFileCount does not match the sealed file list.");
  }
  let totalSize = 0;
  let previousPath = "";
  const paths = new Set();
  for (const entry of manifest.integrity.files) {
    requireRecord(entry, "manifest file entry");
    normalizeCapsulePath(entry.path, "manifest file path");
    if (entry.path === CAPSULE_MANIFEST_NAME) {
      throw new Error("Capsule manifest cannot recursively seal itself.");
    }
    if (paths.has(entry.path) || (previousPath && compareText(previousPath, entry.path) >= 0)) {
      throw new Error("Capsule file entries must be unique and sorted by path.");
    }
    paths.add(entry.path);
    previousPath = entry.path;
    if (!Number.isSafeInteger(entry.size) || entry.size < 0) {
      throw new Error(`Capsule file ${entry.path} has an invalid size.`);
    }
    requireSha256(entry.sha256, `Capsule file ${entry.path} sha256`);
    if (entry.type === "file") {
      requireExactKeys(
        entry,
        ["path", "type", "size", "sha256", "executable"],
        `Capsule file ${entry.path}`,
      );
      if (typeof entry.executable !== "boolean" || "target" in entry) {
        throw new Error(`Capsule file ${entry.path} has invalid file metadata.`);
      }
      if (entry.executable !== (entry.path === target.executable)) {
        throw new Error(`Capsule file ${entry.path} violates the executable-mode allowlist.`);
      }
    } else if (entry.type === "symlink") {
      requireExactKeys(
        entry,
        ["path", "type", "target", "size", "sha256"],
        `Capsule symlink ${entry.path}`,
      );
      if (typeof entry.target !== "string" || "executable" in entry) {
        throw new Error(`Capsule symlink ${entry.path} has invalid symlink metadata.`);
      }
      if (
        entry.size !== Buffer.byteLength(entry.target) ||
        entry.sha256 !== sha256Text(entry.target)
      ) {
        throw new Error(`Capsule symlink ${entry.path} target metadata was tampered.`);
      }
    } else {
      throw new Error(`Capsule file ${entry.path} has an unsupported type.`);
    }
    totalSize += entry.size;
  }
  if (manifest.integrity.payloadSize !== totalSize) {
    throw new Error("Capsule payloadSize does not match the sealed file list.");
  }
  const nativePaths = new Set(manifest.nativeCode.objects.map((entry) => entry.path));
  for (const entry of manifest.integrity.files) {
    if (entry.type === "file" && entry.path.endsWith(".node") && !nativePaths.has(entry.path)) {
      throw new Error(`Capsule native addon ${entry.path} is absent from nativeCode inventory.`);
    }
  }
  for (const nativeObject of manifest.nativeCode.objects) {
    const entry = manifest.integrity.files.find(
      (candidate) => candidate.path === nativeObject.path,
    );
    if (!entry || entry.type !== "file") {
      throw new Error(`Capsule native-code object ${nativeObject.path} is absent from integrity.`);
    }
  }
  return target;
}

function validateNativeCodeDocument(nativeCode, target) {
  requireRecord(nativeCode, "manifest.nativeCode");
  requireExactKeys(nativeCode, ["format", "objects", "signingOrder"], "manifest.nativeCode");
  const expectedInventoryFormat = target.platform === "darwin" ? "mach-o" : "platform-native";
  requireExactString(nativeCode.format, expectedInventoryFormat, "nativeCode format");
  if (!Array.isArray(nativeCode.objects) || !Array.isArray(nativeCode.signingOrder)) {
    throw new Error("Capsule native-code inventory must contain arrays.");
  }
  let previousPath = "";
  const objects = [];
  for (const entry of nativeCode.objects) {
    requireRecord(entry, "native-code object");
    requireExactKeys(entry, ["path", "kind", "format", "architectures"], "native-code object");
    const path = normalizeCapsulePath(entry.path, "native-code path");
    if (previousPath && compareText(previousPath, path) >= 0) {
      throw new Error("Capsule native-code inventory must be uniquely path-sorted.");
    }
    previousPath = path;
    if (
      !["runtime-executable", "native-addon", "dynamic-library", "executable"].includes(
        entry.kind,
      ) ||
      !["elf", "mach-o", "pe-coff", "unknown"].includes(entry.format) ||
      !Array.isArray(entry.architectures) ||
      entry.architectures.some(
        (architecture, index) =>
          !["arm64", "x64"].includes(architecture) ||
          entry.architectures.indexOf(architecture) !== index,
      )
    ) {
      throw new Error(`Capsule native-code metadata is invalid at ${path}.`);
    }
    if (entry.format === "unknown" && entry.architectures.length !== 0) {
      throw new Error(`Unknown native object ${path} declares an architecture.`);
    }
    if (entry.format !== "unknown" && entry.architectures.length === 0) {
      throw new Error(`Native object ${path} has no architecture inventory.`);
    }
    if ((entry.kind === "native-addon") !== path.endsWith(".node")) {
      throw new Error(`Capsule native-addon classification is invalid at ${path}.`);
    }
    if ((entry.kind === "runtime-executable") !== (path === target.executable)) {
      throw new Error(`Capsule runtime executable classification is invalid at ${path}.`);
    }
    objects.push({
      path,
      kind: entry.kind,
      format: entry.format,
      architectures: [...entry.architectures],
    });
  }
  const expectedFormat = expectedBinaryFormat(target.platform);
  const runtimeObject = objects.find((entry) => entry.kind === "runtime-executable");
  if (
    !runtimeObject ||
    runtimeObject.format !== expectedFormat ||
    stableStringify(runtimeObject.architectures) !== stableStringify(target.architectures)
  ) {
    throw new Error("Capsule runtime executable architecture inventory is incomplete.");
  }
  for (const nativeObject of objects) {
    if (
      nativeObject.format !== expectedFormat ||
      nativeObject.architectures.length === 0 ||
      nativeObject.architectures.some(
        (architecture) => !target.architectures.includes(architecture),
      )
    ) {
      throw new Error(`Capsule native object ${nativeObject.path} does not match ${target.id}.`);
    }
  }
  const expectedOrder = expectedNativeSigningOrder(objects);
  if (stableStringify(nativeCode.signingOrder) !== stableStringify(expectedOrder)) {
    throw new Error("Capsule native-code signing order is not deterministic inside-out order.");
  }
  return objects;
}

export function runtimeArgumentsForArchitecture(manifest, architecture) {
  validateManifestDocument(manifest);
  const entry = manifest.runtime.architectureArguments.find(
    (candidate) => candidate.architecture === architecture,
  );
  if (!entry) {
    throw new Error(`Capsule has no runtime argument policy for ${architecture}.`);
  }
  return [...entry.arguments];
}

export async function verifyPayloadIntegrity(capsuleRoot, manifest) {
  validateManifestDocument(manifest);
  const actualEntries = await collectPayloadEntries(capsuleRoot);
  const expectedEntries = manifest.integrity.files;
  if (actualEntries.length !== expectedEntries.length) {
    throw new Error(
      `Capsule payload inventory changed: expected ${expectedEntries.length} entries, found ${actualEntries.length}.`,
    );
  }
  for (let index = 0; index < expectedEntries.length; index += 1) {
    const expected = expectedEntries[index];
    const actual = actualEntries[index];
    if (stableStringify(actual) !== stableStringify(expected)) {
      throw new Error(`Capsule payload integrity mismatch at ${expected?.path ?? actual?.path}.`);
    }
  }
}

export async function assertReadOnlyTree(root) {
  if (process.platform === "win32") {
    return;
  }
  await visitTree(root, async (path, metadata) => {
    if (!metadata.isSymbolicLink() && (metadata.mode & 0o222) !== 0) {
      throw new Error(`Capsule verification requires a read-only tree; writable path: ${path}.`);
    }
  });
}

export async function makeTreeReadOnly(root) {
  if (process.platform === "win32") {
    return;
  }
  await chmodReadOnly(root);
}

async function chmodReadOnly(path) {
  const metadata = await lstat(path);
  if (metadata.isSymbolicLink()) {
    return;
  }
  if (metadata.isDirectory()) {
    const entries = await readdir(path);
    entries.sort();
    for (const entry of entries) {
      await chmodReadOnly(resolve(path, entry));
    }
  }
  await chmod(path, metadata.mode & ~0o222);
}

export async function removeTreeEvenIfReadOnly(path) {
  try {
    await lstat(path);
  } catch (error) {
    if (error && error.code === "ENOENT") {
      return;
    }
    throw error;
  }
  await makeTreeOwnerWritable(path);
  await rm(path, { recursive: true, force: true });
}

export async function makeTreeOwnerWritable(path) {
  const metadata = await lstat(path);
  if (metadata.isSymbolicLink()) {
    return;
  }
  await chmod(path, metadata.mode | 0o200 | (metadata.isDirectory() ? 0o100 : 0));
  if (metadata.isDirectory()) {
    const entries = await readdir(path);
    for (const entry of entries) {
      await makeTreeOwnerWritable(resolve(path, entry));
    }
  }
}

export async function copyRealPackage(source, destination) {
  await removeTreeEvenIfReadOnly(destination);
  await mkdir(destination, { recursive: true });
  const sourceMetadata = await lstat(source);
  if (!sourceMetadata.isDirectory() || sourceMetadata.isSymbolicLink()) {
    throw new Error(`Local package source is not a real directory: ${source}`);
  }
  await copyTreeWithoutSymlinks(source, destination);
}

async function copyTreeWithoutSymlinks(source, destination) {
  const entries = await readdir(source, { withFileTypes: true });
  entries.sort((left, right) => compareText(left.name, right.name));
  for (const entry of entries) {
    const from = resolve(source, entry.name);
    const to = resolve(destination, entry.name);
    const metadata = await lstat(from);
    if (metadata.isSymbolicLink()) {
      throw new Error(`Local package staging rejects symlink ${from}.`);
    }
    if (metadata.isDirectory()) {
      await mkdir(to, { recursive: true });
      await copyTreeWithoutSymlinks(from, to);
    } else if (metadata.isFile()) {
      await cp(from, to, { preserveTimestamps: false });
      await chmod(to, metadata.mode & 0o777);
    } else {
      throw new Error(`Local package staging rejects unsupported entry ${from}.`);
    }
  }
}

export async function assertTreeContainsNoSymlinks(root) {
  await visitTree(root, async (path, metadata) => {
    if (metadata.isSymbolicLink()) {
      throw new Error(`The staged local protocol package must contain real files: ${path}.`);
    }
  });
}

export async function scanForbiddenArtifacts(root, options = {}) {
  const tokens = (options.tokens ?? ["pi-web"]).map((token) => Buffer.from(token.toLowerCase()));
  const absoluteBuildPaths = (options.absoluteBuildPaths ?? [])
    .filter(Boolean)
    .map((path) => Buffer.from(resolve(path)));
  await visitTree(root, async (path, metadata) => {
    const relativePath = relative(root, path).split(sep).join("/");
    const lowerPath = relativePath.toLowerCase();
    for (const token of tokens) {
      if (lowerPath.includes(token.toString())) {
        throw new Error(`Capsule contains forbidden artifact path ${relativePath}.`);
      }
    }
    if (!metadata.isFile()) {
      return;
    }
    for (const token of tokens) {
      if (await fileContains(path, token, true)) {
        throw new Error(`Capsule contains forbidden artifact content in ${relativePath}.`);
      }
    }
    for (const absolutePath of absoluteBuildPaths) {
      if (await fileContains(path, absolutePath, false)) {
        throw new Error(`Capsule leaked an absolute build path in ${relativePath}.`);
      }
    }
  });
}

async function fileContains(path, needle, caseInsensitive) {
  if (needle.length === 0) {
    return false;
  }
  let remainder = Buffer.alloc(0);
  for await (const rawChunk of createReadStream(path)) {
    let chunk = Buffer.concat([remainder, rawChunk]);
    if (caseInsensitive) {
      chunk = Buffer.from(chunk.toString("latin1").toLowerCase(), "latin1");
    }
    if (chunk.indexOf(needle) !== -1) {
      return true;
    }
    remainder = chunk.subarray(Math.max(0, chunk.length - needle.length + 1));
  }
  return false;
}

export async function collectInstalledPackages(nodeModulesRoot) {
  const packages = [];
  await collectNodeModules(nodeModulesRoot, packages, new Set());
  return packages.sort((left, right) => compareText(left.path, right.path));
}

async function collectNodeModules(nodeModulesRoot, output, visitedRealPaths) {
  let entries;
  try {
    entries = await readdir(nodeModulesRoot, { withFileTypes: true });
  } catch (error) {
    if (error && error.code === "ENOENT") {
      return;
    }
    throw error;
  }
  entries.sort((left, right) => compareText(left.name, right.name));
  for (const entry of entries) {
    if (entry.name.startsWith(".")) {
      continue;
    }
    if (entry.name.startsWith("@")) {
      const scopePath = resolve(nodeModulesRoot, entry.name);
      const scoped = await readdir(scopePath, { withFileTypes: true });
      scoped.sort((left, right) => compareText(left.name, right.name));
      for (const packageEntry of scoped) {
        await collectPackage(resolve(scopePath, packageEntry.name), output, visitedRealPaths);
      }
    } else {
      await collectPackage(resolve(nodeModulesRoot, entry.name), output, visitedRealPaths);
    }
  }
}

async function collectPackage(packageRoot, output, visitedRealPaths) {
  const packageRealPath = await realpath(packageRoot);
  if (visitedRealPaths.has(packageRealPath)) {
    return;
  }
  visitedRealPaths.add(packageRealPath);
  const packageJsonPath = resolve(packageRoot, "package.json");
  let packageJson;
  try {
    packageJson = await readJson(packageJsonPath);
  } catch (error) {
    throw new Error(`Installed package is missing readable metadata at ${packageJsonPath}.`, {
      cause: error,
    });
  }
  if (typeof packageJson.name !== "string" || typeof packageJson.version !== "string") {
    throw new Error(`Installed package metadata is incomplete at ${packageJsonPath}.`);
  }
  output.push({
    path: packageRoot,
    name: packageJson.name,
    version: packageJson.version,
    license: normalizeDeclaredLicense(packageJson.license),
    requiredDependencies: Object.keys(packageJson.dependencies ?? {}).sort(),
    optionalDependencies: Object.keys(packageJson.optionalDependencies ?? {}).sort(),
    peerDependencies: Object.keys(packageJson.peerDependencies ?? {}).sort(),
  });
  await collectNodeModules(resolve(packageRoot, "node_modules"), output, visitedRealPaths);
}

export async function writePackageLicenseInventories(capsuleRoot) {
  const inventories = await createPackageLicenseInventories(capsuleRoot);
  await Promise.all([
    writeDeterministicJson(
      resolveCapsulePath(capsuleRoot, PACKAGE_INVENTORY_PATH),
      inventories.packages,
    ),
    writeDeterministicJson(
      resolveCapsulePath(capsuleRoot, LICENSE_INVENTORY_PATH),
      inventories.licenses,
    ),
  ]);
  return inventories;
}

export async function verifyPackageLicenseInventories(capsuleRoot) {
  const expected = await createPackageLicenseInventories(capsuleRoot);
  const [packages, licenses] = await Promise.all([
    readJson(resolveCapsulePath(capsuleRoot, PACKAGE_INVENTORY_PATH)),
    readJson(resolveCapsulePath(capsuleRoot, LICENSE_INVENTORY_PATH)),
  ]);
  if (stableStringify(packages) !== stableStringify(expected.packages)) {
    throw new Error("Capsule package inventory does not match installed production packages.");
  }
  if (stableStringify(licenses) !== stableStringify(expected.licenses)) {
    throw new Error("Capsule license inventory does not match installed package license evidence.");
  }
  return expected;
}

async function createPackageLicenseInventories(capsuleRoot) {
  const installed = await collectInstalledPackages(resolve(capsuleRoot, "app/node_modules"));
  const packages = [];
  const packageLicenses = [];
  for (const entry of installed) {
    const packagePath = relative(capsuleRoot, entry.path).split(sep).join("/");
    const licenseFiles = [];
    for (const name of (await readdir(entry.path)).sort(compareText)) {
      if (!/^(?:licen[cs]e|copying|notice)(?:[._-].*)?$/iu.test(name)) continue;
      const path = resolve(entry.path, name);
      const metadata = await lstat(path);
      if (!metadata.isFile() || metadata.isSymbolicLink()) continue;
      licenseFiles.push({
        path: `${packagePath}/${name}`,
        sha256: await sha256File(path),
        size: metadata.size,
      });
    }
    packages.push({
      name: entry.name,
      version: entry.version,
      path: packagePath,
      declaredLicense: entry.license,
    });
    packageLicenses.push({
      name: entry.name,
      version: entry.version,
      path: packagePath,
      declaredLicense: entry.license,
      files: licenseFiles,
    });
  }
  packages.sort((left, right) => compareText(left.path, right.path));
  packageLicenses.sort((left, right) => compareText(left.path, right.path));
  const runtimeLicenses = [];
  for (const path of [
    "runtime/LICENSE",
    "runtime/lib/node_modules/npm/LICENSE",
    "runtime/node_modules/npm/LICENSE",
  ]) {
    const absolute = resolve(capsuleRoot, ...path.split("/"));
    let metadata;
    try {
      metadata = await lstat(absolute);
    } catch (error) {
      if (error?.code === "ENOENT") continue;
      throw error;
    }
    if (metadata.isFile() && !metadata.isSymbolicLink()) {
      runtimeLicenses.push({ path, sha256: await sha256File(absolute), size: metadata.size });
    }
  }
  return {
    packages: {
      schemaVersion: 1,
      packageCount: packages.length,
      packages,
    },
    licenses: {
      schemaVersion: 1,
      packageCount: packageLicenses.length,
      packages: packageLicenses,
      runtimes: runtimeLicenses,
    },
  };
}

function normalizeDeclaredLicense(value) {
  if (typeof value === "string" && value.trim()) return value.trim();
  if (value && typeof value === "object" && typeof value.type === "string" && value.type.trim()) {
    return value.type.trim();
  }
  return null;
}

export async function verifyProductionDependencyTree(appRoot) {
  const packageJson = await readJson(resolve(appRoot, "package.json"));
  if (packageJson.devDependencies && Object.keys(packageJson.devDependencies).length > 0) {
    throw new Error("Capsule application package metadata contains devDependencies.");
  }
  const rootDependencies = packageJson.dependencies ?? {};
  for (const [name, version] of Object.entries(rootDependencies)) {
    if (typeof version !== "string" || !/^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$/u.test(version)) {
      throw new Error(`Capsule runtime dependency ${name} is not pinned exactly: ${version}`);
    }
  }

  const packages = await collectInstalledPackages(resolve(appRoot, "node_modules"));
  const byName = new Map();
  for (const packageEntry of packages) {
    const entries = byName.get(packageEntry.name) ?? [];
    entries.push(packageEntry);
    byName.set(packageEntry.name, entries);
  }
  const reachable = new Set();
  const queue = Object.keys(rootDependencies).sort();
  while (queue.length > 0) {
    const name = queue.shift();
    if (reachable.has(name)) {
      continue;
    }
    reachable.add(name);
    const installed = byName.get(name);
    if (!installed || installed.length === 0) {
      throw new Error(`Capsule production dependency ${name} is missing.`);
    }
    for (const packageEntry of installed) {
      for (const dependency of packageEntry.requiredDependencies) {
        if (!byName.has(dependency)) {
          throw new Error(
            `Capsule package ${packageEntry.name}@${packageEntry.version} is missing dependency ${dependency}.`,
          );
        }
        if (!reachable.has(dependency)) {
          queue.push(dependency);
        }
      }
      for (const dependency of [
        ...packageEntry.optionalDependencies,
        ...packageEntry.peerDependencies,
      ]) {
        if (byName.has(dependency) && !reachable.has(dependency)) {
          queue.push(dependency);
        }
      }
    }
    queue.sort();
  }
  for (const packageEntry of packages) {
    if (!reachable.has(packageEntry.name)) {
      throw new Error(
        `Capsule contains development or extraneous package ${packageEntry.name}@${packageEntry.version}.`,
      );
    }
  }
  for (const [name, expectedVersion] of Object.entries(rootDependencies)) {
    if (!byName.get(name)?.some((entry) => entry.version === expectedVersion)) {
      throw new Error(
        `Capsule dependency ${name} does not contain the pinned version ${expectedVersion}.`,
      );
    }
  }
  return packages;
}

export async function verifyLockCopies(capsuleRoot, manifest) {
  for (const lock of manifest.locks) {
    const path = resolveCapsulePath(capsuleRoot, lock.capsulePath, `lock ${lock.name}`);
    const digest = await sha256File(path);
    if (digest !== lock.sha256) {
      throw new Error(`Capsule lock ${lock.name} digest does not match its manifest.`);
    }
  }
}

export async function verifyPackageMetadata(capsuleRoot, manifest) {
  const appPackage = await readJson(
    resolveCapsulePath(capsuleRoot, manifest.application.packagePath, "application package"),
  );
  const protocolPackageRoot = resolveCapsulePath(
    capsuleRoot,
    manifest.application.protocolPackagePath,
    "protocol package",
  );
  const protocolPackage = await readJson(resolve(protocolPackageRoot, "package.json"));
  if (appPackage.name !== "@pi-client/node" || appPackage.version !== manifest.versions.piNode) {
    throw new Error("Capsule Pi Node package metadata does not match the manifest.");
  }
  if (
    protocolPackage.name !== "@pi-client/protocol" ||
    protocolPackage.version !== manifest.versions.protocol
  ) {
    throw new Error("Capsule protocol package metadata does not match the manifest.");
  }
  if (protocolPackage.devDependencies && Object.keys(protocolPackage.devDependencies).length > 0) {
    throw new Error("Capsule protocol package contains devDependencies.");
  }
  requireExactString(
    appPackage.dependencies?.["@earendil-works/pi-coding-agent"],
    REQUIRED_PI_SDK_VERSION,
    "Pi SDK package dependency",
  );
  requireExactString(
    appPackage.dependencies?.["@pi-client/protocol"],
    manifest.versions.protocol,
    "protocol package dependency",
  );
  requireExactString(
    appPackage.dependencies?.["@bufbuild/protobuf"],
    REQUIRED_PROTOBUF_VERSION,
    "protobuf package dependency",
  );
  await assertTreeContainsNoSymlinks(protocolPackageRoot);
  return verifyProductionDependencyTree(resolve(capsuleRoot, "app"));
}

export async function verifyRuntimeMetadata(capsuleRoot, manifest) {
  const executable = resolveCapsulePath(capsuleRoot, manifest.runtime.executable, "runtime node");
  const entrypoint = resolveCapsulePath(
    capsuleRoot,
    manifest.application.entrypoint,
    "application entrypoint",
  );
  const runtimeBin = dirname(executable);
  const isolatedEnvironment = isolatedRuntimeEnvironment(runtimeBin);
  const runtimeArchitecture = manifest.target.architectures.includes(process.arch)
    ? process.arch
    : manifest.target.architectures[0];
  const runtimeArguments = runtimeArgumentsForArchitecture(manifest, runtimeArchitecture);
  const nodeVersion = await runCaptured(executable, [...runtimeArguments, "--version"], {
    cwd: capsuleRoot,
    env: isolatedEnvironment,
  });
  if (nodeVersion.stdout.trim() !== `v${NODE_RUNTIME_VERSION}`) {
    throw new Error(`Capsule embedded Node version is ${nodeVersion.stdout.trim()}.`);
  }
  const npmCli = resolveCapsulePath(capsuleRoot, manifest.runtime.npmCli, "runtime npm CLI");
  const npmVersion = await runCaptured(executable, [...runtimeArguments, npmCli, "--version"], {
    cwd: capsuleRoot,
    env: isolatedEnvironment,
  });
  if (npmVersion.stdout.trim() !== manifest.versions.npm) {
    throw new Error(`Capsule embedded npm version is ${npmVersion.stdout.trim()}.`);
  }

  const metadataScript = [
    `const api = await import(${JSON.stringify(pathToFileURL(resolve(capsuleRoot, "app/dist/index.js")).href)});`,
    "process.stdout.write(JSON.stringify(api.getRuntimeMetadata()));",
  ].join("\n");
  const metadataResult = await runCaptured(
    executable,
    [...runtimeArguments, "--input-type=module", "--eval", metadataScript],
    {
      cwd: capsuleRoot,
      env: isolatedEnvironment,
    },
  );
  const runtimeMetadata = JSON.parse(metadataResult.stdout);
  if (
    runtimeMetadata.piNodeVersion !== manifest.versions.piNode ||
    runtimeMetadata.piSdkVersion !== REQUIRED_PI_SDK_VERSION ||
    runtimeMetadata.nodeVersion !== NODE_RUNTIME_VERSION ||
    runtimeMetadata.platform !== manifest.target.platform ||
    !manifest.target.architectures.includes(runtimeMetadata.architecture)
  ) {
    throw new Error("Capsule runtime metadata does not match its sealed versions and target.");
  }
  const entrypointMetadata = await stat(entrypoint);
  if (!entrypointMetadata.isFile()) {
    throw new Error("Capsule application entrypoint is not a file.");
  }
  return {
    executable,
    runtimeBin,
    isolatedEnvironment,
    runtimeArchitecture,
    runtimeArguments,
  };
}

export function isolatedRuntimeEnvironment(runtimeBin, baseEnvironment = process.env) {
  const environment = {
    HOME: baseEnvironment.HOME ?? "",
    LANG: baseEnvironment.LANG ?? "C",
    LC_ALL: baseEnvironment.LC_ALL ?? "C",
    PATH: runtimeBin,
    PI_OFFLINE: "1",
    PI_SKIP_VERSION_CHECK: "1",
    PI_TELEMETRY: "0",
  };
  if (baseEnvironment.TMPDIR) {
    environment.TMPDIR = baseEnvironment.TMPDIR;
  }
  if (baseEnvironment.SystemRoot) {
    environment.SystemRoot = baseEnvironment.SystemRoot;
  }
  if (baseEnvironment.WINDIR) {
    environment.WINDIR = baseEnvironment.WINDIR;
  }
  if (baseEnvironment.COMSPEC) {
    environment.COMSPEC = baseEnvironment.COMSPEC;
  }
  if (baseEnvironment.PATHEXT) {
    environment.PATHEXT = baseEnvironment.PATHEXT;
  }
  return environment;
}

export async function runCaptured(executable, arguments_, options = {}) {
  const { spawn } = await import("node:child_process");
  return await new Promise((resolvePromise, rejectPromise) => {
    const child = spawn(executable, arguments_, {
      cwd: options.cwd,
      env: options.env,
      stdio: ["ignore", "pipe", "pipe"],
    });
    const stdout = [];
    const stderr = [];
    child.stdout.on("data", (chunk) => stdout.push(Buffer.from(chunk)));
    child.stderr.on("data", (chunk) => stderr.push(Buffer.from(chunk)));
    child.once("error", rejectPromise);
    child.once("exit", (code, signal) => {
      const result = {
        code,
        signal,
        stdout: Buffer.concat(stdout).toString("utf8"),
        stderr: Buffer.concat(stderr).toString("utf8"),
      };
      if (code !== 0) {
        rejectPromise(
          new Error(
            `Command ${executable} failed with code ${code} and signal ${signal}: ${result.stderr.trim()}`,
          ),
        );
      } else {
        resolvePromise(result);
      }
    });
  });
}

export function parseOfficialShasums(text, archiveName) {
  const matches = text
    .split(/\r?\n/u)
    .map((line) => /^([0-9a-f]{64})  (.+)$/u.exec(line))
    .filter((match) => match?.[2] === archiveName);
  if (matches.length !== 1) {
    throw new Error(`Official SHASUMS256.txt does not contain exactly one ${archiveName} entry.`);
  }
  return matches[0][1];
}

export async function copyFileWithParents(source, destination) {
  await mkdir(dirname(destination), { recursive: true });
  await cp(source, destination, { preserveTimestamps: false });
}

export async function visitTree(root, visitor) {
  const metadata = await lstat(root);
  await visitor(root, metadata);
  if (!metadata.isDirectory() || metadata.isSymbolicLink()) {
    return;
  }
  const entries = await readdir(root);
  entries.sort();
  for (const entry of entries) {
    await visitTree(resolve(root, entry), visitor);
  }
}

function compareText(left, right) {
  return left < right ? -1 : left > right ? 1 : 0;
}

function requireExactKeys(value, expectedKeys, field) {
  const actualKeys = Object.keys(value).sort();
  const expected = [...expectedKeys].sort();
  if (
    actualKeys.length !== expected.length ||
    actualKeys.some((key, index) => key !== expected[index])
  ) {
    throw new Error(`${field} contains missing or unexpected fields.`);
  }
}

function requireRecord(value, field) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error(`${field} must be an object.`);
  }
}

function requireExactString(actual, expected, field) {
  if (actual !== expected) {
    throw new Error(`${field} must be ${expected}; found ${actual}.`);
  }
}

function requireSha256(value, field) {
  if (typeof value !== "string" || !/^[0-9a-f]{64}$/u.test(value)) {
    throw new Error(`${field} must be a lowercase SHA-256 digest.`);
  }
}
