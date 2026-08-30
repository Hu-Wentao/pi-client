import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/app/workspace/workspace.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';

import 'support/fake_pi_node_api.dart';

void main() {
  test(
    'connects, loads typed sessions, streams output, aborts, and reconciles completion',
    () async {
      final session = fakeSession(
        id: 's1',
        title: 'Test session',
        workingDirectory: '/Projects/test-session',
      );
      final history = fakeDetail(
        session,
        messages: <PiMessage>[
          fakeMessage(
            id: 'history-1',
            role: PiMessageRole.assistant,
            text: 'Hello from history',
          ),
        ],
      );
      final api = FakePiNodeApi(
        sessions: <PiSessionSummary>[session],
        details: <PiSessionId, PiSessionDetail>{session.id: history},
      );
      final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

      viewModel.add(const WorkspaceStarted());
      await _waitFor(
        viewModel,
        (state) =>
            state.connection.status == PiNodeConnectionStatus.connected &&
            !state.sessionsLoading,
      );
      expect(viewModel.state.sessions.single, session);
      final serializedKeys = viewModel.state.toJson().keys;
      expect(serializedKeys, isNot(contains('connection')));
      expect(serializedKeys, isNot(contains('sessions')));
      expect(serializedKeys, isNot(contains('selectedSessionId')));
      expect(serializedKeys, isNot(contains('messages')));

      viewModel.add(WorkspaceSessionSelected(session.id));
      await _waitFor(
        viewModel,
        (state) =>
            state.selectedSessionId == session.id &&
            !state.conversationLoading &&
            state.eventStatus == WorkspaceEventStatus.listening,
      );
      expect(viewModel.state.messages.single.text, 'Hello from history');

      viewModel.add(const WorkspacePromptSubmitted('Inspect the project'));
      await _waitFor(
        viewModel,
        (state) =>
            state.promptAdmissionStatus ==
            WorkspacePromptAdmissionStatus.accepted,
      );
      expect(api.lastPrompt?.prompt, 'Inspect the project');
      expect(viewModel.state.messages.last.text, 'Inspect the project');
      expect(viewModel.state.sessions.single.isRunning, isTrue);

      final commandId = api.lastPrompt!.commandId;
      api.emitEvent(
        PiSessionMessageAddedEvent(
          sessionId: session.id,
          sequence: 1,
          message: fakeMessage(
            id: 'assistant-live',
            role: PiMessageRole.assistant,
            text: 'Working',
            isStreaming: true,
          ),
        ),
      );
      api.emitEvent(
        PiSessionMessageDeltaEvent(
          sessionId: session.id,
          sequence: 2,
          messageId: PiMessageId('assistant-live'),
          delta: ' now',
        ),
      );
      await _waitFor(
        viewModel,
        (state) => state.messages.any(
          (message) =>
              message.id == PiMessageId('assistant-live') &&
              message.text == 'Working now',
        ),
      );

      viewModel.add(const WorkspaceAgentStopped());
      await _waitUntil(() => api.abortCalls == 1);
      expect(api.lastAbort?.sessionId, session.id);

      final settledSession = fakeSession(
        id: 's1',
        title: 'Test session',
        workingDirectory: '/Projects/test-session',
        updatedAt: DateTime.utc(2026, 1, 1, 10),
      );
      api.updateDetail(
        fakeDetail(
          settledSession,
          messages: <PiMessage>[
            fakeMessage(
              id: 'prompt-user',
              role: PiMessageRole.user,
              text: 'Inspect the project',
            ),
            fakeMessage(
              id: 'prompt-answer',
              role: PiMessageRole.assistant,
              text: 'Final answer',
            ),
          ],
        ),
      );
      api.emitEvent(
        PiSessionRunningChangedEvent(
          sessionId: session.id,
          sequence: 3,
          isRunning: false,
        ),
      );
      api.emitEvent(
        PiSessionCommandCompletedEvent(
          sessionId: session.id,
          sequence: 4,
          commandId: commandId,
          succeeded: true,
        ),
      );
      await _waitFor(
        viewModel,
        (state) =>
            !state.conversationLoading &&
            state.messages.last.text == 'Final answer',
      );
      expect(viewModel.state.sessions.single.isRunning, isFalse);

      await viewModel.close();
      expect(api.closeCalls, 0);
      await api.close();
    },
  );

  test('removes an optimistic prompt only for definitive rejection', () async {
    final session = fakeSession(
      id: 'rejected-session',
      title: 'Rejected session',
      workingDirectory: '/Projects/rejected',
    );
    final api =
        FakePiNodeApi(
            sessions: <PiSessionSummary>[session],
            details: <PiSessionId, PiSessionDetail>{
              session.id: fakeDetail(session),
            },
          )
          ..promptHandler = (command) async => PiCommandRejected(
            command.commandId,
            const PiNodeException(
              PiNodeErrorCode.invalidRequest,
              retryable: false,
            ),
          );
    final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

    viewModel.add(const WorkspaceStarted());
    await _waitFor(
      viewModel,
      (state) => state.connection.status == PiNodeConnectionStatus.connected,
    );
    viewModel.add(WorkspaceSessionSelected(session.id));
    await _waitFor(
      viewModel,
      (state) =>
          state.selectedSessionId == session.id && !state.conversationLoading,
    );
    viewModel.add(const WorkspacePromptSubmitted('Reject this prompt'));
    await _waitFor(
      viewModel,
      (state) =>
          state.promptAdmissionStatus ==
          WorkspacePromptAdmissionStatus.rejected,
    );

    expect(
      viewModel.state.messages.where(
        (message) => message.text == 'Reject this prompt',
      ),
      isEmpty,
    );
    expect(viewModel.state.promptError, isNotNull);

    await viewModel.close();
    await api.close();
  });

  test('retains the optimistic prompt when admission is uncertain', () async {
    final session = fakeSession(
      id: 'uncertain-session',
      title: 'Uncertain session',
      workingDirectory: '/Projects/uncertain',
    );
    final api =
        FakePiNodeApi(
            sessions: <PiSessionSummary>[session],
            details: <PiSessionId, PiSessionDetail>{
              session.id: fakeDetail(session),
            },
          )
          ..promptHandler = (command) async => PiCommandUncertain(
            command.commandId,
            const PiNodeException(
              PiNodeErrorCode.disconnected,
              retryable: true,
            ),
          );
    final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

    viewModel.add(const WorkspaceStarted());
    await _waitFor(
      viewModel,
      (state) => state.connection.status == PiNodeConnectionStatus.connected,
    );
    viewModel.add(WorkspaceSessionSelected(session.id));
    await _waitFor(
      viewModel,
      (state) =>
          state.selectedSessionId == session.id && !state.conversationLoading,
    );
    viewModel.add(const WorkspacePromptSubmitted('Maybe accepted'));
    await _waitFor(
      viewModel,
      (state) =>
          state.promptAdmissionStatus ==
          WorkspacePromptAdmissionStatus.uncertain,
    );

    expect(viewModel.state.messages.last.text, 'Maybe accepted');
    expect(viewModel.state.sessions.single.isRunning, isTrue);
    expect(viewModel.state.promptError, contains('uncertain'));

    await viewModel.close();
    await api.close();
  });

  test(
    'reloads authoritative session state after an event sequence gap',
    () async {
      final session = fakeSession(
        id: 'gap-session',
        title: 'Gap session',
        workingDirectory: '/Projects/gap',
      );
      final api = FakePiNodeApi(
        sessions: <PiSessionSummary>[session],
        details: <PiSessionId, PiSessionDetail>{
          session.id: fakeDetail(
            session,
            messages: <PiMessage>[
              fakeMessage(
                id: 'before-gap',
                role: PiMessageRole.assistant,
                text: 'Before gap',
              ),
            ],
          ),
        },
      );
      final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

      viewModel.add(const WorkspaceStarted());
      await _waitFor(
        viewModel,
        (state) => state.connection.status == PiNodeConnectionStatus.connected,
      );
      viewModel.add(WorkspaceSessionSelected(session.id));
      await _waitFor(
        viewModel,
        (state) => state.eventStatus == WorkspaceEventStatus.listening,
      );
      final getCallsBeforeGap = api.getCalls;
      api.updateDetail(
        fakeDetail(
          session,
          messages: <PiMessage>[
            fakeMessage(
              id: 'after-gap',
              role: PiMessageRole.assistant,
              text: 'Authoritative answer',
            ),
          ],
        ),
      );
      api.emitEvent(
        PiSessionSequenceGapEvent(
          sessionId: session.id,
          expectedSequence: 1,
          receivedSequence: 3,
        ),
      );

      await _waitFor(
        viewModel,
        (state) =>
            api.getCalls > getCallsBeforeGap &&
            state.eventStatus == WorkspaceEventStatus.listening &&
            state.messages.single.text == 'Authoritative answer',
      );

      await viewModel.close();
      await api.close();
    },
  );

  test(
    'validates a manual project path before switching session scope',
    () async {
      final defaultProject = fakeProject('/Projects/default');
      final validatedProject = fakeProject('/Projects/canonical-manual');
      final api = FakePiNodeApi(defaultProject: defaultProject)
        ..validateProjectHandler = (request) async {
          expect(request.candidateDirectory, '/Projects/manual-alias');
          return validatedProject;
        };
      final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

      viewModel.add(const WorkspaceStarted());
      await _waitFor(
        viewModel,
        (state) =>
            state.connection.status == PiNodeConnectionStatus.connected &&
            state.selectedProject == defaultProject,
      );
      viewModel.add(
        const WorkspaceProjectPathValidated('/Projects/manual-alias'),
      );
      await _waitFor(
        viewModel,
        (state) =>
            state.selectedProject == validatedProject &&
            !state.sessionsLoading &&
            !state.projectValidating,
      );

      expect(api.validateProjectCalls, 1);
      expect(
        viewModel.state.selectedProject?.identity.canonicalWorkingDirectory,
        '/Projects/canonical-manual',
      );
      expect(viewModel.state.selectedSessionId, isNull);

      await viewModel.close();
      await api.close();
    },
  );

  test(
    'requires explicit trust approval before creating or opening sessions',
    () async {
      final restrictedProject = fakeProject(
        '/Projects/restricted',
        trustStatus: PiProjectTrustStatus.approvalRequired,
      );
      final existing = fakeSession(
        id: 'restricted-existing',
        title: 'Restricted session',
        workingDirectory: '/Projects/restricted',
      );
      final api = FakePiNodeApi(
        defaultProject: restrictedProject,
        sessions: <PiSessionSummary>[existing],
        details: <PiSessionId, PiSessionDetail>{
          existing.id: fakeDetail(existing),
        },
      );
      final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

      viewModel.add(const WorkspaceStarted());
      await _waitFor(
        viewModel,
        (state) =>
            state.connection.status == PiNodeConnectionStatus.connected &&
            !state.sessionsLoading,
      );
      viewModel.add(const WorkspaceNewSessionRequested());
      viewModel.add(WorkspaceSessionSelected(existing.id));
      await _waitFor(
        viewModel,
        (state) =>
            state.sessionError?.contains('Approve project trust') == true,
      );
      expect(api.createCalls, 0);
      expect(api.getCalls, 0);

      viewModel.add(
        const WorkspaceProjectTrustApproved(createSessionAfterApproval: true),
      );
      await _waitFor(
        viewModel,
        (state) =>
            api.approveTrustCalls == 1 &&
            api.createCalls == 1 &&
            state.selectedProject?.trust.status ==
                PiProjectTrustStatus.trusted &&
            state.selectedSessionId != null,
      );
      expect(
        viewModel.state.selectedProject?.trust.allowsProjectResources,
        isTrue,
      );

      await viewModel.close();
      await api.close();
    },
  );

  test(
    'cleans a selected session immediately before confirmed deletion',
    () async {
      final session = fakeSession(
        id: 'delete-session',
        title: 'Delete session',
        workingDirectory: '/Projects/delete',
      );
      final completion = Completer<PiSessionAdminResult>();
      final api = FakePiNodeApi(
        sessions: <PiSessionSummary>[session],
        details: <PiSessionId, PiSessionDetail>{
          session.id: fakeDetail(
            session,
            messages: <PiMessage>[
              fakeMessage(
                id: 'delete-message',
                role: PiMessageRole.assistant,
                text: 'Delete me',
              ),
            ],
          ),
        },
      )..deleteSessionHandler = (command) => completion.future;
      final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

      viewModel.add(const WorkspaceStarted());
      await _waitFor(
        viewModel,
        (state) => state.connection.status == PiNodeConnectionStatus.connected,
      );
      viewModel.add(WorkspaceSessionSelected(session.id));
      await _waitFor(
        viewModel,
        (state) =>
            state.selectedSessionId == session.id && state.messages.isNotEmpty,
      );
      viewModel.add(
        WorkspaceSessionDeleted(PiDeleteSessionConfirmation.confirmed(session)),
      );
      await _waitFor(
        viewModel,
        (state) => api.deleteCalls == 1 && state.sessionAdminLoading,
      );
      expect(viewModel.state.selectedSessionId, isNull);
      expect(viewModel.state.messages, isEmpty);
      expect(
        viewModel.state.sessionAdminOperation,
        PiSessionAdminOperation.delete,
      );

      api.sessions = const <PiSessionSummary>[];
      api.details.remove(session.id);
      completion.complete(
        PiSessionAdminDeleted(
          commandId: PiCommandId('delete-result'),
          sessionId: session.id,
          reparentedChildCount: 1,
        ),
      );
      await _waitFor(
        viewModel,
        (state) => !state.sessionAdminLoading && state.sessions.isEmpty,
      );
      expect(viewModel.state.statusMessage, contains('reparented'));

      await viewModel.close();
      await api.close();
    },
  );

  test(
    'ignores a stale session rename after the selected project changes',
    () async {
      final session = fakeSession(
        id: 'stale-admin-session',
        title: 'Original title',
        workingDirectory: '/Projects/original',
      );
      final completion = Completer<PiSessionAdminResult>();
      final api = FakePiNodeApi(sessions: <PiSessionSummary>[session])
        ..renameSessionHandler = (command) => completion.future;
      final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

      viewModel.add(const WorkspaceStarted());
      await _waitFor(
        viewModel,
        (state) => state.connection.status == PiNodeConnectionStatus.connected,
      );
      viewModel.add(
        WorkspaceSessionRenamed(sessionId: session.id, name: 'Stale title'),
      );
      await _waitUntil(() => api.renameCalls == 1);

      final nextProject = fakeProject('/Projects/next');
      viewModel.add(WorkspaceProjectSelected(nextProject));
      await _waitFor(
        viewModel,
        (state) =>
            state.selectedProject == nextProject && !state.sessionsLoading,
      );
      completion.complete(
        PiSessionAdminUpdated(
          commandId: PiCommandId('stale-admin-result'),
          operation: PiSessionAdminOperation.rename,
          session: fakeSession(
            id: 'stale-admin-session',
            title: 'Stale title',
            workingDirectory: '/Projects/original',
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.selectedProject, nextProject);
      expect(viewModel.state.sessions.single.title, 'Original title');
      expect(viewModel.state.sessionAdminLoading, isFalse);

      await viewModel.close();
      await api.close();
    },
  );

  test('ignores a stale selected-session load that completes last', () async {
    final first = fakeSession(
      id: 'first-session',
      title: 'First session',
      workingDirectory: '/Projects/first',
    );
    final second = fakeSession(
      id: 'second-session',
      title: 'Second session',
      workingDirectory: '/Projects/second',
    );
    final completers = <PiSessionId, Completer<PiSessionDetail>>{
      first.id: Completer<PiSessionDetail>(),
      second.id: Completer<PiSessionDetail>(),
    };
    final api = FakePiNodeApi(sessions: <PiSessionSummary>[first, second])
      ..getSessionHandler = (sessionId) => completers[sessionId]!.future;
    final viewModel = WorkspaceViewModel(service: WorkspaceService(api));

    viewModel.add(const WorkspaceStarted());
    await _waitFor(
      viewModel,
      (state) => state.connection.status == PiNodeConnectionStatus.connected,
    );
    viewModel.add(WorkspaceSessionSelected(first.id));
    await _waitUntil(() => api.getCalls == 1);
    viewModel.add(WorkspaceSessionSelected(second.id));
    await _waitUntil(() => api.getCalls == 2);

    completers[second.id]!.complete(
      fakeDetail(
        second,
        messages: <PiMessage>[
          fakeMessage(
            id: 'second-answer',
            role: PiMessageRole.assistant,
            text: 'Second answer',
          ),
        ],
      ),
    );
    await _waitFor(
      viewModel,
      (state) =>
          state.selectedSessionId == second.id &&
          state.messages.isNotEmpty &&
          state.messages.single.text == 'Second answer',
    );
    completers[first.id]!.complete(
      fakeDetail(
        first,
        messages: <PiMessage>[
          fakeMessage(
            id: 'first-answer',
            role: PiMessageRole.assistant,
            text: 'First answer',
          ),
        ],
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.selectedSessionId, second.id);
    expect(viewModel.state.messages.single.text, 'Second answer');

    await viewModel.close();
    await api.close();
  });
}

Future<WorkspaceModel> _waitFor(
  WorkspaceViewModel viewModel,
  bool Function(WorkspaceModel state) predicate,
) async {
  if (predicate(viewModel.state)) return viewModel.state;
  return viewModel.stream
      .firstWhere(predicate)
      .timeout(const Duration(seconds: 3));
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition was not met.');
    }
    await Future<void>.delayed(Duration.zero);
  }
}
