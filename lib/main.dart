import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fr_storage/fr_storage.dart';

import 'app_router.dart';
import 'core/app_locale.dart';
import 'core/app_theme.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeStorage();
  runApp(const AppProviders(child: Application()));
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) => FrView<AppLocaleViewModel, Locale>(
    builder: (context, locale, child) =>
        FrView<AppThemeViewModel, AppThemeModel>(
          builder: (context, theme, child) => MaterialApp.router(
            title: 'Pi Client',
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
            locale: locale.data,
            supportedLocales: locale.vm.all.toList(growable: false),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: theme.data.seedColor,
              ),
              extensions: theme.data.extensions,
            ),
          ),
        ),
  );
}

Future<void> _initializeStorage() async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
    final supportDirectory = await getApplicationSupportDirectory();
    await FrStorage.init(
      directory: '${supportDirectory.path}/fr_storage',
      encryptionKey: kDebugMode
          ? Uint8List.fromList(const <int>[
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
            ])
          : null,
    );
    return;
  }
  await FrStorage.init();
}
