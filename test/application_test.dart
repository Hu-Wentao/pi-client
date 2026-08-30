import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/app_router.dart';
import 'package:pi_client/core/providers.dart';
import 'package:pi_client/main.dart' show Application;
import 'package:pi_client/platform/platform_capabilities.dart';

import 'support/fake_pi_node_api.dart';

void main() {
  test('keeps WorkspacePage as the typed root route', () {
    expect(const WorkspacePage().location, '/');
    expect(appRouter.routeInformationProvider.value.uri.path, '/');
  });

  testWidgets('builds the routed Pi Client application with PiNodeApi', (
    tester,
  ) async {
    final api = FakePiNodeApi();

    await tester.pumpWidget(
      AppProviders(piNodeApi: api, child: const Application()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pi Client'), findsOneWidget);
    expect(find.byKey(const Key('nodeConnectionBadge')), findsWidgets);
    expect(find.text('No sessions yet'), findsOneWidget);
    expect(api.connectCalls, 1);
    expect(api.listCalls, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(api.closeCalls, 0);
    await api.close();
  });

  testWidgets('preserves an externally injected PiNodeApi owner', (
    tester,
  ) async {
    final api = FakePiNodeApi();
    late PiNodeApi resolvedApi;

    await tester.pumpWidget(
      AppProviders(
        piNodeApi: api,
        child: _RuntimeProbe(
          onMount: (context) => resolvedApi = context.read<PiNodeApi>(),
        ),
      ),
    );
    expect(resolvedApi, same(api));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(api.closeCalls, 0);
    await api.close();
  });

  testWidgets('closes an app-owned PiNodeApi created by the factory', (
    tester,
  ) async {
    final api = FakePiNodeApi();

    await tester.pumpWidget(
      AppProviders(
        piNodeApiFactory: (capabilities) => api,
        child: _RuntimeProbe(onMount: (context) => context.read<PiNodeApi>()),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(api.closeCalls, 1);
  });

  testWidgets('provides the injected platform capabilities', (tester) async {
    final capabilities = PlatformCapabilities.resolve(
      isWeb: false,
      targetPlatform: TargetPlatform.android,
    );
    final api = FakePiNodeApi();
    late PlatformCapabilities resolvedCapabilities;

    await tester.pumpWidget(
      AppProviders(
        piNodeApi: api,
        platformCapabilities: capabilities,
        child: _RuntimeProbe(
          onMount: (context) =>
              resolvedCapabilities = context.read<PlatformCapabilities>(),
        ),
      ),
    );

    expect(resolvedCapabilities, same(capabilities));
    expect(resolvedCapabilities.isRemoteClientOnly, isTrue);
    await api.close();
  });

  testWidgets('shows an explicit remote-node-required state on Android', (
    tester,
  ) async {
    final capabilities = PlatformCapabilities.resolve(
      isWeb: false,
      targetPlatform: TargetPlatform.android,
    );

    await tester.pumpWidget(
      AppProviders(
        platformCapabilities: capabilities,
        child: const Application(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Remote Pi Node required'), findsOneWidget);
    expect(find.textContaining('requires a remote Pi Node'), findsOneWidget);
    expect(find.byKey(const Key('nodeConnectionPrimaryAction')), findsNothing);
  });
}

class _RuntimeProbe extends StatefulWidget {
  const _RuntimeProbe({required this.onMount});

  final ValueChanged<BuildContext> onMount;

  @override
  State<_RuntimeProbe> createState() => _RuntimeProbeState();
}

class _RuntimeProbeState extends State<_RuntimeProbe> {
  var _mountedRuntime = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mountedRuntime) return;
    _mountedRuntime = true;
    widget.onMount(context);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
