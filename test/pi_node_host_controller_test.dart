import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/platform/agent_host/pi_node_host_controller.dart';
import 'package:pi_client/platform/platform_capabilities.dart';
import 'package:pi_client/transport/local_direct_pi_transport.dart';
import 'package:pi_client/transport/pi_transport.dart';

void main() {
  group('LocalProcessPiNodeHostController', () {
    test(
      'passes desktop process configuration to the transport seam',
      () async {
        final configuration = PiNodeDesktopProcessConfiguration(
          nodeExecutable: '/runtime/node',
          serverArguments: const <String>['server', '--stdio'],
          workingDirectory: '/safe/project',
          environment: const <String, String>{'PI_NODE_MODE': 'test'},
        );
        final transport = _TrackingTransport();
        LocalDirectPiProcessConfiguration? launchedConfiguration;
        final controller = LocalProcessPiNodeHostController(
          capabilities: PlatformCapabilities.resolve(
            isWeb: false,
            targetPlatform: TargetPlatform.macOS,
          ),
          configuration: configuration,
          launcher: (value) async {
            launchedConfiguration = value;
            return transport;
          },
        );

        expect(await controller.start(), same(transport));
        expect(await controller.start(), same(transport));
        expect(launchedConfiguration?.executable, '/runtime/node');
        expect(launchedConfiguration?.arguments, const <String>[
          'server',
          '--stdio',
        ]);
        expect(launchedConfiguration?.workingDirectory, '/safe/project');
        expect(launchedConfiguration?.environment['PI_NODE_MODE'], 'test');
        expect(configuration.toString(), isNot(contains('/runtime/node')));

        final firstClose = controller.close();
        final secondClose = controller.close();
        expect(identical(firstClose, secondClose), isTrue);
        await firstClose;
        await secondClose;
        expect(transport.closeCount, 1);
      },
    );

    test('loads bundled process configuration lazily only once', () async {
      final configuration = PiNodeDesktopProcessConfiguration(
        nodeExecutable: '/bundle/Contents/Helpers/PiNode/runtime/bin/node',
        serverArguments: const <String>[
          '/bundle/Contents/Helpers/PiNode/app/dist/stdio-main.js',
        ],
      );
      final transport = _TrackingTransport();
      var configurationLoads = 0;
      final controller = LocalProcessPiNodeHostController.locating(
        capabilities: PlatformCapabilities.resolve(
          isWeb: false,
          targetPlatform: TargetPlatform.macOS,
        ),
        configurationLoader: () async {
          configurationLoads += 1;
          return configuration;
        },
        launcher: (_) async => transport,
      );

      expect(configurationLoads, 0);
      expect(await controller.start(), same(transport));
      expect(await controller.start(), same(transport));
      expect(configurationLoads, 1);
      await controller.close();
    });

    for (final entry in <String, PlatformCapabilities>{
      'Android': PlatformCapabilities.resolve(
        isWeb: false,
        targetPlatform: TargetPlatform.android,
      ),
      'iOS': PlatformCapabilities.resolve(
        isWeb: false,
        targetPlatform: TargetPlatform.iOS,
      ),
      'web': PlatformCapabilities.resolve(
        isWeb: true,
        targetPlatform: TargetPlatform.linux,
      ),
    }.entries) {
      test(
        '${entry.key} rejects local hosting before process launch',
        () async {
          var launchCalled = false;
          final controller = LocalProcessPiNodeHostController(
            capabilities: entry.value,
            configuration: PiNodeDesktopProcessConfiguration(
              nodeExecutable: '/runtime/node',
              serverArguments: const <String>['server'],
            ),
            launcher: (_) async {
              launchCalled = true;
              return _TrackingTransport();
            },
          );

          await expectLater(
            controller.start(),
            throwsA(
              isA<PiNodeHostException>().having(
                (error) => error.code,
                'code',
                PiNodeHostErrorCode.unsupportedPlatform,
              ),
            ),
          );
          expect(launchCalled, isFalse);
          await controller.close();
        },
      );
    }

    test('maps process launch failures to a redacted host error', () async {
      final controller = LocalProcessPiNodeHostController(
        capabilities: PlatformCapabilities.resolve(
          isWeb: false,
          targetPlatform: TargetPlatform.linux,
        ),
        configuration: PiNodeDesktopProcessConfiguration(
          nodeExecutable: '/runtime/node',
          serverArguments: const <String>['server'],
        ),
        launcher: (_) => Future<PiTransport>.error(
          const PiTransportException(PiTransportErrorCode.processStartFailed),
        ),
      );

      await expectLater(
        controller.start(),
        throwsA(
          isA<PiNodeHostException>()
              .having(
                (error) => error.code,
                'code',
                PiNodeHostErrorCode.launchFailed,
              )
              .having(
                (error) => error.toString(),
                'redacted',
                contains('<redacted>'),
              ),
        ),
      );
      await controller.close();
    });
  });
}

final class _TrackingTransport implements PiTransport {
  final StreamController<PiTransportFrame> _incoming =
      StreamController<PiTransportFrame>.broadcast();
  final Completer<void> _done = Completer<void>();
  var closeCount = 0;

  @override
  Stream<PiTransportFrame> get incoming => _incoming.stream;

  @override
  Future<void> get done => _done.future;

  @override
  Future<void> send(PiTransportFrame frame) async {}

  @override
  Future<void> close() async {
    closeCount += 1;
    if (!_incoming.isClosed) await _incoming.close();
    if (!_done.isCompleted) _done.complete();
  }
}
