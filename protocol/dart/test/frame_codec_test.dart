import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart';
import 'package:test/test.dart';

PiTransportFrame _validHealthFrame() => PiTransportFrame(
  frameSequence: Int64.parseInt('9007199254740993'),
  healthResponse: HealthResponse(
    requestId: 'health-1',
    status: HealthStatus.HEALTH_STATUS_SERVING,
    nodeVersion: 'node-spike',
    uptimeMillis: Int64.parseInt('9007199254740999'),
  ),
);

void main() {
  group('bounded Protobuf frame codec', () {
    test('round-trips a typed operation and uint64 values', () {
      final decoded = decodeTransportFrame(
        encodeTransportFrame(_validHealthFrame()),
      );
      expect(decoded.frameSequence.toString(), '9007199254740993');
      expect(
        decoded.whichOperation(),
        PiTransportFrame_Operation.healthResponse,
      );
      expect(
        decoded.healthResponse.uptimeMillis.toString(),
        '9007199254740999',
      );
    });

    test('rejects truncated and malformed protobuf bytes', () {
      expect(() => decodeTransportFrame([0x80]), throwsA(anything));
      expect(() => decodeTransportFrame([0x0a, 0x02, 0x01]), throwsA(anything));
    });

    test('rejects oversized and semantically invalid frames', () {
      expect(
        () => decodeTransportFrame(Uint8List(maxFrameBytes + 1)),
        throwsA(isA<FrameValidationException>()),
      );
      expect(
        () => decodeTransportFrame([0x08, 0x01]),
        throwsA(isA<FrameValidationException>()),
      );

      final invalidChunk = PiTransportFrame(
        transferChunk: TransferChunk(
          transferId: 'transfer-1',
          data: Uint8List(maxTransferChunkBytes + 1),
        ),
      );
      expect(
        () => decodeTransportFrame(invalidChunk.writeToBuffer()),
        throwsA(isA<FrameValidationException>()),
      );
    });
  });

  group('stream IPC length prefix', () {
    test('decodes split and coalesced frames', () {
      final first = encodeIpcLengthPrefixedFrame(
        encodeTransportFrame(_validHealthFrame()),
      );
      final second = encodeIpcLengthPrefixedFrame(
        encodeTransportFrame(_validHealthFrame()),
      );
      final joined = Uint8List(first.length + second.length)
        ..setAll(0, first)
        ..setAll(first.length, second);

      final decoder = IpcLengthPrefixDecoder();
      expect(decoder.push(joined.sublist(0, 3)), isEmpty);
      expect(decoder.push(joined.sublist(3)), hasLength(2));
      decoder.finish();
    });

    test('rejects truncated, zero-length, and oversized stream frames', () {
      final truncated = IpcLengthPrefixDecoder()..push([0, 0, 0, 5, 1, 2]);
      expect(truncated.finish, throwsA(isA<IpcFrameException>()));

      expect(
        () => IpcLengthPrefixDecoder().push([0, 0, 0, 0]),
        throwsA(isA<IpcFrameException>()),
      );

      final header = ByteData(4)..setUint32(0, maxFrameBytes + 1, Endian.big);
      expect(
        () => IpcLengthPrefixDecoder().push(header.buffer.asUint8List()),
        throwsA(isA<IpcFrameException>()),
      );
    });
  });
}
