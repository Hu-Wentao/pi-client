import 'dart:convert';
import 'dart:typed_data';

import 'gen/pi/client/protocol/v0/protocol.pb.dart';
import 'limits.dart';

final class FrameValidationException implements Exception {
  FrameValidationException(this.message);

  final String message;

  @override
  String toString() => 'FrameValidationException: $message';
}

Uint8List encodeTransportFrame(PiTransportFrame frame) {
  validateTransportFrame(frame);
  final bytes = frame.writeToBuffer();
  _validateFrameByteLength(bytes.length);
  return bytes;
}

PiTransportFrame decodeTransportFrame(List<int> bytes) {
  _validateFrameByteLength(bytes.length);
  final frame = PiTransportFrame.fromBuffer(bytes);
  validateTransportFrame(frame);
  return frame;
}

void validateTransportFrame(PiTransportFrame frame) {
  switch (frame.whichOperation()) {
    case PiTransportFrame_Operation.bootstrapHello:
      final hello = frame.bootstrapHello;
      _validateOptionalIdentifier('connection_id', hello.connectionId);
      _validateIdentifier('peer_id', hello.peerId);
      _validateText('implementation_name', hello.implementationName, true);
      _validateText(
        'implementation_version',
        hello.implementationVersion,
        true,
      );
      if (hello.maxFrameBytes <= 0 || hello.maxFrameBytes > maxFrameBytes) {
        _fail('bootstrap max_frame_bytes is outside the local hard limit');
      }
      if (hello.maxTransferChunkBytes <= 0 ||
          hello.maxTransferChunkBytes > maxTransferChunkBytes) {
        _fail(
          'bootstrap max_transfer_chunk_bytes is outside the local hard limit',
        );
      }
      if (hello.capabilities.length > maxCapabilities) {
        _fail('bootstrap capability count exceeds the local hard limit');
      }
    case PiTransportFrame_Operation.healthRequest:
      _validateIdentifier('request_id', frame.healthRequest.requestId);
    case PiTransportFrame_Operation.healthResponse:
      final response = frame.healthResponse;
      _validateIdentifier('request_id', response.requestId);
      _validateText('node_version', response.nodeVersion, false);
      if (response.status == HealthStatus.HEALTH_STATUS_UNSPECIFIED) {
        _fail('health response status must be specified');
      }
    case PiTransportFrame_Operation.eventStream:
      final stream = frame.eventStream;
      _validateIdentifier('stream_id', stream.streamId);
      switch (stream.whichEvent()) {
        case EventStreamEnvelope_Event.heartbeat:
          return;
        case EventStreamEnvelope_Event.healthStatusChanged:
          final event = stream.healthStatusChanged;
          if (event.status == HealthStatus.HEALTH_STATUS_UNSPECIFIED) {
            _fail('health status event must specify a status');
          }
          _validateText('health summary', event.summary, false);
        case EventStreamEnvelope_Event.streamClosed:
          if (stream.streamClosed.hasError()) {
            _validateStableError(stream.streamClosed.error);
          }
        case EventStreamEnvelope_Event.notSet:
          _fail('event stream envelope must contain a typed event');
      }
    case PiTransportFrame_Operation.cancel:
      final cancel = frame.cancel;
      switch (cancel.whichTarget()) {
        case Cancel_Target.requestId:
          _validateIdentifier('request_id', cancel.requestId);
        case Cancel_Target.streamId:
          _validateIdentifier('stream_id', cancel.streamId);
        case Cancel_Target.transferId:
          _validateIdentifier('transfer_id', cancel.transferId);
        case Cancel_Target.notSet:
          _fail('cancel must contain a target identifier');
      }
      _validateText('cancel reason', cancel.reason, false);
    case PiTransportFrame_Operation.windowUpdate:
      final update = frame.windowUpdate;
      switch (update.whichTarget()) {
        case WindowUpdate_Target.streamId:
          _validateIdentifier('stream_id', update.streamId);
        case WindowUpdate_Target.transferId:
          _validateIdentifier('transfer_id', update.transferId);
        case WindowUpdate_Target.notSet:
          _fail('window update must contain a target identifier');
      }
      if (update.creditMessages == 0 && update.creditBytes.isZero) {
        _fail('window update must grant message or byte credit');
      }
    case PiTransportFrame_Operation.transferOpen:
      final transfer = frame.transferOpen;
      _validateIdentifier('transfer_id', transfer.transferId);
      if (transfer.direction ==
          TransferDirection.TRANSFER_DIRECTION_UNSPECIFIED) {
        _fail('transfer direction must be specified');
      }
      if (transfer.purpose == TransferPurpose.TRANSFER_PURPOSE_UNSPECIFIED) {
        _fail('transfer purpose must be specified');
      }
      _validateText('content_type', transfer.contentType, false);
      _validateText('file_name', transfer.fileName, false);
      if (transfer.chunkBytes <= 0 ||
          transfer.chunkBytes > maxTransferChunkBytes) {
        _fail('transfer chunk_bytes is outside the local hard limit');
      }
      _validateDigest(transfer.sha256);
    case PiTransportFrame_Operation.transferChunk:
      final chunk = frame.transferChunk;
      _validateIdentifier('transfer_id', chunk.transferId);
      if (chunk.data.isEmpty || chunk.data.length > maxTransferChunkBytes) {
        _fail('transfer chunk data is outside the local hard limit');
      }
    case PiTransportFrame_Operation.transferAck:
      _validateIdentifier('transfer_id', frame.transferAck.transferId);
    case PiTransportFrame_Operation.transferComplete:
      final complete = frame.transferComplete;
      _validateIdentifier('transfer_id', complete.transferId);
      _validateDigest(complete.sha256);
    case PiTransportFrame_Operation.transferAbort:
      final abort = frame.transferAbort;
      _validateIdentifier('transfer_id', abort.transferId);
      if (!abort.hasError()) {
        _fail('transfer abort must contain a stable error');
      }
      _validateStableError(abort.error);
    case PiTransportFrame_Operation.error:
      final envelope = frame.error;
      switch (envelope.whichCorrelation()) {
        case ErrorEnvelope_Correlation.requestId:
          _validateIdentifier('request_id', envelope.requestId);
        case ErrorEnvelope_Correlation.streamId:
          _validateIdentifier('stream_id', envelope.streamId);
        case ErrorEnvelope_Correlation.transferId:
          _validateIdentifier('transfer_id', envelope.transferId);
        case ErrorEnvelope_Correlation.notSet:
          break;
      }
      if (!envelope.hasError()) {
        _fail('error envelope must contain a stable error');
      }
      _validateStableError(envelope.error);
    case PiTransportFrame_Operation.notSet:
      _fail('transport frame must contain a typed operation');
  }
}

