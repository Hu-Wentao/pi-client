import 'dart:async';
import 'dart:io';
import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/app/workspace/workspace.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';

void main() {
  final defaultComparator = goldenFileComparator;
  goldenFileComparator = _ThresholdGoldenComparator(
    Uri.file('${Directory.current.path}/test/marketing_screenshot_test.dart'),
    threshold: 0.0002,
  );
  tearDownAll(() => goldenFileComparator = defaultComparator);

  testWidgets('renders the sanitized real-text marketing screenshot', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(_loadMarketingFonts);

    final api = _MarketingPiWebApi();
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
          fontFamily: 'MarketingRoboto',
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
    viewModel.add(const WorkspaceSessionSelected('preview-session'));
    await tester.pump();
    await tester.runAsync(
      () => _waitUntil(
        () =>
            viewModel.state.selectedSessionId == 'preview-session' &&
            !viewModel.state.conversationLoading &&
            viewModel.state.messages.length == 4,
      ),
    );
    await tester.pumpAndSettle();

    expect(api.receivedPassword, isEmpty);
    expect(find.textContaining('/Users/'), findsNothing);
    expect(find.textContaining('password'), findsNothing);
    expect(find.textContaining('token'), findsNothing);

    await expectLater(
      find.byKey(const Key('workspaceScaffold')),
      matchesGoldenFile('../site/public/assets/workspace-preview.png'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    unawaited(viewModel.close());
    unawaited(api.close());
  });
}

Future<void> _loadMarketingFonts() async {
  final configuredRoot = Platform.environment['FLUTTER_ROOT'];
  final inferredRoot = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent.path;
  final fontDirectory =
      '${configuredRoot ?? inferredRoot}/bin/cache/artifacts/material_fonts';
  await Future.wait(<Future<void>>[
    _loadFont('MarketingRoboto', '$fontDirectory/Roboto-Regular.ttf'),
    _loadFont('MaterialIcons', '$fontDirectory/MaterialIcons-Regular.otf'),
  ]);
}

Future<void> _loadFont(String family, String path) async {
  final fontFile = File(path);
  if (!fontFile.existsSync()) {
    throw StateError('Flutter test font not found at ${fontFile.path}.');
  }
  final bytes = await fontFile.readAsBytes();
  await (FontLoader(
    family,
  )..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)))).load();
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Marketing screenshot condition was not met.');
    }
    await Future<void>.delayed(Duration.zero);
  }
}

final class _ThresholdGoldenComparator extends LocalFileComparator {
  _ThresholdGoldenComparator(super.testFile, {required this.threshold});

  final double threshold;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= threshold) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

final class _MarketingPiWebApi implements PiWebApi {
  final _controllers = <StreamController<Map<String, dynamic>>>[];
  String receivedPassword = '';

  @override
  String normalizeBaseUrl(String value) => value;

  @override
  Future<Map<String, dynamic>> loadSessions({
    required String baseUrl,
    required String password,
    bool force = false,
  }) async {
    receivedPassword = password;
    return <String, dynamic>{
      'sessions': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'preview-session',
          'cwd': '/Projects/aurora-notes',
          'name': 'Repair the sync regression',
          'created': '2026-08-28T08:00:00Z',
          'modified': '2026-08-30T09:30:00Z',
          'messageCount': 18,
          'firstMessage': 'Inspect the failing sync test',
        },
        <String, dynamic>{
          'id': 'review-session',
          'cwd': '/Projects/atlas-dashboard',
          'name': 'Review the release checklist',
          'created': '2026-08-27T08:00:00Z',
          'modified': '2026-08-29T16:20:00Z',
          'messageCount': 11,
          'firstMessage': 'Check the release boundaries',
        },
        <String, dynamic>{
          'id': 'docs-session',
          'cwd': '/Projects/lumen-docs',
          'name': 'Clarify the setup guide',
          'created': '2026-08-26T08:00:00Z',
          'modified': '2026-08-29T11:10:00Z',
          'messageCount': 7,
          'firstMessage': 'Make the quick start user-focused',
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
  }) async {
    receivedPassword = password;
    return <String, dynamic>{
      'context': <String, dynamic>{
        'messages': <Map<String, dynamic>>[
          <String, dynamic>{
            'role': 'user',
            'content':
                'Inspect the failing sync test and explain the root cause.',
          },
          <String, dynamic>{
            'role': 'assistant',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'text',
                'text':
                    'The older request can finish last and overwrite the newer result. I will add a generation guard and a focused regression test.',
              },
            ],
          },
          <String, dynamic>{
            'role': 'toolResult',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'text',
                'text':
                    'flutter test test/sync_controller_test.dart\n00:02 +12: All tests passed!',
              },
            ],
          },
          <String, dynamic>{
            'role': 'assistant',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'text',
                'text':
                    'The stale response is now ignored, and the focused test covers both completion orders.',
              },
            ],
          },
        ],
        'entryIds': <String>[
          'preview-user',
          'preview-analysis',
          'preview-tool',
          'preview-result',
        ],
      },
    };
  }

  @override
  Future<String> ensureSession({
    required String baseUrl,
    required String password,
    required String cwd,
  }) async => 'preview-session';

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
    receivedPassword = password;
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
