import '../platform_capabilities.dart';
import 'external_terminal_launcher_stub.dart'
    if (dart.library.io) 'external_terminal_launcher_io.dart'
    as implementation;
import 'external_terminal_launcher_types.dart';

export 'external_terminal_launcher_types.dart';

ExternalTerminalLauncher createPlatformExternalTerminalLauncher({
  PlatformCapabilities? capabilities,
}) {
  final resolved = capabilities ?? PlatformCapabilities.current;
  if (!resolved.isDesktop) {
    return const UnsupportedExternalTerminalLauncher();
  }
  final platform = switch (resolved.platform) {
    PiClientPlatform.macos => ExternalTerminalDesktopPlatform.macos,
    PiClientPlatform.windows => ExternalTerminalDesktopPlatform.windows,
    PiClientPlatform.linux => ExternalTerminalDesktopPlatform.linux,
    PiClientPlatform.android ||
    PiClientPlatform.ios ||
    PiClientPlatform.web => null,
  };
  if (platform == null) return const UnsupportedExternalTerminalLauncher();
  return implementation.createDesktopExternalTerminalLauncher(platform);
}
