import type { Readable, Writable } from "node:stream";

import { IpcLengthPrefixDecoder, encodeIpcLengthPrefixedFrame } from "@pi-client/protocol";

import {
  PiNodeProtobufConnection,
  type PiNodeProtocolLogCode,
  type PiNodeProtocolLogger,
} from "../protocol/pi-node-protobuf-connection.js";
import type { PiNodeProtocolDomain } from "../protocol/pi-node-protocol-domain-port.js";

export interface PiNodeStdioServerOptions {
  readonly domain: PiNodeProtocolDomain;
  readonly implementationVersion: string;
  readonly input?: Readable;
  readonly output?: Writable;
  readonly errorOutput?: Writable;
  readonly nodeInstanceId?: string;
  readonly streamIdFactory?: (sessionId: string, ordinal: number) => string;
}

export interface PiNodeStdioServerResult {
  readonly reason:
    | "input-ended"
    | "handshake-rejected"
    | "protocol-error"
    | "input-error"
    | "output-error";
}

export class RedactedStderrLogger implements PiNodeProtocolLogger {
  constructor(readonly output: Writable = process.stderr) {}

  info(code: PiNodeProtocolLogCode): void {
    this.#write(code);
  }

  error(code: PiNodeProtocolLogCode): void {
    this.#write(code);
  }

  #write(code: PiNodeProtocolLogCode): void {
    this.output.write(`[pi-client-node] ${code}\n`);
  }
}

/**
 * Runs one binary Protobuf connection over stdin/stdout. Stdout is reserved for
 * four-byte big-endian length-prefixed protocol frames.
 */
export async function runPiNodeStdioServer(
  options: PiNodeStdioServerOptions,
): Promise<PiNodeStdioServerResult> {
  const input = options.input ?? process.stdin;
  const output = options.output ?? process.stdout;
  const errorOutput = options.errorOutput ?? process.stderr;
  if (output === errorOutput) {
    throw new Error("Protocol stdout and diagnostic stderr must be separate streams.");
  }
  const logger = new RedactedStderrLogger(errorOutput);
  let outputFailed = false;

  const connection = new PiNodeProtobufConnection({
    domain: options.domain,
    implementationVersion: options.implementationVersion,
    ...(options.nodeInstanceId === undefined ? {} : { nodeInstanceId: options.nodeInstanceId }),
    ...(options.streamIdFactory === undefined ? {} : { streamIdFactory: options.streamIdFactory }),
    logger,
    writeFrame: async (payload) => {
      try {
        await writeBytes(output, encodeIpcLengthPrefixedFrame(payload));
      } catch {
        outputFailed = true;
        throw new Error("Protocol output failed.");
      }
    },
  });
  const decoder = new IpcLengthPrefixDecoder();

  try {
    for await (const rawChunk of input) {
      const chunk = toBytes(rawChunk);
      let payloads: Uint8Array[];
      try {
        payloads = decoder.push(chunk);
      } catch {
        const result = await connection.rejectMalformedTransport();
        input.destroy();
        return { reason: result.reason ?? "protocol-error" };
      }

      for (const payload of payloads) {
        const result = await connection.receive(payload);
        if (result.close) {
          input.destroy();
          return { reason: result.reason ?? "protocol-error" };
        }
      }
    }

    try {
      decoder.finish();
    } catch {
      const result = await connection.rejectMalformedTransport();
      return { reason: result.reason ?? "protocol-error" };
    }
    return { reason: outputFailed ? "output-error" : "input-ended" };
  } catch {
    return { reason: outputFailed ? "output-error" : "input-error" };
  } finally {
    await connection.dispose();
  }
}

async function writeBytes(output: Writable, bytes: Uint8Array): Promise<void> {
  if (output.destroyed) {
    throw new Error("Protocol output is closed.");
  }

  await new Promise<void>((resolve, reject) => {
    let settled = false;
    const finish = (error?: Error | null) => {
      if (settled) {
        return;
      }
      settled = true;
      output.off("error", onError);
      if (error) {
        reject(new Error("Protocol output failed."));
      } else {
        resolve();
      }
    };
    const onError = () => finish(new Error("Protocol output failed."));
    output.once("error", onError);
    output.write(bytes, finish);
  });
}

function toBytes(chunk: unknown): Uint8Array {
  if (chunk instanceof Uint8Array) {
    return chunk;
  }
  if (typeof chunk === "string") {
    return new TextEncoder().encode(chunk);
  }
  throw new TypeError("Stdio input emitted an unsupported chunk type.");
}
