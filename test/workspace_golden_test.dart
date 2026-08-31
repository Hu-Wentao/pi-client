import 'dart:async';

import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/app/workspace/workspace.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';

import 'support/fake_pi_node_api.dart';

void main() {
  testWidgets('renders the first-party desktop workspace baseline', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final primary = fakeSession(
      id: 'session-1',
      title: 'Integrate the first-party Pi Node',
      workingDirectory: '/Projects/pi-client',
      isRunning: true,
      updatedAt: DateTime.utc(2026, 8, 29, 9, 30),
    );
    final protocol = fakeSession(
      id: 'session-2',
      title: 'Verify protocol 0.1.0',
      workingDirectory: '/Projects/protocol-lab',
      updatedAt: DateTime.utc(2026, 8, 28, 10),
    );
    final api = FakePiNodeApi(
      sessions: <PiSessionSummary>[primary, protocol],
      details: <PiSessionId, PiSessionDetail>{
        primary.id: fakeDetail(
          primary,
          messages: <PiMessage>[
            fakeMessage(
              id: 'entry-user',
              role: PiMessageRole.user,
              text: 'Connect the Flutter workspace directly to Pi Node.',
              createdAt: DateTime.utc(2026, 8, 29, 8),
            ),
            fakeMessage(
              id: 'entry-assistant',
              role: PiMessageRole.assistant,
              text:
                  'The app-owned PiNodeApi is connected through the typed protocol. Sessions, prompts, ordered events, abort, and authoritative recovery are active.',
              createdAt: DateTime.utc(2026, 8, 29, 8, 1),
            ),
          ],
        ),
      },
    );
    final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        home: FrProvider<WorkspaceViewModel>.value(
          value: viewModel,
          child: const WorkspaceView(),
        ),
      ),
    );
    viewModel.add(const WorkspaceStarted());
    await tester.pumpAndSettle();
    viewModel.add(WorkspaceSessionSelected(primary.id));
    await tester.pump();
    await tester.runAsync(
      () => _waitUntil(
        () =>
            viewModel.state.selectedSessionId == primary.id &&
            !viewModel.state.conversationLoading &&
            viewModel.state.conversationEntries.length == 2,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await expectLater(
      find.byKey(const Key('workspaceScaffold')),
      matchesGoldenFile('goldens/workspace_desktop.png'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    unawaited(viewModel.close());
    unawaited(api.close());
  });
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Golden condition was not met.');
    }
    await Future<void>.delayed(Duration.zero);
  }
}
