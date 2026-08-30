import 'dart:io';
import 'dart:typed_data';

import 'package:pi_client_protocol_spike/pi_client_protocol_spike.dart';
import 'package:test/test.dart';

final _vectors = Directory('../test-vectors');
final _unknownSuffix = Uint8List.fromList([0xc0, 0xa3, 0x09, 0x7b]);

void main() {
  group('cross-language Protobuf vectors', () {
    test(
      'decodes TypeScript session response and full-range uint64 values',
      () {
        final frame = decodeTransportFrame(
          File.fromUri(
            _vectors.uri.resolve('ts_session_response.pb'),
          ).readAsBytesSync(),
        );

        expect(frame.frameSequence.toHexString(), 'FFFFFFFFFFFFFFFF');
        expect(
          frame.whichOperation(),
          PiTransportFrame_Operation.getSessionResponse,
        );
        expect(
          frame.getSessionResponse.requestId.toHexString(),
          'FFFFFFFFFFFFFFFF',
        );
        expect(
          frame.getSessionResponse.session.summary.sessionId,
          'session-ts-1',
        );
        expect(
          frame.getSessionResponse.session.summary.createdAtUnixMillis
              .toString(),
          '9007199254740993',
        );
        expect(
          frame.getSessionResponse.session.messages.single.role,
          MessageRole.MESSAGE_ROLE_ASSISTANT,
        );
      },
    );

    test('preserves unknown fields when decoded and re-encoded by Dart', () {
      final input = File.fromUri(
        _vectors.uri.resolve('unknown_field.pb'),
      ).readAsBytesSync();
      final decoded = PiTransportFrame.fromBuffer(input);
      final output = decoded.writeToBuffer();

      expect(_containsSubsequence(output, _unknownSuffix), isTrue);
      expect(
        decodeTransportFrame(output).whichOperation(),
        PiTransportFrame_Operation.getSessionResponse,
      );
    });

    test('rejects unknown operation and enum vectors', () {
      expect(
        () => decodeTransportFrame(
          File.fromUri(
            _vectors.uri.resolve('unknown_operation.pb'),
          ).readAsBytesSync(),
        ),
        throwsA(isA<FrameValidationException>()),
      );
      expect(
        () => decodeTransportFrame(
          File.fromUri(
            _vectors.uri.resolve('unknown_enum.pb'),
          ).readAsBytesSync(),
        ),
        throwsA(isA<FrameValidationException>()),
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
