import { VERSION as PI_SDK_VERSION } from "@earendil-works/pi-coding-agent";

export const PI_NODE_VERSION = "0.2.0-dev.0";
export const REQUIRED_NODE_VERSION = ">=22.19.0";
export const REQUIRED_PI_SDK_VERSION = "0.84.3";

export interface PiNodeRuntimeMetadata {
  readonly piNodeVersion: string;
  readonly piSdkVersion: string;
  readonly requiredPiSdkVersion: string;
  readonly nodeVersion: string;
  readonly requiredNodeVersion: string;
  readonly platform: NodeJS.Platform;
  readonly architecture: string;
}

export class RuntimeCompatibilityError extends Error {
  readonly code = "runtime-incompatible";

  constructor(message: string) {
    super(message);
    this.name = "RuntimeCompatibilityError";
  }
}

interface SemanticVersion {
  readonly major: number;
  readonly minor: number;
  readonly patch: number;
}

function parseSemanticVersion(version: string): SemanticVersion {
  const match = /^(?:v)?(\d+)\.(\d+)\.(\d+)(?:[-+].*)?$/.exec(version);
  if (!match) {
    throw new RuntimeCompatibilityError(`Cannot parse runtime version ${version}.`);
  }

  return {
    major: Number(match[1]),
    minor: Number(match[2]),
    patch: Number(match[3]),
  };
}

function compareSemanticVersions(left: SemanticVersion, right: SemanticVersion): number {
  return left.major - right.major || left.minor - right.minor || left.patch - right.patch;
}

export function assertRuntimeCompatibility(
  options: {
    readonly nodeVersion?: string;
    readonly piSdkVersion?: string;
  } = {},
): void {
  const nodeVersion = options.nodeVersion ?? process.versions.node;
  const piSdkVersion = options.piSdkVersion ?? PI_SDK_VERSION;
  const minimumNodeVersion = parseSemanticVersion(REQUIRED_NODE_VERSION.slice(2));

  if (compareSemanticVersions(parseSemanticVersion(nodeVersion), minimumNodeVersion) < 0) {
    throw new RuntimeCompatibilityError(
      `Pi Node requires Node.js ${REQUIRED_NODE_VERSION}; found ${nodeVersion}.`,
    );
  }

  if (piSdkVersion !== REQUIRED_PI_SDK_VERSION) {
    throw new RuntimeCompatibilityError(
      `Pi Node requires Pi SDK ${REQUIRED_PI_SDK_VERSION}; found ${piSdkVersion}.`,
    );
  }
}

export function getRuntimeMetadata(): PiNodeRuntimeMetadata {
  assertRuntimeCompatibility();

  return Object.freeze({
    piNodeVersion: PI_NODE_VERSION,
    piSdkVersion: PI_SDK_VERSION,
    requiredPiSdkVersion: REQUIRED_PI_SDK_VERSION,
    nodeVersion: process.versions.node,
    requiredNodeVersion: REQUIRED_NODE_VERSION,
    platform: process.platform,
    architecture: process.arch,
  });
}
