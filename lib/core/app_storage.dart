import 'package:flutter/foundation.dart';
import 'package:fr_storage/fr_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../platform/platform_capabilities.dart';

enum AppDistributionChannel {
  standard('standard'),
  unsignedPreview('unsigned-preview');

  const AppDistributionChannel(this.value);

  final String value;

  static AppDistributionChannel parse(String value) => switch (value) {
    '' || 'standard' => AppDistributionChannel.standard,
    'unsigned-preview' => AppDistributionChannel.unsignedPreview,
    _ => throw ArgumentError.value(
      value,
      'PI_CLIENT_DISTRIBUTION_CHANNEL',
      'Expected standard or unsigned-preview',
    ),
  };
}

abstract final class AppDistribution {
  static const configuredChannel = String.fromEnvironment(
    'PI_CLIENT_DISTRIBUTION_CHANNEL',
    defaultValue: 'standard',
  );

  static AppDistributionChannel get current =>
      AppDistributionChannel.parse(configuredChannel);
}

@immutable
class AppStorageConfiguration {
  const AppStorageConfiguration({
    required this.directoryName,
    required this.usesPlatformSecureStorage,
    this.encryptionKeyBytes,
  });

  final String directoryName;
  final bool usesPlatformSecureStorage;
  final List<int>? encryptionKeyBytes;

  Uint8List? createEncryptionKey() {
    final bytes = encryptionKeyBytes;
    return bytes == null ? null : Uint8List.fromList(bytes);
  }

  static AppStorageConfiguration forRuntime(
    AppDistributionChannel channel, {
    required bool debugMode,
    required PiClientPlatform platform,
  }) {
    if (channel == AppDistributionChannel.unsignedPreview &&
        platform != PiClientPlatform.macos) {
      throw UnsupportedError(
        'The unsigned-preview distribution channel is macOS-only.',
      );
    }
    final useEmbeddedDebugKey =
        channel == AppDistributionChannel.standard &&
        debugMode &&
        platform == PiClientPlatform.macos;
    return switch (channel) {
      AppDistributionChannel.unsignedPreview => const AppStorageConfiguration(
        directoryName: 'fr_storage_unsigned_preview',
        usesPlatformSecureStorage: false,
        // This key is intentionally public and provides no secrecy. Its
        // purpose is to let the unsigned preview open an isolated
        // preferences store without requiring a Keychain entitlement.
        encryptionKeyBytes: <int>[
          112,
          105,
          45,
          99,
          108,
          105,
          101,
          110,
          116,
          45,
          117,
          110,
          115,
          105,
          103,
          110,
          101,
          100,
          45,
          112,
          114,
          101,
          118,
          105,
          101,
          119,
          45,
          118,
          48,
          50,
          33,
          33,
        ],
      ),
      AppDistributionChannel.standard => AppStorageConfiguration(
        directoryName: 'fr_storage',
        usesPlatformSecureStorage: !useEmbeddedDebugKey,
        encryptionKeyBytes: useEmbeddedDebugKey ? _debugEncryptionKey : null,
      ),
    };
  }

  static const _debugEncryptionKey = <int>[
    25,
    107,
    42,
    210,
    251,
    15,
    114,
    234,
    13,
    222,
    237,
    39,
    154,
    208,
    41,
    193,
    232,
    222,
    10,
    140,
    101,
    39,
    205,
    0,
    125,
    173,
    44,
    86,
    28,
    243,
    74,
    70,
  ];
}

Future<void> initializeAppStorage({
  AppDistributionChannel? distributionChannel,
  bool debugMode = kDebugMode,
}) async {
  final capabilities = PlatformCapabilities.current;
  if (!kIsWeb && capabilities.isDesktop) {
    final supportDirectory = await getApplicationSupportDirectory();
    final configuration = AppStorageConfiguration.forRuntime(
      distributionChannel ?? AppDistribution.current,
      debugMode: debugMode,
      platform: capabilities.platform,
    );
    await FrStorage.init(
      directory: '${supportDirectory.path}/${configuration.directoryName}',
      encryptionKey: configuration.createEncryptionKey(),
    );
    return;
  }
  await FrStorage.init();
}
