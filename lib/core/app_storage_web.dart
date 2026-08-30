import 'app_storage_types.dart';

/// Initializes the Web preference boundary without persistent storage.
///
/// Browser builds retain theme and locale only in app-owned memory for the
/// current page lifetime. Credentials, tokens, prompts, paths, and other
/// sensitive state must remain owned by their authenticated runtime boundary
/// and are never written by this adapter.
Future<AppStorageBoundary> initializePlatformAppStorage({
  AppDistributionChannel? distributionChannel,
  required bool debugMode,
}) async => AppStorageBoundary.webNoSecretNoPersistence;
