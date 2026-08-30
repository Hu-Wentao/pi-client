import 'dart:async';

import '../api/pi_node/pi_node.dart';
import '../platform/agent_host/pi_node_host_controller.dart';
import '../platform/platform_capabilities.dart';
import '../protocol/pi_protocol.dart';
import '../transport/pi_transport.dart';
import 'pi_node_runtime_defaults.dart';

enum PiNodeCompositionAvailability {
  localHost,
  externalNode,
  remoteNodeRequired,
  unsupported,
}

enum PiNodeCompositionErrorCode {
  remoteNodeRequired,
  unsupported,
  notConnected,
  closed,
}

final class PiNodeCompositionException implements Exception {
  const PiNodeCompositionException(this.code);

  final PiNodeCompositionErrorCode code;

  @override
  String toString() =>
      'PiNodeCompositionException(code: ${code.name}, details: <redacted>)';
}

abstract interface class PiNodeCompositionMetadata {
  PiNodeCompositionAvailability get availability;
}

typedef PiNodeHostControllerFactory = PiNodeHostController Function();
typedef HostedPiNodeClientFactory = PiNodeApi Function(PiTransport transport);

PiNodeApi createAppPiNodeApi({
  required PlatformCapabilities capabilities,
  PiNodeHostControllerFactory? hostControllerFactory,
  HostedPiNodeClientFactory? clientFactory,
}) {
  if (!capabilities.supportsAgentHosting) {
    final availability = switch (capabilities.platform) {
      PiClientPlatform.android ||
      PiClientPlatform.ios => PiNodeCompositionAvailability.remoteNodeRequired,
      PiClientPlatform.web => PiNodeCompositionAvailability.unsupported,
      PiClientPlatform.macos ||
      PiClientPlatform.windows ||
      PiClientPlatform.linux => PiNodeCompositionAvailability.unsupported,
    };
    return UnavailablePiNodeApi(availability);
  }

  return LazyHostedPiNodeApi(
    hostControllerFactory:
        hostControllerFactory ??
        () => LocalProcessPiNodeHostController(
          capabilities: capabilities,
          configuration: createDefaultPiNodeProcessConfiguration(),
        ),
    clientFactory: clientFactory ?? _createProductionPiNodeClient,
  );
}

