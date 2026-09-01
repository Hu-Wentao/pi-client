import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../api/pi_node/pi_node.dart';
import 'workspace.dart';
import 'workspace.srv.dart';

part 'workspace.page.g.dart';

@TypedGoRoute<WorkspacePage>(path: '/')
class WorkspacePage extends GoRouteData with $WorkspacePage {
  const WorkspacePage();

  @override
  Widget build(BuildContext context, GoRouterState state) => FrProvider(
    (context) => WorkspaceViewModel(
      service: WorkspaceService(context.read<PiNodeApi>()),
    ),
    onCreated: (context, vm) => vm.add(const WorkspaceStarted()),
    child: WorkspaceView(piNodeApi: context.read<PiNodeApi>()),
  );
}
