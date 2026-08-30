import { MAX_FRAME_BYTES } from "./limits.ts";

const PREFIX_BYTES = 4;

export class IpcFrameError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "IpcFrameError";
  }
}

export function encodeIpcLengthPrefixedFrame(
  payload: Uint8Array,
  maxFrameBytes = MAX_FRAME_BYTES,
): Uint8Array {
  assertPayloadLength(payload.length, maxFrameBytes);
  const framed = new Uint8Array(PREFIX_BYTES + payload.length);
  const view = new DataView(framed.buffer, framed.byteOffset, framed.byteLength);
  view.setUint32(0, payload.length, false);
  framed.set(payload, PREFIX_BYTES);
  return framed;
}

/**
 * Incrementally removes a four-byte big-endian length prefix from stream IPC.
 * The prefix is transport framing only and is not part of PiTransportFrame.
 */
export class IpcLengthPrefixDecoder {
  readonly #maxFrameBytes: number;
  #pending = new Uint8Array(0);

  constructor(maxFrameBytes = MAX_FRAME_BYTES) {
    if (!Number.isInteger(maxFrameBytes) || maxFrameBytes <= 0) {
      throw new IpcFrameError("maxFrameBytes must be a positive integer");
    }
    this.#maxFrameBytes = maxFrameBytes;
  }

  push(chunk: Uint8Array): Uint8Array[] {
    if (chunk.length === 0) {
      return [];
    }

    const combined = new Uint8Array(this.#pending.length + chunk.length);
    combined.set(this.#pending);
    combined.set(chunk, this.#pending.length);

    const frames: Uint8Array[] = [];
    let offset = 0;
    while (combined.length - offset >= PREFIX_BYTES) {
      const view = new DataView(
        combined.buffer,
        combined.byteOffset + offset,
        PREFIX_BYTES,
      );
      const length = view.getUint32(0, false);
      assertPayloadLength(length, this.#maxFrameBytes);
      const frameEnd = offset + PREFIX_BYTES + length;
      if (combined.length < frameEnd) {
        break;
      }
      frames.push(combined.slice(offset + PREFIX_BYTES, frameEnd));
      offset = frameEnd;
    }

    this.#pending = combined.slice(offset);
    return frames;
  }

  finish(): void {
    if (this.#pending.length !== 0) {
      throw new IpcFrameError(
        `truncated IPC frame: ${this.#pending.length} trailing byte(s)`,
      );
    }
  }
}

function assertPayloadLength(length: number, maxFrameBytes: number): void {
  if (length <= 0) {
    throw new IpcFrameError("IPC frames must contain at least one byte");
  }
  if (length > maxFrameBytes) {
    throw new IpcFrameError(
      `IPC frame length ${length} exceeds maximum ${maxFrameBytes}`,
    );
  }
}
