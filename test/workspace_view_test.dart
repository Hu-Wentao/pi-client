import 'dart:async';

import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/app/workspace/workspace.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';
import 'package:pi_client/platform/external_terminal/external_terminal_launcher.dart';

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

  testWidgets('opens Project Trust approval before a restricted session', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final project = fakeProject(
      '/Projects/restricted',
      trustStatus: PiProjectTrustStatus.approvalRequired,
    );
    final session = fakeSession(
      id: 'restricted-session',
      title: 'Restricted session',
      workingDirectory: '/Projects/restricted',
    );
    final api = FakePiNodeApi(
      defaultProject: project,
      sessions: <PiSessionSummary>[session],
      details: <PiSessionId, PiSessionDetail>{session.id: fakeDetail(session)},
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

    await tester.tap(find.byKey(ValueKey<PiSessionId>(session.id)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('projectTrustDialog')), findsOneWidget);
    expect(api.getCalls, 0);

    await tester.tap(find.byKey(const Key('projectTrustApproveButton')));
    await tester.pump();
    await tester.runAsync(
      () => _waitUntil(
        () =>
            api.approveTrustCalls == 1 &&
            api.getCalls == 1 &&
            viewModel.state.selectedSessionId == session.id,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('projectTrustDialog')), findsNothing);
    expect(
      viewModel.state.selectedProject?.trust.status,
      PiProjectTrustStatus.trusted,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    unawaited(viewModel.close());
    unawaited(api.close());
  });

  testWidgets('renames a session through the Workspace action surface', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final session = fakeSession(
      id: 'workspace-admin',
      title: 'Original workspace title',
      workingDirectory: '/Projects/workspace-admin',
    );
    final api = FakePiNodeApi(
      sessions: <PiSessionSummary>[session],
      details: <PiSessionId, PiSessionDetail>{session.id: fakeDetail(session)},
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

    await tester.tap(
      find.byKey(ValueKey<String>('sessionActions-${session.id.value}')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('sessionRenameField')),
      'Renamed from Workspace',
    );
    await tester.tap(find.byKey(const Key('sessionRenameSaveButton')));
    await tester.pump();
    await tester.runAsync(
      () => _waitUntil(
        () =>
            api.renameCalls == 1 &&
            !viewModel.state.sessionAdminLoading &&
            viewModel.state.sessions.single.title == 'Renamed from Workspace',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Renamed from Workspace'), findsOneWidget);
    expect(viewModel.state.sessionAdminError, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    unawaited(viewModel.close());
    unawaited(api.close());
  });

  testWidgets(
    'opens the trusted canonical project from an accessible keyboard action',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final project = fakeProject(r'/Projects/Space & [safe]; $(ignored)');
      final api = FakePiNodeApi(defaultProject: project);
      final launcher = _FakeExternalTerminalLauncher(
        handler: (identity) async =>
            const ExternalTerminalLaunchResult.success(),
      );
      final viewModel = WorkspaceViewModel(service: WorkspaceService(api));
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: FrProvider<WorkspaceViewModel>.value(
            value: viewModel,
            child: WorkspaceView(externalTerminalLauncher: launcher),
          ),
        ),
      );
      viewModel.add(const WorkspaceStarted());
      await tester.pumpAndSettle();

      final button = find.byKey(
        const Key('projectBrowserOpenExternalTerminal'),
      );
      expect(button, findsOneWidget);
      expect(
        find.bySemanticsLabel('Open selected project in an external terminal'),
        findsOneWidget,
      );
      Focus.of(tester.element(find.text('Open in terminal'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(launcher.identities, <PiProjectIdentity>[project.identity]);
      expect(
        find.text('Project opened in an external terminal.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      unawaited(viewModel.close());
      unawaited(api.close());
    },
  );

  testWidgets('does not offer external terminal for an untrusted project', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final project = fakeProject(
      '/Projects/restricted',
      trustStatus: PiProjectTrustStatus.approvalRequired,
    );
    final api = FakePiNodeApi(defaultProject: project);
    final launcher = _FakeExternalTerminalLauncher();
    final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

    await tester.pumpWidget(
      MaterialApp(
        home: FrProvider<WorkspaceViewModel>.value(
          value: viewModel,
          child: WorkspaceView(externalTerminalLauncher: launcher),
        ),
      ),
    );
    viewModel.add(const WorkspaceStarted());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('projectBrowserOpenExternalTerminal')),
      findsNothing,
    );
    expect(launcher.identities, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    unawaited(viewModel.close());
    unawaited(api.close());
  });

  for (final testCase
      in <({ExternalTerminalLaunchResult result, String message})>[
        (
          result: const ExternalTerminalLaunchResult.failure(),
          message: 'The external terminal could not be opened.',
        ),
        (
          result: const ExternalTerminalLaunchResult.terminalUnavailable(),
          message: 'No supported external terminal is available.',
        ),
      ]) {
    testWidgets(
      'shows redacted ${testCase.result.status.name} external-terminal feedback',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final project = fakeProject('/Projects/private-visible-identity');
        final api = FakePiNodeApi(defaultProject: project);
        final launcher = _FakeExternalTerminalLauncher(
          handler: (identity) async => testCase.result,
        );
        final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

        await tester.pumpWidget(
          MaterialApp(
            home: FrProvider<WorkspaceViewModel>.value(
              value: viewModel,
              child: WorkspaceView(externalTerminalLauncher: launcher),
            ),
          ),
        );
        viewModel.add(const WorkspaceStarted());
        await tester.pumpAndSettle();

        final button = find.byKey(
          const Key('projectBrowserOpenExternalTerminal'),
        );
        await tester.ensureVisible(button);
        await tester.pump();
        await tester.tap(button);
        await tester.pumpAndSettle();

        expect(find.text(testCase.message), findsOneWidget);
        final feedback = tester.widget<Text>(find.text(testCase.message)).data!;
        expect(
          feedback,
          isNot(contains(project.identity.canonicalWorkingDirectory)),
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        unawaited(viewModel.close());
        unawaited(api.close());
      },
    );
  }

  testWidgets('suppresses an external-terminal result after project switch', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final firstProject = fakeProject('/Projects/first');
    final secondProject = fakeProject('/Projects/second');
    final completion = Completer<ExternalTerminalLaunchResult>();
    final api = FakePiNodeApi(defaultProject: firstProject);
    final launcher = _FakeExternalTerminalLauncher(
      handler: (identity) => completion.future,
    );
    final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

    await tester.pumpWidget(
      MaterialApp(
        home: FrProvider<WorkspaceViewModel>.value(
          value: viewModel,
          child: WorkspaceView(externalTerminalLauncher: launcher),
        ),
      ),
    );
    viewModel.add(const WorkspaceStarted());
    await tester.pumpAndSettle();

    final externalTerminalButton = find.byKey(
      const Key('projectBrowserOpenExternalTerminal'),
    );
    await tester.ensureVisible(externalTerminalButton);
    await tester.pump();
    await tester.tap(externalTerminalButton);
    await tester.pump();
    expect(launcher.identities.single, firstProject.identity);

    viewModel.add(WorkspaceProjectSelected(secondProject));
    await tester.runAsync(
      () => _waitUntil(
        () =>
            viewModel.state.selectedProject?.identity.projectId ==
            secondProject.identity.projectId,
      ),
    );
    await tester.pump();
    viewModel.add(WorkspaceProjectSelected(firstProject));
    await tester.runAsync(
      () => _waitUntil(
        () =>
            viewModel.state.selectedProject?.identity.projectId ==
            firstProject.identity.projectId,
      ),
    );
    await tester.pump();
    completion.complete(const ExternalTerminalLaunchResult.success());
    await tester.pumpAndSettle();

    expect(find.text('Project opened in an external terminal.'), findsNothing);

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
            viewModel.state.conversationEntries.isNotEmpty,
      ),
    );
    await tester.pumpAndSettle();
    expect(viewModel.state.messages.single.text, 'Existing answer');
    expect(
      find.byKey(
        const ValueKey<String>('conversation-entry-answer-s16'),
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.text('Existing answer', skipOffstage: false), findsWidgets);

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
    final optimisticEntry = viewModel.state.conversationEntries.last;
    expect(optimisticEntry, isA<PiUserConversationEntry>());
    expect(
      (optimisticEntry.parts.single as PiTextConversationPart).text,
      'Run the focused tests',
    );
    expect(find.byKey(const Key('promptComposerStopButton')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    unawaited(viewModel.close());
    unawaited(api.close());
  });
}

final class _FakeExternalTerminalLauncher implements ExternalTerminalLauncher {
  _FakeExternalTerminalLauncher({this.handler});

  @override
  bool get isPlatformSupported => true;
  final Future<ExternalTerminalLaunchResult> Function(
    PiProjectIdentity identity,
  )?
  handler;
  final List<PiProjectIdentity> identities = <PiProjectIdentity>[];

  @override
  Future<ExternalTerminalLaunchResult> openTrustedProject(
    PiProjectIdentity projectIdentity,
  ) {
    identities.add(projectIdentity);
    return handler?.call(projectIdentity) ??
        Future<ExternalTerminalLaunchResult>.value(
          const ExternalTerminalLaunchResult.success(),
        );
  }
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
