import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/core/pi_node_composition.dart';
import 'package:pi_client/platform/agent_host/pi_node_host_controller.dart';
import 'package:pi_client/platform/platform_capabilities.dart';
import 'package:pi_client/transport/pi_transport.dart';

import 'support/fake_pi_node_api.dart';

void main() {
  test('starts the desktop host lazily and owns the created API', () async {
    final host = _FakeHostController();
    final delegate = FakePiNodeApi();
    final api = createAppPiNodeApi(
      capabilities: PlatformCapabilities.resolve(
        isWeb: false,
        targetPlatform: TargetPlatform.macOS,
      ),
      hostControllerFactory: () => host,
      clientFactory: (transport) {
        expect(transport, same(host.transport));
        return delegate;
      },
    );

    expect(api, isA<LazyHostedPiNodeApi>());
    expect(
      (api as PiNodeCompositionMetadata).availability,
      PiNodeCompositionAvailability.localHost,
    );
    expect(host.startCalls, 0);
    expect(delegate.connectCalls, 0);

    expect((await api.connect()).status, PiNodeConnectionStatus.connected);
    expect(host.startCalls, 1);
    expect(delegate.connectCalls, 1);
    expect((await api.connect()).status, PiNodeConnectionStatus.connected);
    expect(host.startCalls, 1);

    await api.close();
    expect(delegate.closeCalls, 1);
    expect(host.closeCalls, 1);
  });

  test('recreates the hosted session after a launch failure', () async {
    final failedHost = _FakeHostController(
      startError: const PiNodeHostException(PiNodeHostErrorCode.launchFailed),
    );
    final recoveredHost = _FakeHostController();
    final delegate = FakePiNodeApi();
    var hostFactoryCalls = 0;
    final api = createAppPiNodeApi(
      capabilities: PlatformCapabilities.resolve(
        isWeb: false,
        targetPlatform: TargetPlatform.linux,
      ),
      hostControllerFactory: () => switch (++hostFactoryCalls) {
        1 => failedHost,
        _ => recoveredHost,
      },
      clientFactory: (transport) => delegate,
    );

    await expectLater(
      api.connect(),
      throwsA(
        isA<PiNodeHostException>().having(
          (error) => error.code,
          'code',
          PiNodeHostErrorCode.launchFailed,
        ),
      ),
    );
    expect(api.connection.status, PiNodeConnectionStatus.disconnected);
    expect((await api.connect()).status, PiNodeConnectionStatus.connected);
    expect(hostFactoryCalls, 2);

    await api.close();
  });
}

final class _FakeHostController implements PiNodeHostController {
  _FakeHostController({this.startError});

  final Object? startError;
  final _FakeTransport transport = _FakeTransport();
  int startCalls = 0;
  int closeCalls = 0;

  @override
  Future<PiTransport> start() async {
    startCalls += 1;
    final error = startError;
    if (error != null) throw error;
    return transport;
  }

  @override
  Future<void> close() async {
    closeCalls += 1;
    await transport.close();
  }
}

final class _FakeTransport implements PiTransport {
  final StreamController<PiTransportFrame> _incoming =
      StreamController<PiTransportFrame>.broadcast();
  final Completer<void> _done = Completer<void>();

  @override
  Stream<PiTransportFrame> get incoming => _incoming.stream;

  @override
  Future<void> get done => _done.future;

  @override
  Future<void> send(PiTransportFrame frame) async {}

  @override
  Future<void> close() async {
    if (!_incoming.isClosed) await _incoming.close();
    if (!_done.isCompleted) _done.complete();
  }
}
