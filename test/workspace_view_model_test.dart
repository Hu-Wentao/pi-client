import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/app/workspace/workspace.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';

void main() {
  test(
    'loads sessions, streams output, refreshes final messages, and aborts',
    () async {
      final api = _FakePiWebApi();
      final viewModel = WorkspaceViewModel(
        gateway: api,
        initialBaseUrl: 'http://127.0.0.1:30141',
        reconnectDelay: Duration.zero,
      );

      viewModel.add(const WorkspaceStarted());
      await _waitFor(
        viewModel,
        (state) =>
            state.connectionStatus == WorkspaceConnectionStatus.connected,
      );
      expect(viewModel.state.sessions.single.id, 's1');

      viewModel.add(const WorkspaceSessionSelected('s1'));
      await _waitFor(
        viewModel,
        (state) =>
            state.selectedSessionId == 's1' && !state.conversationLoading,
      );
      expect(viewModel.state.messages.single.text, 'Hello from history');
      await _waitUntil(() => api.watchCalls == 1);
      api.currentEvents.add(<String, dynamic>{
        'type': 'connected',
        'sessionId': 's1',
        'isStreaming': false,
      });
      await _waitFor(
        viewModel,
        (state) => state.streamStatus == WorkspaceStreamStatus.connected,
      );

      api.promptCompleter = Completer<void>();
      viewModel.add(const WorkspacePromptSubmitted('Inspect the project'));
      await _waitFor(viewModel, (state) => state.sending);
      expect(viewModel.state.messages.last.text, 'Inspect the project');
      await _waitUntil(() => api.watchCalls == 2);

      api.currentEvents.add(<String, dynamic>{
        'type': 'message_update',
        'assistantMessageEvent': <String, dynamic>{
          'type': 'text_delta',
          'delta': 'Live answer',
        },
      });
      await _waitFor(
        viewModel,
        (state) =>
            state.messages.any((message) => message.text == 'Live answer'),
      );

      viewModel.add(const WorkspaceAgentStopped());
      await _waitUntil(() => api.abortCalls == 1);

      api.detailMessage = 'Final answer';
      api.promptCompleter!.complete();
      await _waitFor(viewModel, (state) => !state.sending);
      expect(viewModel.state.messages.last.text, 'Final answer');

      final watchCallsBeforeClose = api.watchCalls;
      final firstController = api.currentEvents;
      await firstController.close();
      await _waitUntil(() => api.watchCalls > watchCallsBeforeClose);
      expect(viewModel.state.streamStatus, WorkspaceStreamStatus.connecting);

      await viewModel.close();
      await api.close();
    },
  );

  test('keeps the password outside serializable workspace state', () async {
    final api = _FakePiWebApi();
    final viewModel = WorkspaceViewModel(
      gateway: api,
      initialBaseUrl: 'http://127.0.0.1:30141',
    );

    viewModel.add(
      const WorkspaceConnectionApplied(
        baseUrl: 'http://localhost:30141',
        password: 'do-not-serialize',
      ),
    );
    await _waitFor(
      viewModel,
      (state) => state.connectionStatus == WorkspaceConnectionStatus.connected,
    );

    expect(
      viewModel.state.toJson().toString(),
      isNot(contains('do-not-serialize')),
    );
    expect(api.lastPassword, 'do-not-serialize');

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
      .timeout(const Duration(seconds: 2));
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition was not met.');
    }
    await Future<void>.delayed(Duration.zero);
  }
}

final class _FakePiWebApi implements PiWebApi {
  String detailMessage = 'Hello from history';
  Completer<void>? promptCompleter;
  int watchCalls = 0;
  int abortCalls = 0;
  String lastPassword = '';
  StreamController<Map<String, dynamic>> currentEvents =
      StreamController<Map<String, dynamic>>();

  @override
  String normalizeBaseUrl(String value) =>
      value.replaceFirst('localhost', '127.0.0.1');

  @override
  Future<Map<String, dynamic>> loadSessions({
    required String baseUrl,
    required String password,
    bool force = false,
  }) async {
    lastPassword = password;
    return <String, dynamic>{
      'sessions': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 's1',
          'cwd': '/tmp/project',
          'name': 'Test session',
          'created': '2026-01-01T00:00:00Z',
          'modified': '2026-01-01T00:00:00Z',
          'messageCount': 2,
          'firstMessage': 'Inspect the project',
        },
      ],
      'runningSessionIds': <String>[],
    };
  }

  @override
  Future<Map<String, dynamic>> loadSession({
    required String baseUrl,
    required String password,
    required String sessionId,
  }) async => <String, dynamic>{
    'context': <String, dynamic>{
      'messages': <Map<String, dynamic>>[
        <String, dynamic>{
          'role': 'assistant',
          'content': <Map<String, dynamic>>[
            <String, dynamic>{'type': 'text', 'text': detailMessage},
          ],
        },
      ],
      'entryIds': <String>['entry-1'],
    },
  };

  @override
  Future<String> ensureSession({
    required String baseUrl,
    required String password,
    required String cwd,
  }) async => 's1';

  @override
  Future<void> sendPrompt({
    required String baseUrl,
    required String password,
    required String sessionId,
    required String message,
  }) async {
    await promptCompleter?.future;
  }

  @override
  Future<void> abort({
    required String baseUrl,
    required String password,
    required String sessionId,
  }) async {
    abortCalls += 1;
  }

  @override
  Stream<Map<String, dynamic>> watchEvents({
    required String baseUrl,
    required String password,
    required String sessionId,
  }) {
    watchCalls += 1;
    currentEvents = StreamController<Map<String, dynamic>>();
    return currentEvents.stream;
  }

  Future<void> close() async {
    if (currentEvents.isClosed) return;
    if (currentEvents.hasListener) {
      await currentEvents.close();
    } else {
      unawaited(currentEvents.close());
    }
  }
}
