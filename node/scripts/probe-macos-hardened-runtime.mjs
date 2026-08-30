#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { cp, mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

import {
  DEFAULT_AD_HOC_NODE_ENTITLEMENTS,
  DEFAULT_NODE_ENTITLEMENTS,
  NODE_EXECUTABLE_MEMORY_ENTITLEMENT,
} from "./macos-code-signing-lib.mjs";
import {
  CAPSULE_MANIFEST_NAME,
  readJson,
  resolveCapsulePath,
  runtimeArgumentsForArchitecture,
  validateManifestDocument,
} from "./runtime-capsule-lib.mjs";

if (process.platform !== "darwin") throw new Error("The Hardened Runtime probe requires macOS.");
const capsuleRoot = resolve(parseCapsule(process.argv.slice(2)));
const manifest = await readJson(resolve(capsuleRoot, CAPSULE_MANIFEST_NAME));
const target = validateManifestDocument(manifest);
for (const path of [DEFAULT_NODE_ENTITLEMENTS, DEFAULT_AD_HOC_NODE_ENTITLEMENTS]) {
  const text = await readFile(path, "utf8");
  if (!text.includes(NODE_EXECUTABLE_MEMORY_ENTITLEMENT)) {
    throw new Error(`${path} is missing the executable-memory exception under probe.`);
  }
}

const evidence = [];
for (const architecture of target.architectures) {
  const architectureArguments = runtimeArgumentsForArchitecture(manifest, architecture);
  const addon = manifest.nativeCode.objects.find(
    (entry) =>
      entry.kind === "native-addon" &&
      entry.format === "mach-o" &&
      entry.path.includes("@earendil-works/pi-tui/native/darwin/prebuilds/") &&
      entry.architectures.length === 1 &&
      entry.architectures[0] === architecture,
  );
  if (!addon) throw new Error(`No ${architecture} Pi TUI addon exists for the signing probe.`);
  const root = await mkdtemp(resolve(tmpdir(), `pi-node-signing-probe-${architecture}-`));
  const node = resolve(root, "node");
  const nativeAddon = resolve(root, "darwin-modifiers.node");
  const extension = resolve(root, "native-addon-extension.js");
  const jitOnlyEntitlements = resolve(root, "jit-only.entitlements");
  try {
    await Promise.all([
      cp(resolveCapsulePath(capsuleRoot, manifest.runtime.executable), node),
      cp(resolveCapsulePath(capsuleRoot, addon.path), nativeAddon),
      mkdir(resolve(root, "home"), { recursive: true }),
    ]);
    run("/bin/chmod", ["755", node]);
    run("/bin/chmod", ["644", nativeAddon]);
    await writeFile(
      jitOnlyEntitlements,
      '<?xml version="1.0" encoding="UTF-8"?>\n<plist version="1.0"><dict><key>com.apple.security.cs.allow-jit</key><true/></dict></plist>\n',
      "utf8",
    );
    sign(nativeAddon);

    const directScript = [
      "const addon = require(process.argv[1]);",
      'if (typeof addon.isModifierPressed !== "function") throw new Error("native addon API missing");',
      'process.stdout.write("loaded");',
    ].join("\n");
    sign(node, jitOnlyEntitlements);
    const jitOnly = runArchitecture(
      architecture,
      node,
      [...architectureArguments, "--eval", directScript, nativeAddon],
      { allowFailure: true, cwd: root },
    );
    if (jitOnly.status === 0) {
      throw new Error(`${architecture} unexpectedly loaded the addon with only allow-jit.`);
    }
    const jitOnlyOutput = `${jitOnly.stdout}\n${jitOnly.stderr}`;
    const executableMemoryRequired = architecture === "x64";
    if (
      executableMemoryRequired
        ? !/SetPermissions|executable memory|Fatal error/iu.test(jitOnlyOutput)
        : !/different Team IDs|library validation|code signature/iu.test(jitOnlyOutput)
    ) {
      throw new Error(
        `${architecture} allow-jit-only probe failed for an unexpected reason: ${jitOnlyOutput.trim()}`,
      );
    }

    sign(node, DEFAULT_NODE_ENTITLEMENTS);
    const libraryValidation = runArchitecture(
      architecture,
      node,
      [...architectureArguments, "--eval", directScript, nativeAddon],
      { allowFailure: true, cwd: root },
    );
    const libraryValidationOutput = `${libraryValidation.stdout}\n${libraryValidation.stderr}`;
    if (
      libraryValidation.status === 0 ||
      !/different Team IDs|library validation|code signature/iu.test(libraryValidationOutput)
    ) {
      throw new Error(
        `${architecture} did not prove the ad-hoc native-addon library-validation boundary: ${libraryValidationOutput.trim()}`,
      );
    }

    sign(node, DEFAULT_AD_HOC_NODE_ENTITLEMENTS);
    await writeFile(
      extension,
      [
        'import { createRequire } from "node:module";',
        "const require = createRequire(import.meta.url);",
        `const addon = require(${JSON.stringify(nativeAddon)});`,
        'if (typeof addon.isModifierPressed !== "function") throw new Error("native addon API missing");',
        "export default function capsuleProbeExtension() {}",
      ].join("\n"),
      "utf8",
    );
    const sdkUrl = pathToFileURL(
      resolve(capsuleRoot, "app/node_modules/@earendil-works/pi-coding-agent/dist/index.js"),
    ).href;
    const extensionScript = [
      `const sdk = await import(${JSON.stringify(sdkUrl)});`,
      `const loader = new sdk.DefaultResourceLoader({cwd: ${JSON.stringify(root)}, agentDir: ${JSON.stringify(root)}, additionalExtensionPaths: [${JSON.stringify(extension)}], noSkills: true, noPromptTemplates: true, noThemes: true, noContextFiles: true});`,
      "await loader.reload({resolveProjectTrust: async () => true});",
      "const loaded = loader.getExtensions();",
      "if (loaded.errors.length !== 0 || loaded.extensions.length !== 1) throw new Error(JSON.stringify(loaded.errors));",
      "process.stdout.write(JSON.stringify({architecture: process.arch, nativeAddon: true, extension: true}));",
    ].join("\n");
    const accepted = runArchitecture(
      architecture,
      node,
      [...architectureArguments, "--input-type=module", "--eval", extensionScript],
      { cwd: root },
    );
    const result = JSON.parse(accepted.stdout);
    if (result.architecture !== architecture) {
      throw new Error(`Probe requested ${architecture}; Node reported ${result.architecture}.`);
    }
    evidence.push({
      architecture,
      hardenedRuntime: true,
      allowJitRequired: true,
      disableLibraryValidationRequiredForAdHocNativeAddons: true,
      allowUnsignedExecutableMemoryRequired: executableMemoryRequired,
      nativeAddonFixture: addon.path,
      extensionFixture: true,
      allowJitOnlyRejectedRuntimeOrNativeAddon: true,
      executableMemoryEntitlementReachedLibraryValidation: true,
      adHocEntitlementsAcceptedNativeAddon: true,
    });
  } finally {
    await rm(root, { recursive: true, force: true });
  }
}
process.stdout.write(`${JSON.stringify({ capsuleRoot, target: target.id, evidence }, null, 2)}\n`);

