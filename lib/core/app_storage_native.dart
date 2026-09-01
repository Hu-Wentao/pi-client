import 'package:fr_storage/fr_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../platform/platform_capabilities.dart';
import 'app_storage_types.dart';

Future<AppStorageBoundary> initializePlatformAppStorage({
  AppDistributionChannel? distributionChannel,
  required bool debugMode,
}) async {
  final capabilities = PlatformCapabilities.current;
  if (capabilities.isDesktop) {
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
    return configuration.usesPlatformSecureStorage
        ? AppStorageBoundary.nativePlatformProtected
        : AppStorageBoundary.nativePublicKeyPreferencesOnly;
  }

  await FrStorage.init();
  return AppStorageBoundary.nativePlatformProtected;
}
