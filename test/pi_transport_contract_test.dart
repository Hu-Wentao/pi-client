import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/transport/in_memory_pi_transport.dart';
import 'package:pi_client/transport/pi_transport.dart';

import 'support/pi_transport_conformance.dart';

void main() {
  test('keeps binary frames redacted and defensively copied', () {
    final source = Uint8List.fromList(<int>[1, 2, 3]);
    final frame = PiTransportFrame(source);
    source[0] = 9;

    final firstRead = frame.bytes;
    expect(firstRead, <int>[1, 2, 3]);
    firstRead[1] = 9;
    expect(frame.bytes, <int>[1, 2, 3]);
    expect(frame.toString(), isNot(contains('1, 2, 3')));
  });

  test('rejects empty frames without exposing frame contents', () {
    expect(
      () => PiTransportFrame(Uint8List(0)),
      throwsA(
        isA<PiTransportException>()
            .having(
              (error) => error.code,
              'code',
              PiTransportErrorCode.invalidFrame,
            )
            .having(
              (error) => error.toString(),
              'redacted',
              contains('<redacted>'),
            ),
      ),
    );
  });

  definePiTransportConformance('in-memory', () {
    final pair = InMemoryPiTransportPair();
    return (first: pair.first, second: pair.second);
  });
}
