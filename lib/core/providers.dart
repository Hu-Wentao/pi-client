import 'dart:async';

import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/widgets.dart';

import '../api/pi_node/pi_node.dart';
import '../platform/platform_capabilities.dart';
import 'app_locale.dart';
import 'app_theme.dart';
import 'pi_node_composition.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({
    required this.child,
    this.piNodeApi,
    this.platformCapabilities,
    this.piNodeApiFactory,
    super.key,
  });

  final Widget child;

  /// An externally owned Pi Node API. AppProviders exposes but never closes it.
  final PiNodeApi? piNodeApi;
  final PlatformCapabilities? platformCapabilities;
  final PiNodeApi Function(PlatformCapabilities capabilities)? piNodeApiFactory;

  @override
  Widget build(BuildContext context) {
    final capabilities = platformCapabilities ?? PlatformCapabilities.current;
    return FrProvider<PlatformCapabilities>.value(
      value: capabilities,
      child: FrProvider.multi(
        [
          FrProvider((context) => AppLocaleViewModel()),
          FrProvider((context) => AppThemeViewModel()),
        ],
        child: _PiNodeApiScope(
          capabilities: capabilities,
          externalApi: piNodeApi,
          factory: piNodeApiFactory,
          child: child,
        ),
      ),
    );
  }
}

class _PiNodeApiScope extends StatelessWidget {
  const _PiNodeApiScope({
    required this.capabilities,
    required this.child,
    this.externalApi,
    this.factory,
  });

  final PlatformCapabilities capabilities;
  final Widget child;
  final PiNodeApi? externalApi;
  final PiNodeApi Function(PlatformCapabilities capabilities)? factory;

  @override
  Widget build(BuildContext context) {
    final api = externalApi;
    if (api != null) {
      return FrProvider<PiNodeApi>.value(value: api, child: child);
    }
    return FrProvider<PiNodeApi>(
      (context) =>
          factory?.call(capabilities) ??
          createAppPiNodeApi(capabilities: capabilities),
      dispose: (context, api) => unawaited(api.close()),
      child: child,
    );
  }
}
