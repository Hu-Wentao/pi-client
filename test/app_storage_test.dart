import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/core/app_storage.dart';

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

  group('AppStorageConfiguration', () {
    test('isolates unsigned preview without platform secure storage', () {
      final configuration = AppStorageConfiguration.forChannel(
        AppDistributionChannel.unsignedPreview,
        debugMode: false,
      );

      expect(configuration.directoryName, 'fr_storage_unsigned_preview');
      expect(configuration.usesPlatformSecureStorage, isFalse);
      expect(configuration.createEncryptionKey(), hasLength(32));
    });

    test('keeps standard release on the signed secure-storage path', () {
      final configuration = AppStorageConfiguration.forChannel(
        AppDistributionChannel.standard,
        debugMode: false,
      );

      expect(configuration.directoryName, 'fr_storage');
      expect(configuration.usesPlatformSecureStorage, isTrue);
      expect(configuration.createEncryptionKey(), isNull);
    });

    test('uses a deterministic injected key only for debug storage', () {
      final first = AppStorageConfiguration.forChannel(
        AppDistributionChannel.standard,
        debugMode: true,
      );
      final second = AppStorageConfiguration.forChannel(
        AppDistributionChannel.standard,
        debugMode: true,
      );

      expect(first.usesPlatformSecureStorage, isFalse);
      expect(
        first.createEncryptionKey(),
        orderedEquals(second.createEncryptionKey()!),
      );
      expect(first.createEncryptionKey(), hasLength(32));
    });
  });
}
