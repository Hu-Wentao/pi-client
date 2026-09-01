import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/transport/local_direct_pi_transport.dart';
import 'package:pi_client/transport/pi_transport.dart';

void main() {
  group('LocalDirectPiTransport', () {
    test('serializes framed writes and drains bounded stderr', () async {
      final transport = await _startFixture('echo');
      addTearDown(transport.close);
      final framesFuture = transport.incoming.take(24).toList();
      final payloads = List<Uint8List>.generate(
        24,
        (index) => Uint8List.fromList(<int>[
          index + 1,
          ...List<int>.filled(256, index),
        ]),
      );

      await Future.wait<void>(
        payloads.map((payload) => transport.send(PiTransportFrame(payload))),
      );
      final frames = await framesFuture;

      expect(
        frames.map((frame) => frame.bytes.toList()).toList(),
        payloads.map((payload) => payload.toList()).toList(),
      );
      final firstClose = transport.close();
      final secondClose = transport.close();
      expect(identical(firstClose, secondClose), isTrue);
      await firstClose;
      await secondClose;
      await transport.done;
      await expectLater(
        transport.send(PiTransportFrame(Uint8List.fromList(<int>[1]))),
        throwsA(_transportError(PiTransportErrorCode.closed)),
      );
    });

    test('fails closed on malformed process framing', () async {
      final transport = await _startFixture('malformed');
      addTearDown(transport.close);
      final incomingFailure = expectLater(
        transport.incoming,
        emitsError(_transportError(PiTransportErrorCode.invalidFraming)),
      );
      final doneFailure = expectLater(
        transport.done,
        throwsA(_transportError(PiTransportErrorCode.invalidFraming)),
      );

      await incomingFailure;
      await doneFailure;
      await transport.close();
    });

    test(
      'reports an unexpected process exit without exposing stderr',
      () async {
        final transport = await _startFixture('exit');
        addTearDown(transport.close);
        final incomingFailure = expectLater(
          transport.incoming,
          emitsError(_transportError(PiTransportErrorCode.processExited)),
        );
        final doneFailure = expectLater(
          transport.done,
          throwsA(_transportError(PiTransportErrorCode.processExited)),
        );

        await incomingFailure;
        await doneFailure;
        expect(
          const PiTransportException(
            PiTransportErrorCode.processExited,
          ).toString(),
          isNot(contains('bounded fixture exit')),
        );
        await transport.close();
      },
    );

    test('returns a typed redacted process-start failure', () async {
      final configuration = LocalDirectPiProcessConfiguration(
        executable: '${Directory.systemTemp.path}/missing-pi-node-executable',
        arguments: const <String>['server'],
      );

      await expectLater(
        LocalDirectPiTransport.start(configuration),
        throwsA(_transportError(PiTransportErrorCode.processStartFailed)),
      );
      expect(configuration.toString(), isNot(contains('missing-pi-node')));
    });
  });
}

Future<LocalDirectPiTransport> _startFixture(String mode) =>
    LocalDirectPiTransport.start(
      LocalDirectPiProcessConfiguration(
        executable: _dartExecutable(),
        arguments: <String>[_fixturePath(), mode],
        shutdownTimeout: const Duration(seconds: 2),
      ),
    );

String _fixturePath() => File.fromUri(
  Directory.current.uri.resolve(
    'test/fixtures/local_direct_process_fixture.dart',
  ),
).path;

String _dartExecutable() {
  final executableName = Platform.isWindows ? 'dart.exe' : 'dart';
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final candidate = File(
      '$flutterRoot/bin/cache/dart-sdk/bin/$executableName',
    );
    if (candidate.existsSync()) return candidate.path;
  }

  var directory = File(Platform.resolvedExecutable).parent;
  for (var depth = 0; depth < 10; depth += 1) {
    final candidate = File('${directory.path}/dart-sdk/bin/$executableName');
    if (candidate.existsSync()) return candidate.path;
    directory = directory.parent;
  }
  throw StateError('Unable to resolve the bounded Dart fixture executable.');
}

Matcher _transportError(PiTransportErrorCode code) =>
    isA<PiTransportException>()
        .having((error) => error.code, 'code', code)
        .having(
          (error) => error.toString(),
          'redacted',
          contains('<redacted>'),
        );
