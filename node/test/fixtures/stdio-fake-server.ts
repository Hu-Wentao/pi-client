import { runPiNodeStdioServer } from "../../src/stdio/pi-node-stdio-server.js";
import { FakeProtocolDomain } from "../support/fake-protocol-domain.js";

const result = await runPiNodeStdioServer({
  domain: new FakeProtocolDomain(),
  implementationVersion: "0.1.0-dev.0",
  nodeInstanceId: "fake-stdio-node",
  streamIdFactory: (_sessionId, ordinal) => `stdio-stream-${ordinal}`,
});

process.exitCode =
  result.reason === "input-ended"
    ? 0
    : result.reason === "handshake-rejected" || result.reason === "protocol-error"
      ? 2
      : 1;
