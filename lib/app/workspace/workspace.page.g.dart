// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.page.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$workspacePage];

RouteBase get $workspacePage => GoRouteData.$route(
  path: '/',
  hasOverriddenOnExit: false,
  factory: $WorkspacePage._fromState,
);

mixin $WorkspacePage on GoRouteData {
  static WorkspacePage _fromState(GoRouterState state) => const WorkspacePage();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
