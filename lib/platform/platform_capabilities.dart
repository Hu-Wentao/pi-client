import 'package:flutter/foundation.dart';

enum PiClientPlatform { android, ios, macos, windows, linux, web }

enum PiClientExecutionRole { agentHostCapable, remoteClientOnly }

@immutable
final class PlatformCapabilities {
  const PlatformCapabilities._({
    required this.platform,
    required this.executionRole,
  });

  final PiClientPlatform platform;
  final PiClientExecutionRole executionRole;

  bool get canConnectToAgentHost => true;

  bool get isDesktop => switch (platform) {
    PiClientPlatform.macos ||
    PiClientPlatform.windows ||
    PiClientPlatform.linux => true,
    PiClientPlatform.android ||
    PiClientPlatform.ios ||
    PiClientPlatform.web => false,
  };

  bool get supportsPiSdkHosting =>
      executionRole == PiClientExecutionRole.agentHostCapable;

  bool get supportsAgentHosting => supportsPiSdkHosting;

  bool get isRemoteClientOnly =>
      executionRole == PiClientExecutionRole.remoteClientOnly;

  static PlatformCapabilities get current =>
      resolve(isWeb: kIsWeb, targetPlatform: defaultTargetPlatform);

  static PlatformCapabilities resolve({
    required bool isWeb,
    required TargetPlatform targetPlatform,
  }) {
    if (isWeb) {
      return const PlatformCapabilities._(
        platform: PiClientPlatform.web,
        executionRole: PiClientExecutionRole.remoteClientOnly,
      );
    }

    return switch (targetPlatform) {
      TargetPlatform.android => const PlatformCapabilities._(
        platform: PiClientPlatform.android,
        executionRole: PiClientExecutionRole.remoteClientOnly,
      ),
      TargetPlatform.iOS => const PlatformCapabilities._(
        platform: PiClientPlatform.ios,
        executionRole: PiClientExecutionRole.remoteClientOnly,
      ),
      TargetPlatform.macOS => const PlatformCapabilities._(
        platform: PiClientPlatform.macos,
        executionRole: PiClientExecutionRole.agentHostCapable,
      ),
      TargetPlatform.windows => const PlatformCapabilities._(
        platform: PiClientPlatform.windows,
        executionRole: PiClientExecutionRole.agentHostCapable,
      ),
      TargetPlatform.linux => const PlatformCapabilities._(
        platform: PiClientPlatform.linux,
        executionRole: PiClientExecutionRole.agentHostCapable,
      ),
      TargetPlatform.fuchsia => throw UnsupportedError(
        'Pi Client does not target Fuchsia.',
      ),
    };
  }
}