final class LazyHostedPiNodeApi
    implements PiNodeApi, PiNodeCompositionMetadata {
  LazyHostedPiNodeApi({
    required PiNodeHostControllerFactory hostControllerFactory,
    required HostedPiNodeClientFactory clientFactory,
  }) : _hostControllerFactory = hostControllerFactory,
       _clientFactory = clientFactory;

  final PiNodeHostControllerFactory _hostControllerFactory;
  final HostedPiNodeClientFactory _clientFactory;
  final StreamController<PiNodeConnectionSnapshot> _connectionStates =
      StreamController<PiNodeConnectionSnapshot>.broadcast(sync: true);

  _HostedPiNodeSession? _session;
  Future<PiNodeConnectionSnapshot>? _connectFuture;
  Future<void>? _closeFuture;
  PiNodeConnectionSnapshot _connection =
      const PiNodeConnectionSnapshot.disconnected();
  int _generation = 0;
  bool _closed = false;

  @override
  PiNodeCompositionAvailability get availability =>
      PiNodeCompositionAvailability.localHost;

  @override
  PiNodeConnectionSnapshot get connection => _connection;

  @override
  Stream<PiNodeConnectionSnapshot> get connectionStates =>
      _connectionStates.stream;

  @override
  Future<PiNodeConnectionSnapshot> connect() {
    if (_closed) {
      return Future<PiNodeConnectionSnapshot>.error(
        const PiNodeCompositionException(PiNodeCompositionErrorCode.closed),
      );
    }
    final session = _session;
    if (session != null &&
        session.api.connection.status == PiNodeConnectionStatus.connected) {
      return Future<PiNodeConnectionSnapshot>.value(session.api.connection);
    }
    final active = _connectFuture;
    if (active != null) return active;

    final future = _connectFresh();
    _connectFuture = future;
    unawaited(
      future.then<void>(
        (_) {
          if (identical(_connectFuture, future)) _connectFuture = null;
        },
        onError: (Object error, StackTrace stackTrace) {
          if (identical(_connectFuture, future)) _connectFuture = null;
        },
      ),
    );
    return future;
  }

  @override
  Future<PiProjectBootstrap> getProjectBootstrap() =>
      _requireConnectedApi().getProjectBootstrap();

  @override
  Future<PiDirectoryListing> browseDirectory(
    PiBrowseDirectoryRequest request,
  ) => _requireConnectedApi().browseDirectory(request);

  @override
  Future<PiProject> validateProject(PiValidateProjectRequest request) =>
      _requireConnectedApi().validateProject(request);

  @override
  Future<List<PiKnownProject>> listKnownProjects({int maxProjects = 24}) =>
      _requireConnectedApi().listKnownProjects(maxProjects: maxProjects);

  @override
  Future<PiProject> approveProjectTrust(PiProjectTrustApproval approval) =>
      _requireConnectedApi().approveProjectTrust(approval);

  @override
  Future<List<PiSessionSummary>> listSessions(PiProjectId projectId) =>
      _requireConnectedApi().listSessions(projectId);

  @override
  Future<PiSessionDetail> getSession(
    PiProjectId projectId,
    PiSessionId sessionId,
  ) => _requireConnectedApi().getSession(projectId, sessionId);

  @override
  Future<PiSessionDetail> createSession(PiCreateSessionRequest request) =>
      _requireConnectedApi().createSession(request);

  @override
  Future<PiCommandResult> prompt(PiPromptCommand command) =>
      _requireConnectedApi().prompt(command);

  @override
  Future<PiCommandResult> abort(PiAbortCommand command) =>
      _requireConnectedApi().abort(command);

  @override
  Stream<PiSessionEvent> sessionEvents(PiSessionId sessionId) {
    try {
      return _requireConnectedApi().sessionEvents(sessionId);
    } catch (error, stackTrace) {
      return Stream<PiSessionEvent>.error(error, stackTrace);
    }
  }

  @override
  Future<void> close() => _closeFuture ??= _close();

  Future<PiNodeConnectionSnapshot> _connectFresh() async {
    final generation = ++_generation;
    await _disposeSession(_session);
    if (_closed || generation != _generation) {
      throw const PiNodeCompositionException(PiNodeCompositionErrorCode.closed);
    }

    _emitConnection(const PiNodeConnectionSnapshot.connecting());
    final host = _hostControllerFactory();
    PiNodeApi? api;
    StreamSubscription<PiNodeConnectionSnapshot>? subscription;
    try {
      final transport = await host.start();
      if (_closed || generation != _generation) {
        await host.close();
        throw const PiNodeCompositionException(
          PiNodeCompositionErrorCode.closed,
        );
      }
      api = _clientFactory(transport);
      subscription = api.connectionStates.listen((snapshot) {
        if (!_closed && generation == _generation) {
          _emitConnection(snapshot);
        }
      });
      final session = _HostedPiNodeSession(
        host: host,
        api: api,
        connectionSubscription: subscription,
      );
      _session = session;
      final connected = await api.connect();
      if (_closed || generation != _generation) {
        await _disposeSession(session);
        throw const PiNodeCompositionException(
          PiNodeCompositionErrorCode.closed,
        );
      }
      _emitConnection(connected);
      return connected;
    } catch (_) {
      final failedSession = _session;
      if (failedSession != null && identical(failedSession.api, api)) {
        await _disposeSession(failedSession);
      } else {
        await subscription?.cancel();
        await api?.close();
        await host.close();
      }
      if (!_closed && generation == _generation) {
        _emitConnection(const PiNodeConnectionSnapshot.disconnected());
      }
      rethrow;
    }
  }

  PiNodeApi _requireConnectedApi() {
    if (_closed) {
      throw const PiNodeCompositionException(PiNodeCompositionErrorCode.closed);
    }
    final api = _session?.api;
    if (api == null ||
        api.connection.status != PiNodeConnectionStatus.connected) {
      throw const PiNodeCompositionException(
        PiNodeCompositionErrorCode.notConnected,
      );
    }
    return api;
  }

  Future<void> _disposeSession(_HostedPiNodeSession? session) async {
    if (session == null) return;
    if (identical(_session, session)) _session = null;
    await session.connectionSubscription.cancel();
    try {
      await session.api.close();
    } finally {
      await session.host.close();
    }
  }

  Future<void> _close() async {
    if (_closed) return;
    _closed = true;
    _generation += 1;
    _emitConnection(const PiNodeConnectionSnapshot.closing());
    final connecting = _connectFuture;
    if (connecting != null) {
      try {
        await connecting;
      } catch (_) {
        // The in-flight session owns its redacted startup failure.
      }
    }
    try {
      await _disposeSession(_session);
    } finally {
      _emitConnection(const PiNodeConnectionSnapshot.closed());
      await _connectionStates.close();
    }
  }

  void _emitConnection(PiNodeConnectionSnapshot snapshot) {
    if (_connection == snapshot) return;
    _connection = snapshot;
    if (!_connectionStates.isClosed) _connectionStates.add(snapshot);
  }
}

