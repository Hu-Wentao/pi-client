import 'pi_node_host_controller.dart';

enum PiNodeRuntimeLocationErrorCode {
  unsupportedPlatform,
  bundledCapsuleMissing,
  invalidManifest,
  incompatibleCapsule,
  integrityMismatch,
  developmentFallbackUnavailable,
}

/// A stable, redacted Pi Node runtime-location failure.
final class PiNodeRuntimeLocationException implements Exception {
  const PiNodeRuntimeLocationException(this.code);

  final PiNodeRuntimeLocationErrorCode code;

  @override
  String toString() =>
      'PiNodeRuntimeLocationException(code: ${code.name}, details: <redacted>)';
}

/// Explicit process inputs allowed only for opted-in non-production builds.
final class PiNodeDevelopmentRuntimeConfiguration {
  const PiNodeDevelopmentRuntimeConfiguration({
    required this.nodeExecutable,
    required this.entrypoint,
    required this.workingDirectory,
    required this.agentDirectory,
  });

  final String nodeExecutable;
  final String entrypoint;
  final String workingDirectory;
  final String agentDirectory;
}

abstract interface class PiNodeRuntimeLocator {
  Future<PiNodeDesktopProcessConfiguration> locate();
}
