import 'dart:async';

import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/app/workspace/workspace.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';

import 'support/fake_pi_node_api.dart';

void main() {
  testWidgets('uses tabbed Workspace composition on a narrow viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = FakePiNodeApi();
    final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

    await tester.pumpWidget(
      MaterialApp(
        home: FrProvider<WorkspaceViewModel>.value(
          value: viewModel,
          child: const WorkspaceView(),
        ),
      ),
    );
    viewModel.add(const WorkspaceStarted());
    await tester.pumpAndSettle();

    expect(find.text('Sessions'), findsWidgets);
    expect(find.text('Conversation'), findsOneWidget);
    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byKey(const Key('nodeConnectionBadge')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    unawaited(viewModel.close());
    unawaited(api.close());
  });

  testWidgets('scrolls typed sessions, selects one, and submits a prompt', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final sessions = List<PiSessionSummary>.generate(
      16,
      (index) => fakeSession(
        id: 's${index + 1}',
        title: 'Widget session ${index + 1}',
        workingDirectory: '/Projects/widget-${index + 1}',
        updatedAt: DateTime.utc(2026, 1, 1, 9, index),
      ),
    );
    final api = FakePiNodeApi(
      sessions: sessions,
      details: <PiSessionId, PiSessionDetail>{
        for (final session in sessions)
          session.id: fakeDetail(
            session,
            messages: <PiMessage>[
              fakeMessage(
                id: 'answer-${session.id.value}',
                role: PiMessageRole.assistant,
                text: 'Existing answer',
              ),
            ],
          ),
      },
    );
    final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

    await tester.pumpWidget(
      MaterialApp(
        home: FrProvider<WorkspaceViewModel>.value(
          value: viewModel,
          child: const WorkspaceView(),
        ),
      ),
    );
    viewModel.add(const WorkspaceStarted());
    await tester.pumpAndSettle();

    expect(find.text('Pi Client'), findsOneWidget);
    expect(find.byKey(const Key('nodeConnectionBadge')), findsWidgets);
    expect(find.text('Widget session 1'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Widget session 16'),
      320,
      scrollable: find.descendant(
        of: find.byKey(const Key('sessionBrowserList')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Widget session 16'), findsOneWidget);

    final targetKey = ValueKey<PiSessionId>(PiSessionId('s16'));
    await tester.ensureVisible(find.byKey(targetKey));
    await tester.tap(find.byKey(targetKey));
    await tester.pump();
    await tester.runAsync(
      () => _waitUntil(
        () =>
            viewModel.state.selectedSessionId == PiSessionId('s16') &&
            !viewModel.state.conversationLoading &&
            viewModel.state.messages.isNotEmpty,
      ),
    );
    await tester.pumpAndSettle();
    expect(viewModel.state.messages.single.text, 'Existing answer');
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText && widget.data == 'Existing answer',
        skipOffstage: false,
      ),
      findsOneWidget,
    );

    expect(viewModel.state.connection.status, PiNodeConnectionStatus.connected);
    expect(
      viewModel.state.sessions
          .firstWhere((session) => session.id == PiSessionId('s16'))
          .isRunning,
      isFalse,
    );
    await tester.enterText(
      find.byKey(const Key('promptComposerField')),
      'Run the focused tests',
    );
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('promptComposerField')))
          .controller
          ?.text,
      'Run the focused tests',
    );
    final sendButton = tester.widget<IconButton>(
      find.byKey(const Key('promptComposerSendButton')),
    );
    expect(sendButton.onPressed, isNotNull);
    sendButton.onPressed!();
    await tester.pump();
    await tester.runAsync(
      () => _waitUntil(
        () =>
            viewModel.state.promptAdmissionStatus ==
            WorkspacePromptAdmissionStatus.accepted,
      ),
    );
    await tester.pump();

    expect(api.lastPrompt?.prompt, 'Run the focused tests');
    expect(viewModel.state.messages.last.role, PiMessageRole.user);
    expect(viewModel.state.messages.last.text, 'Run the focused tests');
    expect(find.byKey(const Key('promptComposerStopButton')), findsOneWidget);

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
      throw TimeoutException('Widget condition was not met.');
    }
    await Future<void>.delayed(Duration.zero);
  }
}