final class UnavailablePiNodeApi
    implements PiNodeApi, PiNodeCompositionMetadata {
  UnavailablePiNodeApi(this.availability)
    : assert(
        availability == PiNodeCompositionAvailability.remoteNodeRequired ||
            availability == PiNodeCompositionAvailability.unsupported,
      );

  @override
  final PiNodeCompositionAvailability availability;
  bool _closed = false;

  PiNodeCompositionException get _failure => PiNodeCompositionException(
    _closed
        ? PiNodeCompositionErrorCode.closed
        : availability == PiNodeCompositionAvailability.remoteNodeRequired
        ? PiNodeCompositionErrorCode.remoteNodeRequired
        : PiNodeCompositionErrorCode.unsupported,
  );

  @override
  PiNodeConnectionSnapshot get connection => _closed
      ? const PiNodeConnectionSnapshot.closed()
      : const PiNodeConnectionSnapshot.disconnected();

  @override
  Stream<PiNodeConnectionSnapshot> get connectionStates =>
      const Stream<PiNodeConnectionSnapshot>.empty();

  @override
  Future<PiNodeConnectionSnapshot> connect() =>
      Future<PiNodeConnectionSnapshot>.error(_failure);

  @override
  Future<PiProjectBootstrap> getProjectBootstrap() =>
      Future<PiProjectBootstrap>.error(_failure);

  @override
  Future<PiDirectoryListing> browseDirectory(
    PiBrowseDirectoryRequest request,
  ) => Future<PiDirectoryListing>.error(_failure);

  @override
  Future<PiProject> validateProject(PiValidateProjectRequest request) =>
      Future<PiProject>.error(_failure);

  @override
  Future<List<PiKnownProject>> listKnownProjects({int maxProjects = 24}) =>
      Future<List<PiKnownProject>>.error(_failure);

  @override
  Future<PiProject> approveProjectTrust(PiProjectTrustApproval approval) =>
      Future<PiProject>.error(_failure);

  @override
  Future<List<PiSessionSummary>> listSessions(PiProjectId projectId) =>
      Future<List<PiSessionSummary>>.error(_failure);

  @override
  Future<PiSessionDetail> getSession(
    PiProjectId projectId,
    PiSessionId sessionId,
  ) => Future<PiSessionDetail>.error(_failure);

  @override
  Future<PiSessionDetail> createSession(PiCreateSessionRequest request) =>
      Future<PiSessionDetail>.error(_failure);

  @override
  Future<PiCommandResult> prompt(PiPromptCommand command) =>
      Future<PiCommandResult>.error(_failure);

  @override
  Future<PiCommandResult> abort(PiAbortCommand command) =>
      Future<PiCommandResult>.error(_failure);

  @override
  Stream<PiSessionEvent> sessionEvents(PiSessionId sessionId) =>
      Stream<PiSessionEvent>.error(_failure);

  @override
  Future<void> close() async => _closed = true;
}

final class _HostedPiNodeSession {
  const _HostedPiNodeSession({
    required this.host,
    required this.api,
    required this.connectionSubscription,
  });

  final PiNodeHostController host;
  final PiNodeApi api;
  final StreamSubscription<PiNodeConnectionSnapshot> connectionSubscription;
}

PiNodeApi _createProductionPiNodeClient(PiTransport transport) => PiNodeClient(
  transport: transport,
  codec: ProtobufPiProtocolCodec(
    clientInstanceId:
        'pi-client-${DateTime.now().toUtc().microsecondsSinceEpoch}',
    implementationVersion: const String.fromEnvironment(
      'PI_CLIENT_IMPLEMENTATION_VERSION',
      defaultValue: '0.1.0-dev.0',
    ),
  ),
  protocolOffer: PiProtocolOffer(<PiProtocolVersion>[
    PiProtocolVersion(0, 1, 0),
  ]),
);
