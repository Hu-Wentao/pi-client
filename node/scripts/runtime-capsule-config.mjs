export const CAPSULE_SCHEMA_VERSION = 2;
export const NODE_RUNTIME_VERSION = "22.19.0";
export const REQUIRED_BUN_VERSION = "1.4.0";
export const REQUIRED_PI_SDK_VERSION = "0.84.3";
export const REQUIRED_PROTOBUF_VERSION = "2.14.0";
export const NODE_DISTRIBUTION_BASE_URL = `https://nodejs.org/dist/v${NODE_RUNTIME_VERSION}`;
export const NODE_SHASUMS_URL = `${NODE_DISTRIBUTION_BASE_URL}/SHASUMS256.txt`;

const distributionDefinitions = {
  "darwin-arm64": {
    id: "darwin-arm64",
    platform: "darwin",
    architecture: "arm64",
    archiveKind: "tar.gz",
    archiveName: `node-v${NODE_RUNTIME_VERSION}-darwin-arm64.tar.gz`,
    archiveRoot: `node-v${NODE_RUNTIME_VERSION}-darwin-arm64`,
    archiveSha256: "c59006db713c770d6ec63ae16cb3edc11f49ee093b5c415d667bb4f436c6526d",
  },
  "darwin-x64": {
    id: "darwin-x64",
    platform: "darwin",
    architecture: "x64",
    archiveKind: "tar.gz",
    archiveName: `node-v${NODE_RUNTIME_VERSION}-darwin-x64.tar.gz`,
    archiveRoot: `node-v${NODE_RUNTIME_VERSION}-darwin-x64`,
    archiveSha256: "3cfed4795cd97277559763c5f56e711852d2cc2420bda1cea30c8aa9ac77ce0c",
  },
  "linux-x64": {
    id: "linux-x64",
    platform: "linux",
    architecture: "x64",
    archiveKind: "tar.xz",
    archiveName: `node-v${NODE_RUNTIME_VERSION}-linux-x64.tar.xz`,
    archiveRoot: `node-v${NODE_RUNTIME_VERSION}-linux-x64`,
    archiveSha256: "c0649af18e6a24f6fe5535a3e86b341dd49a8e71117c8b68bde973ef834f16f2",
  },
  "win32-x64": {
    id: "win32-x64",
    platform: "win32",
    architecture: "x64",
    archiveKind: "zip",
    archiveName: `node-v${NODE_RUNTIME_VERSION}-win-x64.zip`,
    archiveRoot: `node-v${NODE_RUNTIME_VERSION}-win-x64`,
    archiveSha256: "ea3fad0e67a991d8477d8c01344b56e69c676ccb733f065b22436994b1253f86",
  },
};

const targetDefinitions = {
  "darwin-arm64": targetFromDistributions("darwin-arm64", ["darwin-arm64"]),
  "darwin-x64": targetFromDistributions("darwin-x64", ["darwin-x64"]),
  "darwin-universal": targetFromDistributions("darwin-universal", ["darwin-arm64", "darwin-x64"]),
  "linux-x64": targetFromDistributions("linux-x64", ["linux-x64"]),
  "win32-x64": targetFromDistributions("win32-x64", ["win32-x64"]),
};

export const SUPPORTED_CAPSULE_TARGETS = Object.freeze(
  Object.fromEntries(
    Object.entries(targetDefinitions).map(([id, definition]) => [id, deepFreeze(definition)]),
  ),
);

export function resolveNodeDistribution(targetId) {
  const target = SUPPORTED_CAPSULE_TARGETS[targetId];
  if (!target) {
    throw new Error(
      `Unsupported Pi Node capsule target ${JSON.stringify(targetId)}. Supported targets: ${Object.keys(
        SUPPORTED_CAPSULE_TARGETS,
      ).join(", ")}.`,
    );
  }
  return target;
}

export function currentCapsuleTargetId(platform = process.platform, architecture = process.arch) {
  const targetId = `${platform}-${architecture}`;
  resolveNodeDistribution(targetId);
  return targetId;
}

function targetFromDistributions(id, distributionIds) {
  const distributions = distributionIds.map((distributionId) => {
    const definition = distributionDefinitions[distributionId];
    if (!definition) throw new Error(`Unknown Node distribution ${distributionId}.`);
    return {
      ...definition,
      archiveUrl: `${NODE_DISTRIBUTION_BASE_URL}/${definition.archiveName}`,
      checksumsUrl: NODE_SHASUMS_URL,
    };
  });
  const platform = distributions[0].platform;
  if (distributions.some((distribution) => distribution.platform !== platform)) {
    throw new Error(`Capsule target ${id} mixes Node distribution platforms.`);
  }
  const architectures = distributions.map((distribution) => distribution.architecture);
  return {
    id,
    platform,
    architecture: architectures.length === 1 ? architectures[0] : "universal",
    architectures,
    distributions,
    architectureArguments: architectures.map((architecture) => ({
      architecture,
      arguments: [],
    })),
    executable: platform === "win32" ? "runtime/node.exe" : "runtime/bin/node",
    npmCli:
      platform === "win32"
        ? "runtime/node_modules/npm/bin/npm-cli.js"
        : "runtime/lib/node_modules/npm/bin/npm-cli.js",
    nodeLicense: "runtime/LICENSE",
    npmLicense:
      platform === "win32"
        ? "runtime/node_modules/npm/LICENSE"
        : "runtime/lib/node_modules/npm/LICENSE",
  };
}

function deepFreeze(value) {
  if (!value || typeof value !== "object" || Object.isFrozen(value)) return value;
  for (const child of Object.values(value)) deepFreeze(child);
  return Object.freeze(value);
}
