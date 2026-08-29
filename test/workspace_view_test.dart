import 'dart:async';

import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/app/workspace/workspace.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';

void main() {
  testWidgets('scrolls sessions, selects one, and submits a prompt', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = _WidgetFakePiWebApi();
    final viewModel = WorkspaceViewModel(
      gateway: api,
      initialBaseUrl: 'http://127.0.0.1:30141',
      reconnectDelay: Duration.zero,
    );

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
    expect(find.byKey(const Key('connectionStatusChip')), findsOneWidget);
    expect(find.text('Widget session 1'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('sessionList')),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(find.text('Widget session 16'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('session-s16')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('session-s16')));
    await tester.pump();
    await tester.runAsync(
      () => _waitUntil(
        () =>
            viewModel.state.selectedSessionId == 's16' &&
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

    await tester.enterText(
      find.byKey(const Key('promptField')),
      'Run the focused tests',
    );
    expect(find.text('Run the focused tests'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sendPromptButton')));
    await tester.pump();

    expect(viewModel.state.sending, isTrue);
    expect(viewModel.state.messages.last.role, PiMessageRole.user);
    expect(viewModel.state.messages.last.text, 'Run the focused tests');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    unawaited(viewModel.close());
    unawaited(api.close());
  });
}

final class _WidgetFakePiWebApi implements PiWebApi {
  final sentMessages = <String>[];
  var detailMessage = 'Existing answer';
  final _controllers = <StreamController<Map<String, dynamic>>>[];

  @override
  String normalizeBaseUrl(String value) => value;

  @override
  Future<Map<String, dynamic>> loadSessions({
    required String baseUrl,
    required String password,
    bool force = false,
  }) async => <String, dynamic>{
    'sessions': List<Map<String, dynamic>>.generate(
      16,
      (index) => <String, dynamic>{
        'id': 's${index + 1}',
        'cwd': '/tmp/widget-project-${index + 1}',
        'name': 'Widget session ${index + 1}',
        'created': '2026-01-01T00:00:00Z',
        'modified': '2026-01-01T00:00:00Z',
        'messageCount': index + 1,
        'firstMessage': 'Run tests',
      },
    ),
    'runningSessionIds': <String>[],
  };

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
    sentMessages.add(message);
    detailMessage = 'Completed in widget test';
  }

  @override
  Future<void> abort({
    required String baseUrl,
    required String password,
    required String sessionId,
  }) async {}

  @override
  Stream<Map<String, dynamic>> watchEvents({
    required String baseUrl,
    required String password,
    required String sessionId,
  }) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _controllers.add(controller);
    scheduleMicrotask(
      () => controller.add(<String, dynamic>{
        'type': 'connected',
        'sessionId': sessionId,
        'isStreaming': false,
      }),
    );
    return controller.stream;
  }

  Future<void> close() async {
    for (final controller in _controllers) {
      if (controller.isClosed) continue;
      if (controller.hasListener) {
        await controller.close();
      } else {
        unawaited(controller.close());
      }
    }
  }
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Widget condition was not met.');
    }
    await Future<void>.delayed(Duration.zero);
  }
}