function sign(path, entitlements) {
  const arguments_ = ["--force", "--sign", "-", "--options", "runtime", "--timestamp=none"];
  if (entitlements) arguments_.push("--entitlements", entitlements);
  arguments_.push(path);
  run("/usr/bin/codesign", arguments_);
  run("/usr/bin/codesign", ["--verify", "--strict", "--verbose=4", path]);
}

function runArchitecture(architecture, executable, arguments_, options = {}) {
  const archName = architecture === "x64" ? "x86_64" : architecture;
  return run("/usr/bin/arch", [`-${archName}`, executable, ...arguments_], options);
}

function run(executable, arguments_, options = {}) {
  const result = spawnSync(executable, arguments_, {
    cwd: options.cwd,
    env: {
      HOME: options.cwd ?? tmpdir(),
      LANG: "C",
      LC_ALL: "C",
      PATH: "",
      PI_OFFLINE: "1",
      PI_SKIP_VERSION_CHECK: "1",
      PI_TELEMETRY: "0",
    },
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });
  if (result.error) throw result.error;
  if (result.status !== 0 && !options.allowFailure) {
    throw new Error(
      `Command failed (${result.status}): ${executable} ${arguments_.join(" ")}\n${result.stderr ?? ""}`,
    );
  }
  return {
    status: result.status,
    stdout: result.stdout ?? "",
    stderr: result.stderr ?? "",
  };
}

function parseCapsule(arguments_) {
  if (arguments_.length !== 2 || arguments_[0] !== "--capsule" || !arguments_[1]) {
    throw new Error("Usage: probe-macos-hardened-runtime.mjs --capsule <path>.");
  }
  return arguments_[1];
}
