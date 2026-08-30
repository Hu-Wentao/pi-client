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

const files = [
  ...collectFiles(new URL("src", packageRoot).pathname),
  ...collectFiles(new URL("test", packageRoot).pathname),
];
const violations = [];
for (const file of files) {
  const content = readFileSync(file, "utf8");
  for (const rule of forbidden) {
    if (rule.pattern.test(content)) {
      violations.push(`${file}: ${rule.label}`);
    }
  }
}

if (violations.length > 0) {
  throw new Error(`Forbidden dependency boundary violations:\n${violations.join("\n")}`);
}

console.log(`Forbidden-boundary scan passed for ${files.length} TypeScript files.`);
