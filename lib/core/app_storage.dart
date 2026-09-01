import 'package:flutter/foundation.dart';

import 'app_storage_native.dart'
    if (dart.library.js_interop) 'app_storage_web.dart'
    as platform_storage;
import 'app_storage_types.dart';

export 'app_storage_types.dart';

Future<AppStorageBoundary> initializeAppStorage({
  AppDistributionChannel? distributionChannel,
  bool debugMode = kDebugMode,
}) => platform_storage.initializePlatformAppStorage(
  distributionChannel: distributionChannel,
  debugMode: debugMode,
);
