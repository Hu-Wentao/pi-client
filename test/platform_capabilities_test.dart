import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/platform/platform_capabilities.dart';

void main() {
  group('PlatformCapabilities', () {
    for (final entry in <TargetPlatform, PiClientPlatform>{
      TargetPlatform.macOS: PiClientPlatform.macos,
      TargetPlatform.windows: PiClientPlatform.windows,
      TargetPlatform.linux: PiClientPlatform.linux,
    }.entries) {
      test('${entry.value.name} can connect and host an agent', () {
        final capabilities = PlatformCapabilities.resolve(
          isWeb: false,
          targetPlatform: entry.key,
        );

        expect(capabilities.platform, entry.value);
        expect(capabilities.canConnectToAgentHost, isTrue);
        expect(capabilities.isDesktop, isTrue);
        expect(capabilities.supportsPiSdkHosting, isTrue);
        expect(capabilities.supportsAgentHosting, isTrue);
        expect(capabilities.isRemoteClientOnly, isFalse);
      });
    }

    for (final entry in <TargetPlatform, PiClientPlatform>{
      TargetPlatform.android: PiClientPlatform.android,
      TargetPlatform.iOS: PiClientPlatform.ios,
    }.entries) {
      test('${entry.value.name} is a connect-only client', () {
        final capabilities = PlatformCapabilities.resolve(
          isWeb: false,
          targetPlatform: entry.key,
        );

        expect(capabilities.platform, entry.value);
        expect(capabilities.canConnectToAgentHost, isTrue);
        expect(capabilities.isDesktop, isFalse);
        expect(capabilities.supportsPiSdkHosting, isFalse);
        expect(capabilities.supportsAgentHosting, isFalse);
        expect(capabilities.isRemoteClientOnly, isTrue);
      });
    }

    test('web is connect-only regardless of the reported target platform', () {
      final capabilities = PlatformCapabilities.resolve(
        isWeb: true,
        targetPlatform: TargetPlatform.linux,
      );

      expect(capabilities.platform, PiClientPlatform.web);
      expect(capabilities.canConnectToAgentHost, isTrue);
      expect(capabilities.isDesktop, isFalse);
      expect(capabilities.supportsPiSdkHosting, isFalse);
      expect(capabilities.supportsAgentHosting, isFalse);
      expect(capabilities.isRemoteClientOnly, isTrue);
    });

    test('Fuchsia is outside the supported platform matrix', () {
      expect(
        () => PlatformCapabilities.resolve(
          isWeb: false,
          targetPlatform: TargetPlatform.fuchsia,
        ),
        throwsUnsupportedError,
      );
    });
  });
}