void _validateStableError(StableError error) {
  if (error.code == ErrorCode.ERROR_CODE_UNSPECIFIED) {
    _fail('stable error code must be specified');
  }
  final length = utf8.encode(error.message).length;
  if (length == 0 || length > maxErrorMessageBytes) {
    _fail('stable error message is outside the local hard limit');
  }
}

void _validateDigest(List<int> digest) {
  if (digest.isNotEmpty && digest.length != sha256Bytes) {
    _fail('sha256 must be empty or exactly 32 bytes');
  }
}

void _validateIdentifier(String label, String value) {
  final length = utf8.encode(value).length;
  if (length == 0 || length > maxIdentifierBytes) {
    _fail('$label is outside the local identifier limit');
  }
}

void _validateOptionalIdentifier(String label, String value) {
  if (value.isNotEmpty) {
    _validateIdentifier(label, value);
  }
}

void _validateText(String label, String value, bool required) {
  final length = utf8.encode(value).length;
  if ((required && length == 0) || length > maxShortTextBytes) {
    _fail('$label is outside the local text limit');
  }
}

void _validateFrameByteLength(int length) {
  if (length <= 0) {
    _fail('transport frame must contain at least one byte');
  }
  if (length > maxFrameBytes) {
    _fail('transport frame exceeds $maxFrameBytes bytes');
  }
}

Never _fail(String message) {
  throw FrameValidationException(message);
}
