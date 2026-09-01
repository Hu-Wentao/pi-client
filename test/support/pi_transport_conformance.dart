import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/transport/pi_transport.dart';

typedef PiTransportPairFactory =
    ({PiTransport first, PiTransport second}) Function();

void definePiTransportConformance(
  String implementationName,
  PiTransportPairFactory createPair,
) {
  group('$implementationName transport conformance', () {
    test('delivers defensive binary frames in send order', () async {
      final pair = createPair();
      final received = pair.second.incoming.take(3).toList();

      await pair.first.send(_frame(1));
      await pair.first.send(_frame(2));
      await pair.first.send(_frame(3));

      expect((await received).map((frame) => frame.bytes.single), <int>[
        1,
        2,
        3,
      ]);
      await pair.first.close();
    });

    test('ends incoming before done and makes close idempotent', () async {
      final pair = createPair();
      var incomingEnded = false;
      final incomingDone = Completer<void>();
      pair.second.incoming.listen(
        (_) {},
        onDone: () {
          incomingEnded = true;
          incomingDone.complete();
        },
      );
      final peerDone = pair.second.done.then((_) {
        expect(incomingEnded, isTrue);
      });

      final firstClose = pair.first.close();
      final secondClose = pair.first.close();
      expect(identical(firstClose, secondClose), isTrue);
      await firstClose;
      await incomingDone.future;
      await peerDone;
      await pair.second.close();
    });

    test('rejects sends after either endpoint closes', () async {
      final pair = createPair();
      await pair.second.close();

      await expectLater(
        pair.first.send(_frame(1)),
        throwsA(
          isA<PiTransportException>().having(
            (error) => error.code,
            'code',
            PiTransportErrorCode.closed,
          ),
        ),
      );
      await expectLater(
        pair.second.send(_frame(2)),
        throwsA(isA<PiTransportException>()),
      );
    });
  });
}

PiTransportFrame _frame(int value) =>
    PiTransportFrame(Uint8List.fromList(<int>[value]));
