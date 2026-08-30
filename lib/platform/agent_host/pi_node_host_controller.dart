import '../../transport/local_direct_pi_transport.dart';
import '../../transport/pi_transport.dart';
import '../platform_capabilities.dart';

enum PiNodeHostErrorCode { unsupportedPlatform, launchFailed, closed }

/// A stable, redacted Pi Node host lifecycle failure.
final class PiNodeHostException implements Exception {
  const PiNodeHostException(this.code);

  final PiNodeHostErrorCode code;

  @override
  String toString() =>
      'PiNodeHostException(code: ${code.name}, details: <redacted>)';
}

/// Desktop-only process inputs owned by the application composition layer.
final class PiNodeDesktopProcessConfiguration {
  factory PiNodeDesktopProcessConfiguration({
    required String nodeExecutable,
    required Iterable<String> serverArguments,
    String? workingDirectory,
    Map<String, String> environment = const <String, String>{},
    bool includeParentEnvironment = true,
    Duration shutdownTimeout = const Duration(seconds: 5),
    int maximumFrameBytes = localDirectDefaultMaximumFrameBytes,
  }) {
    final transportConfiguration = LocalDirectPiProcessConfiguration(
      executable: nodeExecutable,
      arguments: serverArguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      shutdownTimeout: shutdownTimeout,
      maximumFrameBytes: maximumFrameBytes,
    );
    return PiNodeDesktopProcessConfiguration._(transportConfiguration);
  }

  const PiNodeDesktopProcessConfiguration._(this.transportConfiguration);

  final LocalDirectPiProcessConfiguration transportConfiguration;

  @override
  String toString() =>
      'PiNodeDesktopProcessConfiguration(<process details redacted>)';
}

abstract interface class PiNodeHostController {
  Future<PiTransport> start();

  Future<void> close();
}

typedef PiNodeTransportLauncher =
    Future<PiTransport> Function(
      LocalDirectPiProcessConfiguration configuration,
    );

/// Default desktop sidecar controller. It is intentionally not wired into the
/// current production Workspace until the Local Direct end-to-end gates pass.
final class LocalProcessPiNodeHostController implements PiNodeHostController {
  LocalProcessPiNodeHostController({
    required PlatformCapabilities capabilities,
    required PiNodeDesktopProcessConfiguration configuration,
    PiNodeTransportLauncher? launcher,
  }) : _capabilities = capabilities,
       _configuration = configuration,
       _launcher = launcher ?? _launchLocalDirect;

  final PlatformCapabilities _capabilities;
  final PiNodeDesktopProcessConfiguration _configuration;
  final PiNodeTransportLauncher _launcher;
  PiTransport? _transport;
  Future<PiTransport>? _startFuture;
  Future<void>? _closeFuture;
  var _closed = false;

  @override
  Future<PiTransport> start() {
    if (_closed) {
      return Future<PiTransport>.error(
        const PiNodeHostException(PiNodeHostErrorCode.closed),
      );
    }
    if (!_capabilities.supportsAgentHosting) {
      return Future<PiTransport>.error(
        const PiNodeHostException(PiNodeHostErrorCode.unsupportedPlatform),
      );
    }
    final transport = _transport;
    if (transport != null) return Future<PiTransport>.value(transport);
    return _startFuture ??= _start();
  }

  @override
  Future<void> close() => _closeFuture ??= _close();

  Future<PiTransport> _start() async {
    try {
      final transport = await _launcher(_configuration.transportConfiguration);
      if (_closed) {
        await transport.close();
        throw const PiNodeHostException(PiNodeHostErrorCode.closed);
      }
      _transport = transport;
      return transport;
    } on PiNodeHostException {
      rethrow;
    } on PiTransportException catch (error) {
      if (error.code == PiTransportErrorCode.unsupported) {
        throw const PiNodeHostException(
          PiNodeHostErrorCode.unsupportedPlatform,
        );
      }
      throw const PiNodeHostException(PiNodeHostErrorCode.launchFailed);
    } catch (_) {
      throw const PiNodeHostException(PiNodeHostErrorCode.launchFailed);
    }
  }

  Future<void> _close() async {
    _closed = true;
    PiTransport? transport = _transport;
    if (transport == null) {
      try {
        transport = await _startFuture;
      } catch (_) {
        return;
      }
    }
    await transport?.close();
  }
}

Future<PiTransport> _launchLocalDirect(
  LocalDirectPiProcessConfiguration configuration,
) async => LocalDirectPiTransport.start(configuration);
