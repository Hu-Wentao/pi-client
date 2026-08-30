const api = await import("../dist/index.js");
const metadata = api.getRuntimeMetadata();

if (metadata.piNodeVersion !== "0.1.0-dev.0") {
  throw new Error(`Unexpected Pi Node version: ${metadata.piNodeVersion}`);
}
if (metadata.piSdkVersion !== "0.84.3") {
  throw new Error(`Unexpected Pi SDK version: ${metadata.piSdkVersion}`);
}
if (typeof api.ProjectTrustCoordinator !== "function") {
  throw new Error("ProjectTrustCoordinator is missing from the built package.");
}
if (typeof api.PublicPiSdkRuntimeSessionFactory !== "function") {
  throw new Error("PublicPiSdkRuntimeSessionFactory is missing from the built package.");
}

console.log(
  `Built Pi Node package loaded with SDK ${metadata.piSdkVersion} on Node.js ${metadata.nodeVersion}.`,
);
