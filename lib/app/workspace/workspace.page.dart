import 'package:dio/dio.dart';
import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_env.dart';
import 'workspace.dart';
import 'workspace.srv.dart';

part 'workspace.page.g.dart';

@TypedGoRoute<WorkspacePage>(path: '/')
class WorkspacePage extends GoRouteData with $WorkspacePage {
  const WorkspacePage();

  @override
  Widget build(BuildContext context, GoRouterState state) => FrProvider(
    (context) => WorkspaceViewModel(
      gateway: PiWebGateway(context.read<Dio>()),
      initialBaseUrl: context.read<AppEnvViewModel>().state.apiBaseUrl,
    ),
    onCreated: (context, vm) => vm.add(const WorkspaceStarted()),
    child: const WorkspaceView(),
  );
}
