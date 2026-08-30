#!/usr/bin/env node

import type { PiNodeDomainService as PiNodeDomainServiceType } from "./pi-node-domain-service.js";

interface LaunchOptions {
  readonly cwd: string;
  readonly agentDir: string;
}

installConsoleRedaction();

let service: PiNodeDomainServiceType | undefined;
try {
  const [
    domainServiceModule,
    sdkAdapterModule,
    protocolAdapterModule,
    trustModule,
    metadataModule,
    stdioModule,
  ] = await Promise.all([
    import("./pi-node-domain-service.js"),
    import("./pi-sdk-domain-session.js"),
    import("./protocol/pi-node-protocol-domain-port.js"),
    import("./project-trust.js"),
    import("./runtime-metadata.js"),
    import("./stdio/pi-node-stdio-server.js"),
  ]);
  metadataModule.assertRuntimeCompatibility();
  const launch = parseLaunchOptions(process.argv.slice(2), process.env);
  service = new domainServiceModule.PiNodeDomainService({
    agentDir: launch.agentDir,
    trustCoordinator: new trustModule.ProjectTrustCoordinator(),
    sessionFactory: new sdkAdapterModule.PublicPiSdkDomainSessionFactory(),
  });
  const result = await stdioModule.runPiNodeStdioServer({
    domain: new protocolAdapterModule.PiNodeDomainServiceProtocolAdapter(service),
    workingDirectory: launch.cwd,
    implementationVersion: metadataModule.PI_NODE_VERSION,
  });
  process.exitCode =
    result.reason === "input-ended"
      ? 0
      : result.reason === "handshake-rejected" || result.reason === "protocol-error"
        ? 2
        : 1;
} catch {
  process.stderr.write("[pi-client-node] startup-failed\n");
  process.exitCode = 1;
} finally {
  if (service) {
    try {
      await service.dispose();
    } catch {
      process.stderr.write("[pi-client-node] shutdown-failed\n");
      process.exitCode = 1;
    }
  }
}

function parseLaunchOptions(
  arguments_: readonly string[],
  environment: NodeJS.ProcessEnv,
): LaunchOptions {
  let cwd = environment.PI_CLIENT_NODE_CWD;
  let agentDir = environment.PI_CODING_AGENT_DIR;

  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index];
    if (argument === "--cwd") {
      cwd = requireOptionValue(arguments_, ++index);
      continue;
    }
    if (argument === "--agent-dir") {
      agentDir = requireOptionValue(arguments_, ++index);
      continue;
    }
    throw new Error("Unsupported Pi Node stdio launch option.");
  }

  if (!cwd?.trim() || !agentDir?.trim()) {
    throw new Error("Pi Node stdio requires an explicit cwd and agent directory.");
  }
  return Object.freeze({ cwd, agentDir });
}

function requireOptionValue(arguments_: readonly string[], index: number): string {
  const value = arguments_[index];
  if (!value?.trim()) {
    throw new Error("A Pi Node stdio launch option is missing its value.");
  }
  return value;
}

function installConsoleRedaction(): void {
  const write = () => process.stderr.write("[pi-client-node] dependency-log-redacted\n");
  console.log = write;
  console.info = write;
  console.debug = write;
  console.warn = write;
  console.error = write;
}
