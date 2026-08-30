import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/transport/pi_transport.dart';

void main() {
  test('represents SemVer without inventing a default protocol release', () {
    expect(PiProtocolVersion(0, 0, 1).toString(), '0.0.1');
    expect(PiProtocolVersion(1, 2, 3), PiProtocolVersion(1, 2, 3));
    expect(() => PiProtocolVersion(-1, 0, 0), throwsArgumentError);
    expect(() => PiProtocolVersion(0, -1, 0), throwsArgumentError);
    expect(() => PiProtocolVersion(0, 0, -1), throwsArgumentError);
  });

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

  test(
    'Local Direct implements transport without central access state',
    () async {
      final transport = _FakeLocalDirectTransport();
      final requestedVersion = PiProtocolVersion(0, 0, 1);
      final connection = await transport.connect(
        protocolVersion: requestedVersion,
      );
      final frame = PiTransportFrame(Uint8List.fromList(<int>[7]));

      await connection.send(frame);

      expect(connection.negotiatedVersion, requestedVersion);
      expect(
        (connection as _FakeLocalDirectConnection).sentFrames,
        <PiTransportFrame>[frame],
      );
    },
  );
}

final class _FakeLocalDirectTransport implements PiTransport {
  @override
  Future<PiTransportConnection> connect({
    required PiProtocolVersion protocolVersion,
  }) async => _FakeLocalDirectConnection(protocolVersion);
}

final class _FakeLocalDirectConnection implements PiTransportConnection {
  _FakeLocalDirectConnection(this.negotiatedVersion);

  @override
  final PiProtocolVersion negotiatedVersion;

  final List<PiTransportFrame> sentFrames = <PiTransportFrame>[];

  @override
  Stream<PiTransportFrame> get incomingFrames => const Stream.empty();

  @override
  Future<void> close() async {}

  @override
  Future<void> send(PiTransportFrame frame) async {
    sentFrames.add(frame);
  }
}
