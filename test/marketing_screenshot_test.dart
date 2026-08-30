import 'dart:async';
import 'dart:io';

import 'package:flowr/flowr_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/app/workspace/workspace.dart';
import 'package:pi_client/app/workspace/workspace.srv.dart';

import 'support/fake_pi_node_api.dart';

void main() {
  final defaultComparator = goldenFileComparator;
  goldenFileComparator = _ThresholdGoldenComparator(
    Uri.file('${Directory.current.path}/test/marketing_screenshot_test.dart'),
    threshold: 0.0002,
  );
  tearDownAll(() => goldenFileComparator = defaultComparator);

  testWidgets('renders the sanitized first-party Node marketing screenshot', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(_loadMarketingFonts);

    final primary = fakeSession(
      id: 'preview-session',
      title: 'Repair the sync regression',
      workingDirectory: '/Projects/aurora-notes',
      updatedAt: DateTime.utc(2026, 8, 30, 9, 30),
    );
    final release = fakeSession(
      id: 'release-session',
      title: 'Review the release checklist',
      workingDirectory: '/Projects/atlas-dashboard',
      updatedAt: DateTime.utc(2026, 8, 29, 16, 20),
    );
    final protocol = fakeSession(
      id: 'protocol-session',
      title: 'Verify the Pi Node protocol',
      workingDirectory: '/Projects/lumen-runtime',
      updatedAt: DateTime.utc(2026, 8, 29, 11, 10),
    );
    final api = FakePiNodeApi(
      sessions: <PiSessionSummary>[primary, release, protocol],
      details: <PiSessionId, PiSessionDetail>{
        primary.id: fakeDetail(
          primary,
          messages: <PiMessage>[
            fakeMessage(
              id: 'preview-user',
              role: PiMessageRole.user,
              text: 'Inspect the failing sync test and explain the root cause.',
              createdAt: DateTime.utc(2026, 8, 30, 9),
            ),
            fakeMessage(
              id: 'preview-analysis',
              role: PiMessageRole.assistant,
              text:
                  'The older request can finish last and overwrite the newer result. I will add a generation guard and a focused regression test.',
              createdAt: DateTime.utc(2026, 8, 30, 9, 1),
            ),
            fakeMessage(
              id: 'preview-tool',
              role: PiMessageRole.tool,
              text:
                  'flutter test test/sync_controller_test.dart\n00:02 +12: All tests passed!',
              createdAt: DateTime.utc(2026, 8, 30, 9, 2),
            ),
            fakeMessage(
              id: 'preview-result',
              role: PiMessageRole.assistant,
              text:
                  'The stale response is now ignored. The first-party Pi Node event flow is covered in both completion orders.',
              createdAt: DateTime.utc(2026, 8, 30, 9, 3),
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
    viewModel.add(WorkspaceSessionSelected(primary.id));
    await tester.pump();
    await tester.runAsync(
      () => _waitUntil(
        () =>
            viewModel.state.selectedSessionId == primary.id &&
            !viewModel.state.conversationLoading &&
            viewModel.state.messages.length == 4,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('/Users/'), findsNothing);
    expect(find.textContaining('password'), findsNothing);
    expect(find.textContaining('token'), findsNothing);
    expect(find.textContaining('pi-web'), findsNothing);
    expect(find.textContaining('Local Pi Node'), findsNothing);
    expect(find.text('Pi Node'), findsOneWidget);

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
  final deadline = DateTime.now().add(const Duration(seconds: 3));
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
