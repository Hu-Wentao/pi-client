import { spawnSync } from "node:child_process";

export function resolveMacosArchitectureStrategy(options = {}) {
  const platform = options.platform ?? process.platform;
  if (platform !== "darwin") {
    throw new Error(`The macOS architecture strategy cannot run on ${platform}.`);
  }
  const canExecute = options.canExecute ?? canExecuteArchitecture;
  const arm64 = canExecute("arm64");
  const x64 = canExecute("x64");
  if (arm64 && x64) {
    return {
      asset: "universal",
      capsuleTarget: "darwin-universal",
      xcodeArchitectures: "arm64 x86_64",
      architectures: "arm64,x64",
      universal: "true",
      evidence: "arm64-and-x64-node-startup-required",
    };
  }
  if (arm64) {
    return {
      asset: "arm64",
      capsuleTarget: "darwin-arm64",
      xcodeArchitectures: "arm64",
      architectures: "arm64",
      universal: "false",
      evidence: "arm64-only-no-x64-rosetta-evidence",
    };
  }
  if (x64) {
    return {
      asset: "x64",
      capsuleTarget: "darwin-x64",
      xcodeArchitectures: "x86_64",
      architectures: "x64",
      universal: "false",
      evidence: "x64-only-no-arm64-execution-evidence",
    };
  }
  throw new Error("This host cannot execute an official supported macOS Node architecture.");
}

export function canExecuteArchitecture(architecture) {
  const archName = architecture === "x64" ? "x86_64" : architecture;
  const result = spawnSync("/usr/bin/arch", [`-${archName}`, "/usr/bin/true"], {
    stdio: "ignore",
  });
  if (result.error) throw result.error;
  return result.status === 0;
}
