import 'package:go_router/go_router.dart';

import 'app/workspace/workspace.page.dart' as workspace;

export 'app/workspace/workspace.page.dart' hide $appRoutes;

final appRouter = GoRouter(routes: [...workspace.$appRoutes]);
