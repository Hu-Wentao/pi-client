import '../../api/pi_node/pi_node.dart';

enum ExternalTerminalDesktopPlatform { macos, windows, linux }

enum ExternalTerminalLaunchStatus { success, unsupported, failure }

enum ExternalTerminalLaunchCode {
  launched,
  unsupportedPlatform,
  terminalUnavailable,
  launchFailed,
}

final class ExternalTerminalLaunchResult {
  const ExternalTerminalLaunchResult._({
    required this.status,
    required this.code,
  });

  const ExternalTerminalLaunchResult.success()
    : this._(
        status: ExternalTerminalLaunchStatus.success,
        code: ExternalTerminalLaunchCode.launched,
      );

  const ExternalTerminalLaunchResult.unsupportedPlatform()
    : this._(
        status: ExternalTerminalLaunchStatus.unsupported,
        code: ExternalTerminalLaunchCode.unsupportedPlatform,
      );

  const ExternalTerminalLaunchResult.terminalUnavailable()
    : this._(
        status: ExternalTerminalLaunchStatus.unsupported,
        code: ExternalTerminalLaunchCode.terminalUnavailable,
      );

  const ExternalTerminalLaunchResult.failure()
    : this._(
        status: ExternalTerminalLaunchStatus.failure,
        code: ExternalTerminalLaunchCode.launchFailed,
      );

  final ExternalTerminalLaunchStatus status;
  final ExternalTerminalLaunchCode code;

  @override
  String toString() =>
      'ExternalTerminalLaunchResult(status: ${status.name}, code: ${code.name}, details: <redacted>)';
}

abstract interface class ExternalTerminalLauncher {
  bool get isPlatformSupported;

  Future<ExternalTerminalLaunchResult> openTrustedProject(
    PiProjectIdentity projectIdentity,
  );
}

final class UnsupportedExternalTerminalLauncher
    implements ExternalTerminalLauncher {
  const UnsupportedExternalTerminalLauncher();

  @override
  bool get isPlatformSupported => false;

  @override
  Future<ExternalTerminalLaunchResult> openTrustedProject(
    PiProjectIdentity projectIdentity,
  ) async => const ExternalTerminalLaunchResult.unsupportedPlatform();
}
