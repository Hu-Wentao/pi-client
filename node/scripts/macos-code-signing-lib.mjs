import { spawnSync } from "node:child_process";
import { lstat, mkdir, readFile, readdir, stat } from "node:fs/promises";
import { dirname, extname, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

import {
  CAPSULE_MANIFEST_NAME,
  makeTreeOwnerWritable,
  makeTreeReadOnly,
  readJson,
  resealCapsuleManifest,
  stableStringify,
  validateManifestDocument,
  writeDeterministicJson,
} from "./runtime-capsule-lib.mjs";
import {
  assertMacosAppBundle,
  resolveMacosAppCapsulePath,
  verifyInstalledRuntimeCapsule,
} from "./macos-app-runtime-capsule-lib.mjs";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const repositoryRoot = resolve(scriptDirectory, "../..");

export const MACOS_SIGNING_MANIFEST_RELATIVE_PATH =
  "Contents/Resources/pi-client-code-signing.json";
export const DEFAULT_APP_ENTITLEMENTS = resolve(
  repositoryRoot,
  "macos/Runner/Release.entitlements",
);
export const DEFAULT_NODE_ENTITLEMENTS = resolve(
  repositoryRoot,
  "macos/Runner/PiNode.entitlements",
);
export const DEFAULT_AD_HOC_NODE_ENTITLEMENTS = resolve(
  repositoryRoot,
  "macos/Runner/PiNodeAdHoc.entitlements",
);
export const FORBIDDEN_MACOS_ENTITLEMENT = "com.apple.security.cs.allow-unsigned-executable-memory";

const codeBundleExtensions = new Set([".app", ".appex", ".bundle", ".framework", ".xpc"]);

export async function signMacosAppInsideOut(options) {
  assertMacosHost();
  const appBundle = await assertMacosAppBundle(options.appBundle);
  const identity = options.identity ?? "-";
  const identityKind = identity === "-" ? "ad-hoc" : "developer-id";
  const capsuleRoot = resolveMacosAppCapsulePath(appBundle);
  await verifyInstalledRuntimeCapsule({
    appBundle,
    expectedSourceCommit: options.expectedSourceCommit,
  });
  const capsuleManifest = await readJson(resolve(capsuleRoot, CAPSULE_MANIFEST_NAME));
  const capsuleTarget = validateManifestDocument(capsuleManifest);
  await makeTreeOwnerWritable(capsuleRoot);

  const appInventory = await collectMacosAppCodeInventory(appBundle, capsuleManifest);
  const runtimePath = relative(
    appBundle,
    resolve(capsuleRoot, ...capsuleManifest.runtime.executable.split("/")),
  )
    .split(sep)
    .join("/");
  const nodeEntitlements =
    identityKind === "ad-hoc"
      ? (options.adHocNodeEntitlements ?? DEFAULT_AD_HOC_NODE_ENTITLEMENTS)
      : (options.nodeEntitlements ?? DEFAULT_NODE_ENTITLEMENTS);
  const appEntitlements = options.appEntitlements ?? DEFAULT_APP_ENTITLEMENTS;
  const expectedNodeEntitlements = await readEntitlementFileKeys(nodeEntitlements);
  const expectedAppEntitlements = await readEntitlementFileKeys(appEntitlements);
  assertMinimumEntitlements(identityKind, expectedNodeEntitlements, expectedAppEntitlements);

  const signedObjects = [];
  for (const path of appInventory.machOSigningOrder) {
    const absolutePath = resolve(appBundle, ...path.split("/"));
    const entitlements = path === runtimePath ? nodeEntitlements : undefined;
    codesignObject({
      path: absolutePath,
      identity,
      entitlements,
      timestamp: options.timestamp,
    });
    signedObjects.push({
      path,
      kind: appInventory.objects.find((entry) => entry.path === path)?.kind ?? "mach-o",
      entitlements: path === runtimePath ? expectedNodeEntitlements : [],
    });
  }

  const resealedCapsule = await resealCapsuleManifest(capsuleRoot);
  await makeTreeReadOnly(capsuleRoot);
  await verifyInstalledRuntimeCapsule({
    appBundle,
    expectedSourceCommit: options.expectedSourceCommit,
  });

  for (const path of appInventory.bundleSigningOrder) {
    codesignObject({
      path: resolve(appBundle, ...path.split("/")),
      identity,
      timestamp: options.timestamp,
    });
    signedObjects.push({ path, kind: "code-bundle", entitlements: [] });
  }

  const signingManifestPath = resolve(
    appBundle,
    ...MACOS_SIGNING_MANIFEST_RELATIVE_PATH.split("/"),
  );
  const signingManifest = {
    schemaVersion: 1,
    signingKind: identityKind,
    hardenedRuntime: true,
    timestamped: identityKind === "ad-hoc" ? false : options.timestamp !== "none",
    appArchitectures: appInventory.appArchitectures,
    capsuleTarget: capsuleTarget.id,
    capsuleArchitectures: [...capsuleTarget.architectures],
    capsuleManifestSha256: await sha256FilePortable(resolve(capsuleRoot, CAPSULE_MANIFEST_NAME)),
    objects: appInventory.objects,
    insideOutSigningOrder: signedObjects,
    app: {
      path: ".",
      entitlements: expectedAppEntitlements,
    },
    notarization: "external-gate",
  };
  await writeDeterministicJson(signingManifestPath, signingManifest);
  codesignObject({
    path: appBundle,
    identity,
    entitlements: appEntitlements,
    timestamp: options.timestamp,
  });

  return await verifyMacosAppCodeSigning({
    appBundle,
    expectedSourceCommit: options.expectedSourceCommit,
    expectedSigningKind: identityKind,
    gatekeeper: options.gatekeeper ?? (identityKind === "ad-hoc" ? "reject" : "skip"),
  });
}

export async function verifyMacosAppCodeSigning(options) {
  assertMacosHost();
  const appBundle = await assertMacosAppBundle(options.appBundle);
  const signingManifestPath = resolve(
    appBundle,
    ...MACOS_SIGNING_MANIFEST_RELATIVE_PATH.split("/"),
  );
  const signingManifest = await readJson(signingManifestPath);
  validateSigningManifest(signingManifest, options.expectedSigningKind);
  const installed = await verifyInstalledRuntimeCapsule({
    appBundle,
    expectedSourceCommit: options.expectedSourceCommit,
  });
  const capsuleManifest = await readJson(resolve(installed.capsulePath, CAPSULE_MANIFEST_NAME));
  const actualManifestSha256 = await sha256FilePortable(
    resolve(installed.capsulePath, CAPSULE_MANIFEST_NAME),
  );
  if (actualManifestSha256 !== signingManifest.capsuleManifestSha256) {
    throw new Error("The signed app manifest does not seal the installed Capsule manifest.");
  }

  const inventory = await collectMacosAppCodeInventory(appBundle, capsuleManifest);
  if (stableStringify(inventory.objects) !== stableStringify(signingManifest.objects)) {
    throw new Error("The signed app Mach-O/code-bundle inventory changed.");
  }
  if (
    stableStringify(inventory.appArchitectures) !==
      stableStringify(signingManifest.appArchitectures) ||
    stableStringify(capsuleManifest.target.architectures) !==
      stableStringify(signingManifest.capsuleArchitectures)
  ) {
    throw new Error("The signed app architecture claim does not match its code inventory.");
  }
  const expectedOrder = [...inventory.machOSigningOrder, ...inventory.bundleSigningOrder];
  if (
    stableStringify(signingManifest.insideOutSigningOrder.map((entry) => entry.path)) !==
    stableStringify(expectedOrder)
  ) {
    throw new Error("The app signing order is not the deterministic inside-out order.");
  }

  for (const signedObject of signingManifest.insideOutSigningOrder) {
    const path = resolve(appBundle, ...signedObject.path.split("/"));
    verifyCodeSignature(path);
    assertHardenedRuntime(path);
    const entitlements = readCodeEntitlementKeys(path);
    if (stableStringify(entitlements) !== stableStringify(signedObject.entitlements)) {
      throw new Error(`Signed entitlements changed at ${signedObject.path}.`);
    }
  }
  verifyCodeSignature(appBundle);
  assertHardenedRuntime(appBundle);
  const appEntitlements = readCodeEntitlementKeys(appBundle);
  if (stableStringify(appEntitlements) !== stableStringify(signingManifest.app.entitlements)) {
    throw new Error("Signed app entitlements do not match the signing manifest.");
  }
  const everyEntitlement = new Set([
    ...appEntitlements,
    ...signingManifest.insideOutSigningOrder.flatMap((entry) => entry.entitlements),
  ]);
  if (everyEntitlement.has(FORBIDDEN_MACOS_ENTITLEMENT)) {
    throw new Error(`${FORBIDDEN_MACOS_ENTITLEMENT} is forbidden.`);
  }
  const disableLibraryValidationUsers = signingManifest.insideOutSigningOrder.filter((entry) =>
    entry.entitlements.includes("com.apple.security.cs.disable-library-validation"),
  );
  if (
    disableLibraryValidationUsers.length > 1 ||
    (disableLibraryValidationUsers.length === 1 &&
      !disableLibraryValidationUsers[0].path.endsWith("/runtime/bin/node")) ||
    (signingManifest.signingKind === "developer-id" && disableLibraryValidationUsers.length !== 0)
  ) {
    throw new Error("Library validation is disabled outside the ad-hoc Node helper boundary.");
  }
  if (
    signingManifest.signingKind === "ad-hoc" &&
    (disableLibraryValidationUsers.length !== 1 ||
      !disableLibraryValidationUsers[0].entitlements.includes("com.apple.security.cs.allow-jit"))
  ) {
    throw new Error(
      "Ad-hoc Node requires only allow-jit plus the proven library-validation exception.",
    );
  }

  const gatekeeper = assessGatekeeper(appBundle);
  if (options.gatekeeper === "reject" && gatekeeper.accepted) {
    throw new Error("Gatekeeper unexpectedly accepted the ad-hoc/unnotarized app.");
  }
  if (options.gatekeeper === "accept" && !gatekeeper.accepted) {
    throw new Error(`Gatekeeper rejected the expected accepted app: ${gatekeeper.output}`);
  }
  return {
    appBundle,
    signingKind: signingManifest.signingKind,
    hardenedRuntime: true,
    appArchitectures: signingManifest.appArchitectures,
    capsuleArchitectures: signingManifest.capsuleArchitectures,
    signedObjectCount: signingManifest.insideOutSigningOrder.length + 1,
    insideOutSigningOrder: signingManifest.insideOutSigningOrder,
    appEntitlements,
    gatekeeper,
    codesignStrict: true,
    codesignDeepUsed: false,
    notarization: signingManifest.notarization,
    installedCapsule: installed,
  };
}

export async function collectMacosAppCodeInventory(appBundle, capsuleManifest) {
  const app = resolve(appBundle);
  const appInfo = resolve(app, "Contents/Info.plist");
  const appExecutableName = readPlistValue(appInfo, "CFBundleExecutable");
  const appExecutableRelative = `Contents/MacOS/${appExecutableName}`;
  const appExecutable = resolve(app, ...appExecutableRelative.split("/"));
  const appArchitectures = readMachOArchitectures(appExecutable);
  const capsuleRoot = resolveMacosAppCapsulePath(app);
  const capsulePrefix = `${relative(app, capsuleRoot).split(sep).join("/")}/`;
  const capsuleObjects = new Map(
    capsuleManifest.nativeCode.objects
      .filter((entry) => entry.format === "mach-o")
      .map((entry) => [`${capsulePrefix}${entry.path}`, entry]),
  );

  const objects = [];
  const bundles = [];
  await visitAppTree(app, async (path, metadata) => {
    const relativePath = relative(app, path).split(sep).join("/");
    if (metadata.isDirectory() && path !== app && codeBundleExtensions.has(extname(path))) {
      let architectures;
      try {
        architectures = readBundleArchitectures(path);
      } catch {
        return;
      }
      bundles.push(relativePath);
      objects.push({ path: relativePath, kind: "code-bundle", architectures });
      return;
    }
    if (!metadata.isFile() || relativePath === appExecutableRelative) return;
    if (!fileDescription(path).includes("Mach-O")) return;
    const capsuleObject = capsuleObjects.get(relativePath);
    objects.push({
      path: relativePath,
      kind: capsuleObject ? `capsule-${capsuleObject.kind}` : "mach-o",
      architectures: readMachOArchitectures(path),
    });
  });
  objects.sort((left, right) => compareText(left.path, right.path));

  const capsuleSigningOrder = capsuleManifest.nativeCode.signingOrder.map(
    (path) => `${capsulePrefix}${path}`,
  );
  const machOPaths = objects
    .filter((entry) => entry.kind !== "code-bundle")
    .map((entry) => entry.path);
  for (const path of capsuleSigningOrder) {
    if (!machOPaths.includes(path)) {
      throw new Error(`Capsule signing object is absent from the app inventory: ${path}.`);
    }
  }
  const otherMachO = machOPaths
    .filter((path) => !capsuleSigningOrder.includes(path))
    .sort(compareInsideOutPath);
  const bundleSigningOrder = bundles.sort(compareInsideOutPath);

  for (const entry of objects) {
    if (!entry.path.startsWith(capsulePrefix)) {
      for (const architecture of appArchitectures) {
        if (!entry.architectures.includes(architecture)) {
          throw new Error(
            `App code object ${entry.path} does not support claimed ${architecture}.`,
          );
        }
      }
    }
  }
  const runtimeObject = capsuleManifest.nativeCode.objects.find(
    (entry) => entry.kind === "runtime-executable",
  );
  if (
    !runtimeObject ||
    stableStringify(runtimeObject.architectures) !==
      stableStringify(capsuleManifest.target.architectures)
  ) {
    throw new Error("Capsule runtime executable does not cover the Capsule architecture claim.");
  }
  for (const architecture of capsuleManifest.target.architectures) {
    if (!appArchitectures.includes(architecture)) {
      throw new Error(`App executable does not cover Capsule architecture ${architecture}.`);
    }
  }

  return {
    appArchitectures,
    objects,
    machOSigningOrder: [...capsuleSigningOrder, ...otherMachO],
    bundleSigningOrder,
  };
}

function codesignObject(options) {
  const arguments_ = ["--force", "--sign", options.identity, "--options", "runtime"];
  if (options.identity === "-" || options.timestamp === "none") {
    arguments_.push("--timestamp=none");
  } else {
    arguments_.push("--timestamp");
  }
  if (options.entitlements) arguments_.push("--entitlements", options.entitlements);
  arguments_.push(options.path);
  run("/usr/bin/codesign", arguments_);
}

function verifyCodeSignature(path) {
  run("/usr/bin/codesign", ["--verify", "--strict", "--verbose=4", path]);
}

function assertHardenedRuntime(path) {
  const result = run("/usr/bin/codesign", ["-d", "--verbose=4", path]);
  const output = `${result.stdout}\n${result.stderr}`;
  if (!/flags=.*\bruntime\b/u.test(output)) {
    throw new Error(`Hardened Runtime flag is absent from ${path}.`);
  }
}

function readCodeEntitlementKeys(path) {
  const result = spawnSync("/usr/bin/codesign", ["-d", "--entitlements", ":-", path], {
    encoding: "utf8",
  });
  if (result.error) throw result.error;
  const output = `${result.stdout ?? ""}\n${result.stderr ?? ""}`;
  if (result.status !== 0 && !/does not have an entitlements blob/iu.test(output)) {
    throw new Error(`Could not read code entitlements for ${path}: ${output.trim()}`);
  }
  const plistStart = output.indexOf("<?xml");
  if (plistStart === -1) return [];
  return plistKeys(output.slice(plistStart));
}

async function readEntitlementFileKeys(path) {
  return plistKeys(await readFile(path, "utf8"));
}

function plistKeys(xml) {
  return [...xml.matchAll(/<key>([^<]+)<\/key>/gu)].map((match) => match[1]).sort(compareText);
}

function assertMinimumEntitlements(identityKind, nodeEntitlements, appEntitlements) {
  if (appEntitlements.length !== 0) {
    throw new Error("The unsandboxed desktop app requires no Release entitlements.");
  }
  const expectedNode =
    identityKind === "ad-hoc"
      ? ["com.apple.security.cs.allow-jit", "com.apple.security.cs.disable-library-validation"]
      : ["com.apple.security.cs.allow-jit"];
  if (stableStringify(nodeEntitlements) !== stableStringify(expectedNode.sort(compareText))) {
    throw new Error("Pi Node entitlements exceed the minimum signing policy.");
  }
  if (nodeEntitlements.includes(FORBIDDEN_MACOS_ENTITLEMENT)) {
    throw new Error(`${FORBIDDEN_MACOS_ENTITLEMENT} is forbidden.`);
  }
}

function validateSigningManifest(manifest, expectedSigningKind) {
  if (
    !manifest ||
    typeof manifest !== "object" ||
    Array.isArray(manifest) ||
    manifest.schemaVersion !== 1 ||
    !["ad-hoc", "developer-id"].includes(manifest.signingKind) ||
    manifest.hardenedRuntime !== true ||
    manifest.notarization !== "external-gate" ||
    !Array.isArray(manifest.objects) ||
    !Array.isArray(manifest.insideOutSigningOrder) ||
    !Array.isArray(manifest.appArchitectures) ||
    !Array.isArray(manifest.capsuleArchitectures)
  ) {
    throw new Error("The app code-signing manifest is invalid.");
  }
  if (expectedSigningKind && manifest.signingKind !== expectedSigningKind) {
    throw new Error(`Expected ${expectedSigningKind} signing; found ${manifest.signingKind}.`);
  }
}

function readBundleArchitectures(bundlePath) {
  const infoCandidates = [
    resolve(bundlePath, "Contents/Info.plist"),
    resolve(bundlePath, "Resources/Info.plist"),
    resolve(bundlePath, "Versions/Current/Resources/Info.plist"),
  ];
  for (const infoPath of infoCandidates) {
    try {
      const executable = readPlistValue(infoPath, "CFBundleExecutable");
      const executableCandidates = [
        resolve(bundlePath, "Contents/MacOS", executable),
        resolve(bundlePath, executable),
        resolve(bundlePath, "Versions/Current", executable),
      ];
      for (const executablePath of executableCandidates) {
        try {
          if (fileDescription(executablePath).includes("Mach-O")) {
            return readMachOArchitectures(executablePath);
          }
        } catch {
          // Try the next conventional bundle executable location.
        }
      }
    } catch {
      // Try the next Info.plist location.
    }
  }
  throw new Error(`Could not resolve the Mach-O executable for code bundle ${bundlePath}.`);
}

function readPlistValue(path, key) {
  const result = run("/usr/bin/plutil", ["-extract", key, "raw", "-o", "-", path]);
  return result.stdout.trim();
}

function readMachOArchitectures(path) {
  const result = run("/usr/bin/lipo", ["-archs", path]);
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

function fileDescription(path) {
  return run("/usr/bin/file", ["-b", path]).stdout.trim();
}

async function visitAppTree(root, visitor) {
  const metadata = await lstat(root);
  await visitor(root, metadata);
  if (!metadata.isDirectory() || metadata.isSymbolicLink()) return;
  for (const entry of (await readdir(root)).sort(compareText)) {
    await visitAppTree(resolve(root, entry), visitor);
  }
}

function compareInsideOutPath(left, right) {
  const depth = right.split("/").length - left.split("/").length;
  return depth || compareText(left, right);
}

function assessGatekeeper(appBundle) {
  const result = spawnSync("/usr/sbin/spctl", ["--assess", "--type", "execute", "-vv", appBundle], {
    encoding: "utf8",
  });
  if (result.error) throw result.error;
  return {
    accepted: result.status === 0,
    status: result.status,
    output: `${result.stdout ?? ""}\n${result.stderr ?? ""}`.trim(),
  };
}

async function sha256FilePortable(path) {
  const { sha256File } = await import("./runtime-capsule-lib.mjs");
  return await sha256File(path);
}

function assertMacosHost() {
  if (process.platform !== "darwin") {
    throw new Error("macOS code signing requires a macOS host.");
  }
}

function run(executable, arguments_) {
  const result = spawnSync(executable, arguments_, {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(
      `Command failed (${result.status}): ${executable} ${arguments_.join(" ")}\n${result.stderr ?? ""}`,
    );
  }
  return { stdout: result.stdout ?? "", stderr: result.stderr ?? "" };
}

function compareText(left, right) {
  return left < right ? -1 : left > right ? 1 : 0;
}
