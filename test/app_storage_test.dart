import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/core/app_storage.dart';
import 'package:pi_client/core/app_storage_web.dart' as web_storage;
import 'package:pi_client/platform/platform_capabilities.dart';

void main() {
  group('AppDistributionChannel', () {
    test('parses standard and unsigned preview values', () {
      expect(AppDistributionChannel.parse(''), AppDistributionChannel.standard);
      expect(
        AppDistributionChannel.parse('standard'),
        AppDistributionChannel.standard,
      );
      expect(
        AppDistributionChannel.parse('unsigned-preview'),
        AppDistributionChannel.unsignedPreview,
      );
    });

    test('rejects an unknown distribution channel', () {
      expect(
        () => AppDistributionChannel.parse('preview'),
        throwsArgumentError,
      );
    });
  });

  group('AppStorageBoundary', () {
    test('keeps protected native storage persistent', () {
      expect(
        AppStorageBoundary.nativePlatformProtected.semantics,
        AppStorageSemantics.nativePlatformProtected,
      );
      expect(
        AppStorageBoundary.nativePlatformProtected.persistsAcrossRestarts,
        isTrue,
      );
      expect(
        AppStorageBoundary.nativePlatformProtected.allowsSecretPersistence,
        isTrue,
      );
    });

    test('marks public-key native stores as preferences-only', () {
      expect(
        AppStorageBoundary.nativePublicKeyPreferencesOnly.semantics,
        AppStorageSemantics.nativePublicKeyPreferencesOnly,
      );
      expect(
        AppStorageBoundary
            .nativePublicKeyPreferencesOnly
            .persistsAcrossRestarts,
        isTrue,
      );
      expect(
        AppStorageBoundary
            .nativePublicKeyPreferencesOnly
            .allowsSecretPersistence,
        isFalse,
      );
    });

    test('keeps Web storage no-secret and non-persistent', () async {
      final boundary = await web_storage.initializePlatformAppStorage(
        distributionChannel: AppDistributionChannel.unsignedPreview,
        debugMode: false,
      );

      expect(boundary, same(AppStorageBoundary.webNoSecretNoPersistence));
      expect(boundary.semantics, AppStorageSemantics.webNoSecretNoPersistence);
      expect(boundary.persistsAcrossRestarts, isFalse);
      expect(boundary.allowsSecretPersistence, isFalse);
    });
  });

  group('AppStorageConfiguration', () {
    test('isolates unsigned preview without platform secure storage', () {
      final configuration = AppStorageConfiguration.forRuntime(
        AppDistributionChannel.unsignedPreview,
        debugMode: false,
        platform: PiClientPlatform.macos,
      );

      expect(configuration.directoryName, 'fr_storage_unsigned_preview');
      expect(configuration.usesPlatformSecureStorage, isFalse);
      expect(configuration.createEncryptionKey(), hasLength(32));
    });

    test('keeps standard release on the signed secure-storage path', () {
      final configuration = AppStorageConfiguration.forRuntime(
        AppDistributionChannel.standard,
        debugMode: false,
        platform: PiClientPlatform.macos,
      );

      expect(configuration.directoryName, 'fr_storage');
      expect(configuration.usesPlatformSecureStorage, isTrue);
      expect(configuration.createEncryptionKey(), isNull);
    });

    test('uses a deterministic injected key only for debug storage', () {
      final first = AppStorageConfiguration.forRuntime(
        AppDistributionChannel.standard,
        debugMode: true,
        platform: PiClientPlatform.macos,
      );
      final second = AppStorageConfiguration.forRuntime(
        AppDistributionChannel.standard,
        debugMode: true,
        platform: PiClientPlatform.macos,
      );

      expect(first.usesPlatformSecureStorage, isFalse);
      expect(
        first.createEncryptionKey(),
        orderedEquals(second.createEncryptionKey()!),
      );
      expect(first.createEncryptionKey(), hasLength(32));
    });

    test('keeps other desktop debug builds on platform secure storage', () {
      for (final platform in <PiClientPlatform>[
        PiClientPlatform.windows,
        PiClientPlatform.linux,
      ]) {
        final configuration = AppStorageConfiguration.forRuntime(
          AppDistributionChannel.standard,
          debugMode: true,
          platform: platform,
        );

        expect(configuration.usesPlatformSecureStorage, isTrue);
        expect(configuration.createEncryptionKey(), isNull);
      }
    });

    test('rejects unsigned preview outside macOS', () {
      expect(
        () => AppStorageConfiguration.forRuntime(
          AppDistributionChannel.unsignedPreview,
          debugMode: false,
          platform: PiClientPlatform.windows,
        ),
        throwsUnsupportedError,
      );
    });
  });
}
