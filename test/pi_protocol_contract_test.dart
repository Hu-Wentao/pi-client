import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/protocol/pi_protocol.dart';

void main() {
  test('represents ordered protocol versions without a default release', () {
    expect(PiProtocolVersion(0, 0, 1).toString(), '0.0.1');
    expect(PiProtocolVersion(1, 2, 3), PiProtocolVersion(1, 2, 3));
    expect(
      PiProtocolVersion(1, 2, 3).compareTo(PiProtocolVersion(1, 3, 0)),
      -1,
    );
    expect(() => PiProtocolVersion(-1, 0, 0), throwsArgumentError);
    expect(() => PiProtocolVersion(0, -1, 0), throwsArgumentError);
    expect(() => PiProtocolVersion(0, 0, -1), throwsArgumentError);
  });

  test('keeps protocol offers ordered, unique, and non-empty', () {
    final first = PiProtocolVersion(1, 1, 0);
    final second = PiProtocolVersion(1, 0, 0);
    final offer = PiProtocolOffer(<PiProtocolVersion>[first, second]);

    expect(offer.versions, <PiProtocolVersion>[first, second]);
    expect(offer.supports(second), isTrue);
    expect(
      () => offer.versions.add(PiProtocolVersion(2, 0, 0)),
      throwsUnsupportedError,
    );
    expect(
      () => PiProtocolOffer(const <PiProtocolVersion>[]),
      throwsArgumentError,
    );
    expect(
      () => PiProtocolOffer(<PiProtocolVersion>[first, first]),
      throwsArgumentError,
    );
  });
}
