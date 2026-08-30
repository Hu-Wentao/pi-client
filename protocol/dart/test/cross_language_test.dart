import 'dart:io';
import 'dart:typed_data';

import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart';
import 'package:test/test.dart';

final _vectors = Directory('../test-vectors');
final _unknownSuffix = Uint8List.fromList([0xc0, 0xa3, 0x09, 0x7b]);

void main() {
  group('cross-language Protobuf vectors', () {
    test('decodes TypeScript health response and uint64 values', () {
      final frame = decodeTransportFrame(
        File.fromUri(
          _vectors.uri.resolve('ts_health_response.pb'),
        ).readAsBytesSync(),
      );

      expect(frame.frameSequence.toString(), '9007199254740993');
      expect(frame.whichOperation(), PiTransportFrame_Operation.healthResponse);
      expect(frame.healthResponse.requestId, 'health-ts-1');
      expect(frame.healthResponse.status, HealthStatus.HEALTH_STATUS_SERVING);
      expect(frame.healthResponse.uptimeMillis.toString(), '9007199254741111');
    });

    test('preserves unknown fields when decoded and re-encoded by Dart', () {
      final input = File.fromUri(
        _vectors.uri.resolve('unknown_field.pb'),
      ).readAsBytesSync();
      final decoded = PiTransportFrame.fromBuffer(input);
      final output = decoded.writeToBuffer();

      expect(_containsSubsequence(output, _unknownSuffix), isTrue);
      expect(
        decodeTransportFrame(output).whichOperation(),
        PiTransportFrame_Operation.healthResponse,
      );
    });
  });
}

bool _containsSubsequence(List<int> haystack, List<int> needle) {
  outer:
  for (var start = 0; start <= haystack.length - needle.length; start++) {
    for (var offset = 0; offset < needle.length; offset++) {
      if (haystack[start + offset] != needle[offset]) {
        continue outer;
      }
    }
    return true;
  }
  return false;
}
