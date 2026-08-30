import { fromBinary, toBinary } from "@bufbuild/protobuf";
import {
  ErrorCode,
  HealthStatus,
  PiTransportFrameSchema,
  TransferDirection,
  TransferPurpose,
  type PiTransportFrame,
  type StableError,
} from "../gen/ts/pi/client/protocol/v0/protocol_pb.ts";
import {
  MAX_CAPABILITIES,
  MAX_ERROR_MESSAGE_BYTES,
  MAX_FRAME_BYTES,
  MAX_IDENTIFIER_BYTES,
  MAX_SHORT_TEXT_BYTES,
  MAX_TRANSFER_CHUNK_BYTES,
  SHA256_BYTES,
} from "./limits.ts";

const textEncoder = new TextEncoder();

export class FrameValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "FrameValidationError";
  }
}

export function encodeTransportFrame(frame: PiTransportFrame): Uint8Array {
  validateTransportFrame(frame);
  const bytes = toBinary(PiTransportFrameSchema, frame);
  assertFrameByteLength(bytes.length);
  return bytes;
}

export function decodeTransportFrame(bytes: Uint8Array): PiTransportFrame {
  assertFrameByteLength(bytes.length);
  const frame = fromBinary(PiTransportFrameSchema, bytes);
  validateTransportFrame(frame);
  return frame;
}

export function validateTransportFrame(frame: PiTransportFrame): void {
  const operation = frame.operation;
  switch (operation.case) {
    case "bootstrapHello": {
      const hello = operation.value;
      validateOptionalIdentifier("connection_id", hello.connectionId);
      validateIdentifier("peer_id", hello.peerId);
      validateText("implementation_name", hello.implementationName, true);
      validateText("implementation_version", hello.implementationVersion, true);
      if (hello.maxFrameBytes <= 0 || hello.maxFrameBytes > MAX_FRAME_BYTES) {
        fail("bootstrap max_frame_bytes is outside the local hard limit");
      }
      if (
        hello.maxTransferChunkBytes <= 0 ||
        hello.maxTransferChunkBytes > MAX_TRANSFER_CHUNK_BYTES
      ) {
        fail("bootstrap max_transfer_chunk_bytes is outside the local hard limit");
      }
      if (hello.capabilities.length > MAX_CAPABILITIES) {
        fail("bootstrap capability count exceeds the local hard limit");
      }
      return;
    }
    case "healthRequest":
      validateIdentifier("request_id", operation.value.requestId);
      return;
    case "healthResponse":
      validateIdentifier("request_id", operation.value.requestId);
      validateText("node_version", operation.value.nodeVersion, false);
      if (operation.value.status === HealthStatus.UNSPECIFIED) {
        fail("health response status must be specified");
      }
      return;
    case "eventStream": {
      const stream = operation.value;
      validateIdentifier("stream_id", stream.streamId);
      switch (stream.event.case) {
        case "heartbeat":
          return;
        case "healthStatusChanged":
          if (stream.event.value.status === HealthStatus.UNSPECIFIED) {
            fail("health status event must specify a status");
          }
          validateText("health summary", stream.event.value.summary, false);
          return;
        case "streamClosed":
          if (stream.event.value.error !== undefined) {
            validateStableError(stream.event.value.error);
          }
          return;
        case undefined:
          fail("event stream envelope must contain a typed event");
      }
      return;
    }
    case "cancel":
      validateTarget(operation.value.target, "cancel");
      validateText("cancel reason", operation.value.reason, false);
      return;
    case "windowUpdate":
      validateTarget(operation.value.target, "window update");
      if (
        operation.value.creditMessages === 0 &&
        operation.value.creditBytes === 0n
      ) {
        fail("window update must grant message or byte credit");
      }
      return;
    case "transferOpen": {
      const transfer = operation.value;
      validateIdentifier("transfer_id", transfer.transferId);
      if (transfer.direction === TransferDirection.UNSPECIFIED) {
        fail("transfer direction must be specified");
      }
      if (transfer.purpose === TransferPurpose.UNSPECIFIED) {
        fail("transfer purpose must be specified");
      }
      validateText("content_type", transfer.contentType, false);
      validateText("file_name", transfer.fileName, false);
      if (
        transfer.chunkBytes <= 0 ||
        transfer.chunkBytes > MAX_TRANSFER_CHUNK_BYTES
      ) {
        fail("transfer chunk_bytes is outside the local hard limit");
      }
      validateDigest(transfer.sha256);
      return;
    }
    case "transferChunk":
      validateIdentifier("transfer_id", operation.value.transferId);
      if (
        operation.value.data.length === 0 ||
        operation.value.data.length > MAX_TRANSFER_CHUNK_BYTES
      ) {
        fail("transfer chunk data is outside the local hard limit");
      }
      return;
    case "transferAck":
      validateIdentifier("transfer_id", operation.value.transferId);
      return;
    case "transferComplete":
      validateIdentifier("transfer_id", operation.value.transferId);
      validateDigest(operation.value.sha256);
      return;
    case "transferAbort":
      validateIdentifier("transfer_id", operation.value.transferId);
      if (operation.value.error === undefined) {
        fail("transfer abort must contain a stable error");
      }
      validateStableError(operation.value.error);
      return;
    case "error":
      if (operation.value.correlation.case !== undefined) {
        validateIdentifier(
          operation.value.correlation.case,
          operation.value.correlation.value,
        );
      }
      if (operation.value.error === undefined) {
        fail("error envelope must contain a stable error");
      }
      validateStableError(operation.value.error);
      return;
    case undefined:
      fail("transport frame must contain a typed operation");
  }
}

function validateTarget(
  target: { case: string | undefined; value?: string },
  label: string,
): void {
  if (target.case === undefined || target.value === undefined) {
    fail(`${label} must contain a target identifier`);
  }
  validateIdentifier(target.case, target.value);
}

function validateStableError(error: StableError): void {
  if (error.code === ErrorCode.UNSPECIFIED) {
    fail("stable error code must be specified");
  }
  const bytes = textEncoder.encode(error.message).length;
  if (bytes === 0 || bytes > MAX_ERROR_MESSAGE_BYTES) {
    fail("stable error message is outside the local hard limit");
  }
}

function validateDigest(digest: Uint8Array): void {
  if (digest.length !== 0 && digest.length !== SHA256_BYTES) {
    fail("sha256 must be empty or exactly 32 bytes");
  }
}

function validateIdentifier(label: string, value: string): void {
  const bytes = textEncoder.encode(value).length;
  if (bytes === 0 || bytes > MAX_IDENTIFIER_BYTES) {
    fail(`${label} is outside the local identifier limit`);
  }
}

function validateOptionalIdentifier(label: string, value: string): void {
  if (value.length !== 0) {
    validateIdentifier(label, value);
  }
}

function validateText(label: string, value: string, required: boolean): void {
  const bytes = textEncoder.encode(value).length;
  if ((required && bytes === 0) || bytes > MAX_SHORT_TEXT_BYTES) {
    fail(`${label} is outside the local text limit`);
  }
}

function assertFrameByteLength(length: number): void {
  if (length <= 0) {
    fail("transport frame must contain at least one byte");
  }
  if (length > MAX_FRAME_BYTES) {
    fail(`transport frame exceeds ${MAX_FRAME_BYTES} bytes`);
  }
}

function fail(message: string): never {
  throw new FrameValidationError(message);
}
