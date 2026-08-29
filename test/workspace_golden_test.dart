import 'dart:async';

import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/app/workspace/workspace.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';

void main() {
  testWidgets('renders the desktop workspace baseline', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = _GoldenPiWebApi();
    final viewModel = WorkspaceViewModel(
      gateway: api,
      initialBaseUrl: 'http://127.0.0.1:30141',
      reconnectDelay: Duration.zero,
    );

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
    viewModel.add(const WorkspaceSessionSelected('session-1'));
    await tester.pump();
    await tester.runAsync(
      () => _waitUntil(
        () =>
            viewModel.state.selectedSessionId == 'session-1' &&
            !viewModel.state.conversationLoading &&
            viewModel.state.messages.length == 2,
      ),
    );
    await tester.pumpAndSettle();

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
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Golden condition was not met.');
    }
    await Future<void>.delayed(Duration.zero);
  }
}

final class _GoldenPiWebApi implements PiWebApi {
  final _controllers = <StreamController<Map<String, dynamic>>>[];

  @override
  String normalizeBaseUrl(String value) => value;

  @override
  Future<Map<String, dynamic>> loadSessions({
    required String baseUrl,
    required String password,
    bool force = false,
  }) async => <String, dynamic>{
    'sessions': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'session-1',
        'cwd': '/Users/demo/projects/pi-client',
        'name': 'Implement the Flutter client',
        'created': '2026-08-29T08:00:00Z',
        'modified': '2026-08-29T09:30:00Z',
        'messageCount': 12,
        'firstMessage': 'Implement a native Flutter pi client',
      },
      <String, dynamic>{
        'id': 'session-2',
        'cwd': '/Users/demo/projects/pi-web',
        'name': 'Review pi-web protocol',
        'created': '2026-08-28T08:00:00Z',
        'modified': '2026-08-28T10:00:00Z',
        'messageCount': 8,
        'firstMessage': 'Audit the HTTP and SSE boundaries',
      },
    ],
    'runningSessionIds': <String>['session-1'],
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
          'role': 'user',
          'content': 'Implement the macOS MVP and verify every state.',
          'timestamp': 1787961600000,
        },
        <String, dynamic>{
          'role': 'assistant',
          'content': <Map<String, dynamic>>[
            <String, dynamic>{
              'type': 'text',
              'text':
                  'The workspace contract is active. Sessions, messages, prompt submission, abort, and SSE reconnect are covered by focused tests.',
            },
          ],
          'timestamp': 1787961660000,
        },
      ],
      'entryIds': <String>['entry-user', 'entry-assistant'],
    },
  };

  @override
  Future<String> ensureSession({
    required String baseUrl,
    required String password,
    required String cwd,
  }) async => 'session-1';

  @override
  Future<void> sendPrompt({
    required String baseUrl,
    required String password,
    required String sessionId,
    required String message,
  }) async {}

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
    final controller = StreamController<Map<String, dynamic>>();
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
