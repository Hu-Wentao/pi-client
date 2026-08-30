import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

const packageRoot = new URL("..", import.meta.url);
const packageJson = JSON.parse(readFileSync(new URL("package.json", packageRoot), "utf8"));
const lockfile = readFileSync(new URL("bun.lock", packageRoot), "utf8");

const expectedSdkVersion = "0.84.3";
if (packageJson.dependencies?.["@earendil-works/pi-coding-agent"] !== expectedSdkVersion) {
  throw new Error(`The Pi SDK dependency must be pinned exactly to ${expectedSdkVersion}.`);
}
const sdkFamilyPackages = [
  "@earendil-works/pi-agent-core",
  "@earendil-works/pi-ai",
  "@earendil-works/pi-client",
  "@earendil-works/pi-protocol",
  "@earendil-works/pi-telemetry",
  "@earendil-works/pi-tui",
];
for (const packageName of sdkFamilyPackages) {
  if (packageJson.overrides?.[packageName] !== expectedSdkVersion) {
    throw new Error(
      `${packageName} must be locked to the Pi SDK family version ${expectedSdkVersion}.`,
    );
  }
}
for (const packageName of ["@earendil-works/pi-coding-agent", ...sdkFamilyPackages]) {
  const expectedLockEntry = `"${packageName}": ["${packageName}@${expectedSdkVersion}"`;
  if (!lockfile.includes(expectedLockEntry)) {
    throw new Error(`bun.lock does not resolve ${packageName} to ${expectedSdkVersion}.`);
  }
}
if (packageJson.engines?.node !== ">=22.19.0") {
  throw new Error("The Pi Node package must declare Node.js >=22.19.0.");
}
if (packageJson.packageManager !== "bun@1.4.0") {
  throw new Error("The Pi Node package must pin Bun 1.4.0 for dependency management.");
}
if (packageJson.dependencies?.["@pi-client/protocol"] !== "file:../protocol") {
  throw new Error("Pi Node must consume the repository protocol package through file:../protocol.");
}
if (!lockfile.includes('"@pi-client/protocol": ["@pi-client/protocol@file:../protocol"')) {
  throw new Error("bun.lock must pin the local @pi-client/protocol file dependency.");
}
const protocolPackageJson = JSON.parse(
  readFileSync(new URL("../protocol/package.json", packageRoot), "utf8"),
);
if (protocolPackageJson.name !== "@pi-client/protocol" || protocolPackageJson.private !== true) {
  throw new Error(
    "The unpublished protocol package must be exported locally as @pi-client/protocol.",
  );
}

function collectFiles(directory) {
  const files = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...collectFiles(path));
    } else if (entry.isFile() && /\.(?:[cm]?[jt]s)$/.test(entry.name)) {
      files.push(path);
    }
  }
  return files;
}

const forbidden = [
  {
    label: "reference implementation name",
    pattern: new RegExp(["pi", "web"].join("-"), "i"),
  },
  {
    label: "Pi coding-agent subpath import",
    pattern: /@earendil-works\/pi-coding-agent\//,
  },
  {
    label: "experimental Pi protocol client",
    pattern: /@earendil-works\/pi-protocol\/client/,
  },
  {
    label: "deep dist import",
    pattern: /@earendil-works\/[^"']+\/dist\//,
  },
  {
    label: "upstream internal test or harness import",
    pattern: /from\s+["']@earendil-works\/[^"']*(?:internal|harness|test-utils)[^"']*["']/,
  },
];

const sourceRoot = new URL("src", packageRoot).pathname;
const files = [...collectFiles(sourceRoot), ...collectFiles(new URL("test", packageRoot).pathname)];
const publicSdkPackage = "@earendil-works/pi-coding-agent";
const sdkAdapterSourceFiles = new Set([
  "pi-sdk-domain-session.ts",
  "pi-sdk-project-session-catalog.ts",
  "pi-sdk-session-factory.ts",
  "project-trust.ts",
  "runtime-metadata.ts",
]);
const domainCoreSourceFiles = new Set(["pi-node-domain.ts", "pi-node-domain-service.ts"]);
const importPattern = /(?:from\s+|import\s*\(\s*)["']([^"']+)["']/g;
const violations = [];
for (const file of files) {
  const content = readFileSync(file, "utf8");
  for (const rule of forbidden) {
    if (rule.pattern.test(content)) {
      violations.push(`${file}: ${rule.label}`);
    }
  }

  const sourceFile = file.startsWith(sourceRoot);
  const fileName = file.slice(file.lastIndexOf("/") + 1);
  for (const match of content.matchAll(importPattern)) {
    const specifier = match[1];
    if (!specifier?.startsWith("@earendil-works/")) {
      continue;
    }
    if (specifier !== publicSdkPackage) {
      violations.push(`${file}: non-root upstream import ${specifier}`);
      continue;
    }
    if (sourceFile && !sdkAdapterSourceFiles.has(fileName)) {
      violations.push(`${file}: public Pi SDK import outside the SDK adapter boundary`);
    }
  }

  if (sourceFile && domainCoreSourceFiles.has(fileName) && content.includes("@earendil-works/")) {
    violations.push(`${file}: domain core must remain independent from upstream SDK types`);
  }
  const wireSource =
    file.includes(`${sourceRoot}/protocol/`) ||
    file.includes(`${sourceRoot}/stdio/`) ||
    file === `${sourceRoot}/index.ts` ||
    file === `${sourceRoot}/stdio-main.ts`;
  if (
    sourceFile &&
    !wireSource &&
    /(?:from\s+|import\s*\(\s*)["'](?:@pi-client\/protocol|(?:\.\.?\/)+protocol(?:\/|["']))/.test(
      content,
    )
  ) {
    violations.push(`${file}: protocol dependency outside the dedicated wire or stdio boundary`);
  }
}

if (violations.length > 0) {
  throw new Error(`Forbidden dependency boundary violations:\n${violations.join("\n")}`);
}

console.log(`Forbidden-boundary scan passed for ${files.length} TypeScript files.`);
