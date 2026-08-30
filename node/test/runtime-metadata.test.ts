import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import {
  assertRuntimeCompatibility,
  getRuntimeMetadata,
  PI_NODE_VERSION,
  REQUIRED_NODE_VERSION,
  REQUIRED_PI_SDK_VERSION,
  RuntimeCompatibilityError,
} from "../src/runtime-metadata.js";

test("runtime metadata matches the package and exact public Pi SDK version", async () => {
  const packageJson = JSON.parse(
    await readFile(new URL("../package.json", import.meta.url), "utf8"),
  ) as {
    version: string;
    engines: { node: string };
    dependencies: Record<string, string>;
  };
  const metadata = getRuntimeMetadata();

  assert.equal(metadata.piNodeVersion, packageJson.version);
  assert.equal(PI_NODE_VERSION, packageJson.version);
  assert.equal(metadata.piSdkVersion, REQUIRED_PI_SDK_VERSION);
  assert.equal(
    packageJson.dependencies["@earendil-works/pi-coding-agent"],
    REQUIRED_PI_SDK_VERSION,
  );
  assert.equal(packageJson.engines.node, REQUIRED_NODE_VERSION);
});

test("runtime compatibility enforces Node.js 22.19.0 and the exact SDK version", () => {
  assert.doesNotThrow(() =>
    assertRuntimeCompatibility({ nodeVersion: "22.19.0", piSdkVersion: "0.84.3" }),
  );
  assert.doesNotThrow(() =>
    assertRuntimeCompatibility({ nodeVersion: "24.0.0", piSdkVersion: "0.84.3" }),
  );
  assert.throws(
    () => assertRuntimeCompatibility({ nodeVersion: "22.18.9", piSdkVersion: "0.84.3" }),
    RuntimeCompatibilityError,
  );
  assert.throws(
    () => assertRuntimeCompatibility({ nodeVersion: "22.19.0", piSdkVersion: "0.84.4" }),
    RuntimeCompatibilityError,
  );
});
