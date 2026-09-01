const api = await import("../dist/index.js");
const metadata = api.getRuntimeMetadata();

if (metadata.piNodeVersion !== "0.2.0-dev.0") {
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
if (typeof api.PiNodeDomainService !== "function") {
  throw new Error("PiNodeDomainService is missing from the built package.");
}
if (typeof api.PublicPiSdkDomainSessionFactory !== "function") {
  throw new Error("PublicPiSdkDomainSessionFactory is missing from the built package.");
}
if (typeof api.PiNodeProtobufConnection !== "function") {
  throw new Error("PiNodeProtobufConnection is missing from the built package.");
}
if (typeof api.runPiNodeStdioServer !== "function") {
  throw new Error("runPiNodeStdioServer is missing from the built package.");
}

console.log(
  `Built Pi Node package loaded with SDK ${metadata.piSdkVersion} on Node.js ${metadata.nodeVersion}.`,
);
