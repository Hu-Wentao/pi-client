import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/components/conversation/conversation.dart';

import '../fixtures/output_renderer_fixtures.dart';
import '../support/fake_pi_node_api.dart';
import 'support/component_test_support.dart';

void main() {
  testWidgets('shows no-session, loading, and retryable error states', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentTestApp(
        const ConversationView(entries: <PiConversationEntry>[]),
      ),
    );
    expect(find.text('Select a session'), findsOneWidget);

    await tester.pumpWidget(
      componentTestApp(
        ConversationView(
          session: testSession('loading'),
          entries: const <PiConversationEntry>[],
          isLoading: true,
        ),
      ),
    );
    expect(find.text('Loading conversation'), findsOneWidget);

    var retried = false;
    await tester.pumpWidget(
      componentTestApp(
        ConversationView(
          session: testSession('error'),
          entries: const <PiConversationEntry>[],
          errorMessage: 'Conversation could not be loaded.',
          onRetry: () => retried = true,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('conversationRetryButton')));
    expect(retried, isTrue);
  });

  testWidgets(
    'renders entry-specific Markdown, math, Mermaid, thinking, JSON, diff, ANSI, and metrics',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final assistant = _assistantEntry(
        'assistant-rich',
        parts: <PiConversationPart>[
          _textPart(
            'assistant-rich-text',
            '# Result\n\n```dart\nfinal value = 42;\n```\n\n'
                r'$$'
                '\nx^2\n'
                r'$$'
                '\n\n```mermaid\nflowchart LR\nA --> B\n```',
          ),
          PiThinkingConversationPart(
            partId: 'thinking-visible',
            revision: 1,
            visibility: PiThinkingVisibility.visible,
            text: '**Checked** the safe path.',
          ),
          PiThinkingConversationPart(
            partId: 'thinking-redacted',
            revision: 1,
            visibility: PiThinkingVisibility.redacted,
          ),
          PiThinkingConversationPart(
            partId: 'thinking-deferred',
            revision: 1,
            visibility: PiThinkingVisibility.deferred,
          ),
        ],
        metrics: _metrics(),
      );
      final jsonResult = _toolResult(
        'json-result',
        callId: 'unmatched-json',
        text: '{"ok":true,"count":2}',
      );
      final diffResult = _toolResult(
        'diff-result',
        callId: 'unmatched-diff',
        text: unifiedDiffFixture,
        isError: true,
      );
      final bash = PiBashConversationEntry(
        identity: _identity('bash-entry'),
        revision: 1,
        createdAt: _now,
        finalized: true,
        parts: <PiConversationPart>[
          _textPart('bash-output', '\u001b[31mfailed\u001b[0m'),
        ],
        toolActivities: const <PiToolActivity>[],
        command: 'flutter test',
        exitCode: 1,
        cancelled: false,
        truncated: false,
        excludedFromContext: false,
      );

      await tester.pumpWidget(
        componentTestApp(
          ConversationView(
            session: testSession('rich'),
            entries: <PiConversationEntry>[
              assistant,
              jsonResult,
              diffResult,
              bash,
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('markdown-body')), findsWidgets);
      expect(find.byKey(const Key('code-highlighted-text')), findsOneWidget);
      expect(find.byKey(const Key('math-rendered-expression')), findsOneWidget);
      expect(find.byKey(const Key('mermaid-canvas-flowchart')), findsOneWidget);
      expect(find.text('Thinking'), findsNWidgets(3));
      expect(find.text('Reasoning redacted by the provider'), findsOneWidget);
      expect(find.text('Reasoning deferred by the provider'), findsOneWidget);
      expect(find.text('12 total'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('tool-result-json-result')),
        300,
        scrollable: _timelineScrollable(),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('tool-result-json-result')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('code-highlighted-text')), findsWidgets);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('tool-result-diff-result')),
        300,
        scrollable: _timelineScrollable(),
      );
      expect(find.byKey(const Key('diffVirtualizedList')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('bash-bash-entry')),
        300,
        scrollable: _timelineScrollable(),
      );
      expect(find.text('failed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'groups parallel tool activity and results under the assistant in source order with all statuses',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final assistant = _assistantEntry(
        'assistant-tools',
        parts: <PiConversationPart>[
          PiToolCallConversationPart(
            partId: 'call-part-first',
            revision: 1,
            toolCallId: 'call-first',
            toolName: 'First tool',
            safeArguments: PiSafeObject(<PiSafeObjectField>[
              PiSafeObjectField(key: 'path', value: PiSafeString('/safe/a')),
            ]),
          ),
          PiToolCallConversationPart(
            partId: 'call-part-second',
            revision: 1,
            toolCallId: 'call-second',
            toolName: 'Second tool',
            safeArguments: const PiSafeNull(),
          ),
          PiToolCallConversationPart(
            partId: 'call-part-third',
            revision: 1,
            toolCallId: 'call-third',
            toolName: 'Blocked tool',
            safeArguments: const PiSafeNull(),
          ),
        ],
        activities: <PiToolActivity>[
          _activity(
            'second',
            callId: 'call-second',
            toolName: 'Second tool',
            ordinal: 1,
            status: PiToolActivityStatus.running,
            progress: 4200,
          ),
          _activity(
            'first',
            callId: 'call-first',
            toolName: 'First tool',
            ordinal: 0,
            status: PiToolActivityStatus.succeeded,
          ),
          _activity(
            'third',
            callId: 'call-third',
            toolName: 'Blocked tool',
            ordinal: 2,
            status: PiToolActivityStatus.pending,
            details: PiSafeObject(<PiSafeObjectField>[
              PiSafeObjectField(key: 'blocked', value: const PiSafeBool(true)),
            ]),
          ),
        ],
      );
      final result = _toolResult(
        'first-result',
        callId: 'call-first',
        toolName: 'First tool',
        text: 'written',
        details: PiSafeObject(<PiSafeObjectField>[
          PiSafeObjectField(key: 'operation', value: PiSafeString('Write')),
          PiSafeObjectField(
            key: 'filePath',
            value: PiSafeString('/safe/output.dart'),
          ),
          PiSafeObjectField(
            key: 'writtenFiles',
            value: PiSafeList(<PiSafeValue>[PiSafeString('/safe/output.dart')]),
          ),
        ]),
      );

      await tester.pumpWidget(
        componentTestApp(
          ConversationView(
            session: testSession('tools'),
            entries: <PiConversationEntry>[assistant, result],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('conversation-entry-first-result')),
        findsNothing,
      );
      expect(find.text('First tool'), findsOneWidget);
      expect(find.text('Second tool'), findsOneWidget);
      expect(find.text('Blocked tool'), findsOneWidget);
      expect(find.text('Succeeded'), findsWidgets);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Blocked'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('First tool')).dy,
        lessThan(tester.getTopLeft(find.text('Second tool')).dy),
      );

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('tool-activity-call-first')),
        200,
        scrollable: _timelineScrollable(),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('tool-activity-call-first')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('tool-result-first-result')),
      );
      await tester.pumpAndSettle();
      expect(find.text('/safe/output.dart'), findsWidgets);
      expect(find.text('Written files'), findsOneWidget);
    },
  );

  testWidgets(
    'renders custom, compaction, branch, marker, and unsupported recovery entries',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final entries = <PiConversationEntry>[
        PiCustomConversationEntry(
          identity: _identity('custom-entry'),
          revision: 1,
          createdAt: _now,
          finalized: true,
          parts: <PiConversationPart>[
            _textPart('custom-part', '**Extension** payload'),
          ],
          toolActivities: const <PiToolActivity>[],
          customType: 'extension.sample',
          display: true,
          safeDetails: PiSafeObject(<PiSafeObjectField>[
            PiSafeObjectField(key: 'safe', value: const PiSafeBool(true)),
          ]),
        ),
        PiCompactionConversationEntry(
          identity: _identity('compaction-entry'),
          revision: 1,
          createdAt: _now,
          finalized: true,
          parts: <PiConversationPart>[
            _textPart('compaction-part', 'Compact summary'),
          ],
          toolActivities: const <PiToolActivity>[],
          firstKeptEntryId: 'assistant-rich',
          tokensBefore: 4096,
          fromHook: false,
          safeDetails: const PiSafeNull(),
        ),
        PiBranchSummaryConversationEntry(
          identity: _identity('branch-entry'),
          revision: 1,
          createdAt: _now,
          finalized: true,
          parts: <PiConversationPart>[
            _textPart('branch-part', 'Alternative branch summary'),
          ],
          toolActivities: const <PiToolActivity>[],
          fromEntryId: 'assistant-rich',
          fromHook: true,
          safeDetails: const PiSafeNull(),
        ),
        PiMarkerConversationEntry(
          identity: _identity('marker-entry'),
          revision: 1,
          createdAt: _now,
          finalized: true,
          parts: const <PiConversationPart>[],
          toolActivities: const <PiToolActivity>[],
          markerKind: PiConversationMarkerKind.modelChange,
          provider: 'provider-next',
          model: 'model-next',
        ),
        PiUnknownConversationEntry(
          identity: _identity('unknown-entry'),
          revision: 1,
          createdAt: _now,
          finalized: true,
          parts: <PiConversationPart>[
            PiUnsupportedConversationPart(
              partId: 'unsupported-part',
              revision: 1,
              sourceType: 'future-content-type',
            ),
          ],
          toolActivities: const <PiToolActivity>[],
          sourceType: 'future-entry-type',
        ),
      ];

      await tester.pumpWidget(
        componentTestApp(
          ConversationView(session: testSession('recovery'), entries: entries),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('extension.sample'), findsOneWidget);
      expect(find.text('Context compacted'), findsOneWidget);
      expect(find.text('Branch summary'), findsOneWidget);
      expect(find.text('Model changed'), findsOneWidget);
      expect(find.text('Unsupported conversation entry'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey<String>('semantic-entry-unknown-entry')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Unsupported content'), findsOneWidget);
      expect(find.text('future-content-type'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'renders verified deferred images and bounds deferred text to 1 MiB',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final image = fixturePng();
      final deferredText = Uint8List.fromList(
        List<int>.filled(1024 * 1024 + 64, 0x61),
      );
      final imageReference = _reference('image-content', 'image/png', image);
      final textReference = _reference(
        'text-content',
        'text/plain; charset=utf-8',
        deferredText,
      );
      final entry = _assistantEntry(
        'deferred-entry',
        parts: <PiConversationPart>[
          PiImageConversationPart(
            partId: 'image-part',
            revision: 1,
            contentReference: imageReference,
          ),
          PiTextConversationPart(
            partId: 'text-part',
            revision: 1,
            contentReference: textReference,
          ),
        ],
      );
      final api = FakePiNodeApi();
      api.messageContentHandler = (request) async => _ContentHandle(
        request,
        request.reference.contentId == imageReference.contentId
            ? <Uint8List>[image]
            : <Uint8List>[
                deferredText.sublist(0, 512 * 1024),
                deferredText.sublist(512 * 1024),
              ],
      );

      await tester.pumpWidget(
        componentTestApp(
          ConversationView(
            session: testSession('deferred'),
            projectId: PiProjectId('project-deferred'),
            piNodeApi: api,
            entries: <PiConversationEntry>[entry],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('deferredImageLoaded')), findsOneWidget);
      expect(find.byKey(const Key('deferredTextPreviewLimit')), findsOneWidget);
      expect(api.messageContentCalls, 2);
      expect(tester.takeException(), isNull);
      await api.close();
    },
  );

  testWidgets(
    'rebinds deferred content when the selected session changes with the same entry revision',
    (tester) async {
      final bytes = Uint8List.fromList(utf8.encode('Session-bound content'));
      final reference = _reference(
        'session-bound-content',
        'text/plain; charset=utf-8',
        bytes,
      );
      final entry = _assistantEntry(
        'shared-entry',
        parts: <PiConversationPart>[
          PiTextConversationPart(
            partId: 'shared-part',
            revision: 1,
            contentReference: reference,
          ),
        ],
      );
      final requests = <PiMessageContentRequest>[];
      final api = FakePiNodeApi();
      api.messageContentHandler = (request) async {
        requests.add(request);
        return _ContentHandle(request, <Uint8List>[bytes]);
      };

      await tester.pumpWidget(
        componentTestApp(
          ConversationView(
            session: testSession('first-session'),
            projectId: PiProjectId('project'),
            piNodeApi: api,
            entries: <PiConversationEntry>[entry],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        componentTestApp(
          ConversationView(
            session: testSession('second-session'),
            projectId: PiProjectId('project'),
            piNodeApi: api,
            entries: <PiConversationEntry>[entry],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(requests, hasLength(2));
      expect(requests.first.binding.sessionId, PiSessionId('first-session'));
      expect(requests.last.binding.sessionId, PiSessionId('second-session'));
      expect(find.text('Session-bound content'), findsOneWidget);
      await api.close();
    },
  );

  testWidgets(
    'preserves the visible scroll anchor when older history prepends',
    (tester) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);
      final harnessKey = GlobalKey<_PagedConversationHarnessState>();

      await tester.pumpWidget(
        componentTestApp(
          SizedBox(
            height: 520,
            child: _PagedConversationHarness(
              key: harnessKey,
              scrollController: scrollController,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      scrollController.jumpTo(scrollController.position.maxScrollExtent / 2);
      await tester.pump();
      final timeline = find.byKey(const Key('conversationTimeline'));
      final viewportTop = tester.getTopLeft(timeline).dy;
      late String anchorText;
      late double previousViewportOffset;
      for (var index = 0; index < 40; index += 1) {
        final text =
            'Recent history entry $index with enough content for scrolling.';
        final visible = find.text(text).hitTestable();
        if (visible.evaluate().isEmpty) continue;
        anchorText = text;
        previousViewportOffset =
            tester.getTopLeft(visible.first).dy - viewportTop;
        break;
      }

      await tester.tap(find.byKey(const Key('conversationLoadOlderButton')));
      await tester.pumpAndSettle();

      final restoredOffset =
          tester.getTopLeft(find.text(anchorText).first).dy -
          tester.getTopLeft(timeline).dy;
      expect(restoredOffset, closeTo(previousViewportOffset, 1));
      expect(harnessKey.currentState!.entries.length, 50);
    },
  );

  testWidgets(
    'offers branch actions only for persisted tree-backed user entries',
    (tester) async {
      final persisted = _userEntry('persisted-user', 'Try another approach');
      final runtime = _userEntry(
        'runtime-user',
        'Optimistic prompt',
        scope: PiConversationIdentityScope.runtime,
      );
      PiConversationEntry? edited;
      PiConversationEntry? forked;

      await tester.pumpWidget(
        componentTestApp(
          SizedBox(
            height: 500,
            child: ConversationView(
              session: testSession('conversation-session'),
              entries: <PiConversationEntry>[persisted, runtime],
              editableEntryIds: <PiSessionTreeEntryId>{
                PiSessionTreeEntryId('persisted-user'),
                PiSessionTreeEntryId('runtime-user'),
              },
              forkableEntryIds: <PiSessionTreeEntryId>{
                PiSessionTreeEntryId('persisted-user'),
                PiSessionTreeEntryId('runtime-user'),
              },
              onEditFromHere: (entry) => edited = entry,
              onForkFromHere: (entry) => forked = entry,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Branch actions for persisted user entry'),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('entryEditFromHere-persisted-user')),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('entryForkFromHere-persisted-user')),
      );
      expect(edited, persisted);
      expect(forked, persisted);
      expect(
        find.byKey(const ValueKey<String>('entryEditFromHere-runtime-user')),
        findsNothing,
      );
    },
  );

  testWidgets('keeps 10,000 entries virtualized and viewport-bounded', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var rendered = 0;
    final entries = List<PiConversationEntry>.generate(
      10000,
      (index) => _userEntry('entry-$index', 'Lightweight entry $index'),
      growable: false,
    );
    final stopwatch = Stopwatch()..start();

    await tester.pumpWidget(
      componentTestApp(
        ConversationView(
          session: testSession('ten-thousand'),
          entries: entries,
          followLatest: false,
          onEntryRendered: (_, _) => rendered += 1,
        ),
      ),
    );
    await tester.pump();
    stopwatch.stop();

    expect(rendered, lessThan(80));
    expect(
      find.byKey(const ValueKey<String>('conversation-entry-entry-9999')),
      findsNothing,
    );
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 8)));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    '1,000 deltas replace only the target semantic subtree',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final counts = <String, int>{};
      final key = GlobalKey<_DeltaHarnessState>();
      await tester.pumpWidget(
        componentTestApp(
          _DeltaHarness(
            key: key,
            onEntryRendered: (entryId, _) {
              counts.update(entryId, (value) => value + 1, ifAbsent: () => 1);
            },
          ),
        ),
      );
      await tester.pump();
      counts.clear();
      final stopwatch = Stopwatch()..start();
      for (var revision = 2; revision <= 1001; revision += 1) {
        key.currentState!.updateTarget(revision);
        await tester.pump();
      }
      stopwatch.stop();

      expect(counts['target'], 1000);
      expect(counts['peer'], isNull);
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 20)));
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  testWidgets(
    'supports 320/768/1440, light/dark, 200% scale, keyboard, and semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      String? clipboard;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });
      final entry = _assistantEntry(
        'responsive-entry',
        parts: <PiConversationPart>[
          _textPart('responsive-text', '**Accessible** response'),
        ],
      );

      for (final width in <double>[320, 768, 1440]) {
        await tester.binding.setSurfaceSize(Size(width, 900));
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: width == 768 ? ThemeMode.dark : ThemeMode.light,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Scaffold(
                body: ConversationView(
                  session: testSession('responsive'),
                  entries: <PiConversationEntry>[entry],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'width $width');
        expect(
          find.byKey(const Key('conversationActivityMinimap')),
          width >= 1000 ? findsOneWidget : findsNothing,
        );
      }

      expect(find.bySemanticsLabel(RegExp('Pi message')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Conversation activity minimap')),
        findsOneWidget,
      );
      for (var index = 0; index < 20 && clipboard == null; index += 1) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
      }
      expect(clipboard, isNotNull);
      semantics.dispose();
      await tester.binding.setSurfaceSize(null);
    },
  );
}

class _PagedConversationHarness extends StatefulWidget {
  const _PagedConversationHarness({required this.scrollController, super.key});

  final ScrollController scrollController;

  @override
  State<_PagedConversationHarness> createState() =>
      _PagedConversationHarnessState();
}

class _PagedConversationHarnessState extends State<_PagedConversationHarness> {
  List<PiConversationEntry> entries = List<PiConversationEntry>.generate(
    40,
    (index) => _assistantEntry(
      'recent-$index',
      parts: <PiConversationPart>[
        _textPart(
          'recent-part-$index',
          'Recent history entry $index with enough content for scrolling.',
        ),
      ],
    ),
  );

  void prependOlder() {
    setState(() {
      entries = <PiConversationEntry>[
        ...List<PiConversationEntry>.generate(
          10,
          (index) => _assistantEntry(
            'older-$index',
            parts: <PiConversationPart>[
              _textPart(
                'older-part-$index',
                'Older history entry $index with enough content.',
              ),
            ],
          ),
        ),
        ...entries,
      ];
    });
  }

  @override
  Widget build(BuildContext context) => ConversationView(
    session: testSession('paged'),
    entries: entries,
    canLoadOlder: entries.length == 40,
    onLoadOlder: prependOlder,
    scrollController: widget.scrollController,
    followLatest: false,
  );
}

class _DeltaHarness extends StatefulWidget {
  const _DeltaHarness({required this.onEntryRendered, super.key});

  final ConversationEntryRenderObserver onEntryRendered;

  @override
  State<_DeltaHarness> createState() => _DeltaHarnessState();
}

class _DeltaHarnessState extends State<_DeltaHarness> {
  var revision = 1;

  void updateTarget(int value) => setState(() => revision = value);

  @override
  Widget build(BuildContext context) => ConversationView(
    session: testSession('delta'),
    entries: <PiConversationEntry>[
      _assistantEntry(
        'target',
        revision: revision,
        finalized: false,
        parts: <PiConversationPart>[
          _textPart('target-part', 'Streaming $revision', revision: revision),
        ],
      ),
      _assistantEntry(
        'peer',
        parts: <PiConversationPart>[_textPart('peer-part', 'Stable peer')],
      ),
    ],
    followLatest: false,
    onEntryRendered: widget.onEntryRendered,
  );
}

Finder _timelineScrollable() => find
    .descendant(
      of: find.byKey(const Key('conversationTimeline')),
      matching: find.byType(Scrollable),
    )
    .first;

final DateTime _now = DateTime.utc(2026, 1, 1, 12);

PiConversationEntryIdentity _identity(
  String id, {
  PiConversationIdentityScope scope = PiConversationIdentityScope.persistent,
}) => PiConversationEntryIdentity(entryId: id, scope: scope);

PiTextConversationPart _textPart(String id, String text, {int revision = 1}) =>
    PiTextConversationPart(partId: id, revision: revision, text: text);

PiUserConversationEntry _userEntry(
  String id,
  String text, {
  PiConversationIdentityScope scope = PiConversationIdentityScope.persistent,
  int revision = 1,
}) => PiUserConversationEntry(
  identity: _identity(id, scope: scope),
  revision: revision,
  createdAt: _now,
  finalized: true,
  parts: <PiConversationPart>[_textPart('$id-part', text, revision: revision)],
  toolActivities: const <PiToolActivity>[],
);

PiAssistantConversationEntry _assistantEntry(
  String id, {
  Iterable<PiConversationPart> parts = const <PiConversationPart>[],
  Iterable<PiToolActivity> activities = const <PiToolActivity>[],
  PiConversationMetrics? metrics,
  int revision = 1,
  bool finalized = true,
}) => PiAssistantConversationEntry(
  identity: _identity(id),
  revision: revision,
  createdAt: _now,
  finalized: finalized,
  parts: parts,
  toolActivities: activities,
  metrics: metrics,
  provider: 'provider',
  model: 'model',
  stopReason: finalized ? 'stop' : 'streaming',
);

PiToolResultConversationEntry _toolResult(
  String id, {
  required String callId,
  String toolName = 'Tool',
  String text = '',
  bool isError = false,
  PiSafeValue details = const PiSafeNull(),
}) => PiToolResultConversationEntry(
  identity: _identity(id),
  revision: 1,
  createdAt: _now,
  finalized: true,
  parts: text.isEmpty
      ? const <PiConversationPart>[]
      : <PiConversationPart>[_textPart('$id-part', text)],
  toolActivities: const <PiToolActivity>[],
  toolCallId: callId,
  toolName: toolName,
  isError: isError,
  safeDetails: details,
);

PiToolActivity _activity(
  String id, {
  required String callId,
  required String toolName,
  required int ordinal,
  required PiToolActivityStatus status,
  int? progress,
  PiSafeValue details = const PiSafeNull(),
}) => PiToolActivity(
  activityId: 'activity-$id',
  toolCallId: callId,
  toolName: toolName,
  sourceOrdinal: ordinal,
  revision: 1,
  status: status,
  progressBasisPoints: progress,
  safeDetails: details,
);

PiConversationMetrics _metrics() => PiConversationMetrics(
  usage: PiUsageMetrics(
    inputTokens: 5,
    outputTokens: 7,
    cacheReadTokens: 0,
    cacheWriteTokens: 0,
    totalTokens: 12,
  ),
  cost: PiMoneyAmount(currencyCode: 'USD', decimalAmount: '0.01'),
  context: PiContextMetrics(
    tokens: 12,
    contextWindow: 100,
    percentDecimal: '12%',
  ),
);

PiMessageContentReference _reference(
  String id,
  String mimeType,
  Uint8List bytes,
) => PiMessageContentReference(
  contentId: id,
  mimeType: mimeType,
  displayName: id,
  totalBytes: bytes.length,
  sha256: Uint8List.fromList(sha256.convert(bytes).bytes),
);

final class _ContentHandle implements PiMessageContentHandle {
  _ContentHandle(this.request, this.chunks);

  final PiMessageContentRequest request;
  final List<Uint8List> chunks;
  final Completer<void> _done = Completer<void>();
  bool cancelled = false;

  @override
  PiMessageContentBinding get binding => request.binding;

  @override
  PiMessageContentReference get reference => request.reference;

  @override
  Stream<Uint8List> get bytes async* {
    for (final chunk in chunks) {
      if (cancelled) break;
      yield Uint8List.fromList(chunk);
    }
    if (!_done.isCompleted) _done.complete();
  }

  @override
  Future<void> get done => _done.future;

  @override
  Future<void> cancel() async {
    cancelled = true;
    if (!_done.isCompleted) _done.complete();
  }
}
