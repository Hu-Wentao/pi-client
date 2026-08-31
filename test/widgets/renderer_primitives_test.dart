import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart' as flutter_math;
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/widgets/code_block_view/code_block_view.dart';
import 'package:pi_client/widgets/markdown_body/markdown_body.dart';
import 'package:pi_client/widgets/math_view/math_view.dart';
import 'package:pi_client/widgets/mermaid_view/mermaid_view.dart';
import 'package:pi_client/widgets/renderer_dependencies/renderer_dependency_inventory.dart';

void main() {
  group('MarkdownBody', () {
    testWidgets('renders bounded GFM, math, Mermaid, and the HTML allowlist', (
      tester,
    ) async {
      Uri? opened;
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _testApp(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: MarkdownBody(
                onOpenLink: (uri) => opened = uri,
                data: r'''
# Renderer heading

A **strong** and *emphasized* paragraph with ~~removed~~ text, `inlineCode`,
<kbd onclick="bad()">⌘ K</kbd>, H<sub class="x">2</sub>O,
x<sup style="bad">2</sup>, <mark data-x="bad">marked</mark>, and<br>line break.

- [x] Completed task
- [ ] Pending task

1. First
2. Second

> Quoted content

| Name | Value |
| --- | ---: |
| safe | 42 |

Visit https://example.com/docs and [blocked](javascript:alert(1)).

![remote](https://example.com/private.png)

```dart
final answer = 42;
```

$$
x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$

```mermaid
flowchart LR
  A[Prompt] --> B{Safe?}
  B -->|yes| C[Render]
```

<script src="https://evil.invalid/payload.js">not executable</script>
''',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Renderer heading'), findsOneWidget);
      expect(find.text('Completed task'), findsOneWidget);
      expect(find.text('Pending task'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Completed task')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Incomplete task')), findsOneWidget);
      expect(find.byKey(const Key('markdown-table')), findsOneWidget);
      expect(find.byKey(const Key('code-highlighted-text')), findsOneWidget);
      expect(find.byKey(const Key('math-rendered-expression')), findsOneWidget);
      expect(find.byKey(const Key('mermaid-canvas-flowchart')), findsOneWidget);
      expect(
        find.byKey(const Key('markdown-remote-image-blocked')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('markdown-blocked-link')), findsOneWidget);
      expect(find.textContaining('<script'), findsNothing);
      expect(find.textContaining('onclick'), findsNothing);
      expect(find.textContaining('not executable'), findsOneWidget);

      await tester.tap(find.byKey(const Key('markdown-safe-link')).first);
      await tester.pump();
      expect(opened, Uri.parse('https://example.com/docs'));
      await tester.tap(find.byKey(const Key('markdown-blocked-link')));
      expect(opened, Uri.parse('https://example.com/docs'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses lightweight streaming mode and enforces parser limits', (
      tester,
    ) async {
      final deep = List<String>.filled(40, '>').join();
      final large = List<String>.filled(2000, '$deep nested').join('\n');
      await tester.pumpWidget(
        _testApp(
          SingleChildScrollView(
            child: MarkdownBody(
              streaming: true,
              limits: const MarkdownRenderLimits(
                maxTextCharacters: 1200,
                maxAstNodes: 80,
                maxDepth: 6,
              ),
              data:
                  '''
```mermaid
flowchart TD
A --> B
```

\$\$x^2\$\$

$large
''',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('markdown-limit-notice')), findsOneWidget);
      expect(find.byType(flutter_math.Math), findsNothing);
      expect(find.byKey(const Key('mermaid-canvas-flowchart')), findsNothing);
      expect(find.byKey(const Key('mermaid-streaming-source')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('blocks dangerous links, data images, and hostile raw HTML', (
      tester,
    ) async {
      var activations = 0;
      final hostileTable = StringBuffer('|a|b|\n|-|-|\n');
      for (var index = 0; index < 80; index++) {
        hostileTable.writeln('|$index|<img src=x onerror=alert(1)>|');
      }
      await tester.pumpWidget(
        _testApp(
          SingleChildScrollView(
            child: MarkdownBody(
              onOpenLink: (_) => activations++,
              limits: const MarkdownRenderLimits(
                maxTableRows: 8,
                maxTableColumns: 2,
              ),
              data:
                  '''
[javascript](javascript:alert(1))
[data](data:text/html,bad)
[file](file:///private/secret)
![data](data:image/png;base64,AAAA)
![protocol-relative](//example.com/private.png)
<style>* { display: none }</style>
<iframe src="https://evil.invalid"></iframe>
${hostileTable.toString()}
''',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('markdown-blocked-link')), findsNWidgets(3));
      expect(
        find.byKey(const Key('markdown-image-unavailable')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('markdown-remote-image-blocked')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('markdown-limit-notice')), findsOneWidget);
      expect(find.textContaining('onerror'), findsNothing);
      for (final target
          in find.byKey(const Key('markdown-blocked-link')).evaluate()) {
        await tester.tap(find.byWidget(target.widget));
      }
      expect(activations, 0);
      expect(tester.takeException(), isNull);
    });
  });

  group('CodeBlockView', () {
    testWidgets('highlights known languages and falls back for unknown ones', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          const Column(
            children: [
              CodeBlockView(code: 'final value = 42;', language: 'dart'),
              CodeBlockView(code: 'plain payload', language: 'unknown-lang'),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('code-highlighted-text')), findsOneWidget);
      expect(find.byKey(const Key('code-plain-text')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('copy action is keyboard accessible and copies bounded text', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await tester.pumpWidget(
        _testApp(
          const CodeBlockView(
            code: '123456789',
            language: 'text',
            maxCharacters: 5,
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(copied, '12345');
      expect(find.textContaining('truncated'), findsOneWidget);
    });
  });

  group('MathView', () {
    testWidgets('renders bounded inline and display TeX without a WebView', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          const Column(
            children: [
              MathView(expression: r'E = mc^2'),
              MathView(
                expression: r'\int_0^1 x^2\,dx = \frac{1}{3}',
                displayMode: true,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(flutter_math.Math), findsNWidgets(2));
      expect(find.byKey(const Key('math-copy-button')), findsOneWidget);
      expect(find.byType(PlatformViewLink), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects links, macro definitions, depth, and oversized TeX', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          const Column(
            children: [
              MathView(expression: r'\href{https://evil.invalid}{x}'),
              MathView(expression: r'\newcommand{\x}{\x}\x'),
              MathView(expression: '{{{{{{{{{{x}}}}}}}}}}', maxCharacters: 8),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('math-rendering-error')), findsNWidgets(3));
      expect(find.byType(flutter_math.Math), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('MermaidView', () {
    final diagrams = <String, String>{
      'flowchart': '''
flowchart LR
A[Start] --> B{Ready?}
B -->|yes| C[Ship]
''',
      'sequence': '''
sequenceDiagram
participant User
participant Pi
User->>Pi: Prompt
Pi-->>User: Result
''',
      'state': '''
stateDiagram-v2
[*] --> Idle
Idle --> Running : start
Running --> Idle : stop
''',
      'classDiagram': '''
classDiagram
class Agent {
  +String id
  +run()
}
class Session
Session *-- Agent : owns
''',
      'er': '''
erDiagram
CUSTOMER {
  string id PK
}
ORDER {
  string id PK
}
CUSTOMER ||--o{ ORDER : places
''',
      'pie': '''
pie
  title Work split
  "Code" : 60
  "Tests" : 40
''',
      'gantt': '''
gantt
  title Release plan
  dateFormat YYYY-MM-DD
  section Build
  Runtime :done, build1, 2026-08-01, 3d
  Verify :test1, 2026-08-04, 2d
''',
    };

    for (final entry in diagrams.entries) {
      testWidgets('paints an actual ${entry.key} diagram', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          _testApp(
            SingleChildScrollView(child: MermaidView(source: entry.value)),
          ),
        );
        await tester.pumpAndSettle();

        final canvasKey = entry.key == 'classDiagram'
            ? 'mermaid-canvas-classDiagram'
            : 'mermaid-canvas-${entry.key}';
        expect(find.byKey(Key(canvasKey)), findsOneWidget);
        expect(find.byKey(const Key('mermaid-rendering-error')), findsNothing);
        final customPaint = tester.widget<CustomPaint>(
          find.byKey(Key(canvasKey)),
        );
        expect(customPaint.size.width, greaterThan(100));
        expect(customPaint.size.height, greaterThan(100));
        expect(
          customPaint.painter.runtimeType.toString(),
          contains('MermaidPainter'),
        );
        final recorder = ui.PictureRecorder();
        customPaint.painter!.paint(ui.Canvas(recorder), customPaint.size);
        final picture = recorder.endRecording();
        picture.dispose();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
      'rejects directives, links, excessive nodes, and unknown types',
      (tester) async {
        final manyNodes = StringBuffer('flowchart TD\n');
        for (var index = 0; index < 20; index++) {
          manyNodes.writeln('N$index --> N${index + 1}');
        }
        await tester.pumpWidget(
          _testApp(
            Column(
              children: [
                const MermaidView(
                  source: '%%{init: {}}%%\nflowchart TD\nA-->B',
                ),
                const MermaidView(
                  source: 'flowchart TD\nclick A javascript:alert(1)',
                ),
                MermaidView(
                  source: manyNodes.toString(),
                  limits: const MermaidRenderLimits(maxNodes: 4),
                ),
                const MermaidView(source: 'journey\ntitle unsupported'),
              ],
            ),
          ),
        );
        await tester.pump();

        expect(
          find.byKey(const Key('mermaid-rendering-error')),
          findsNWidgets(4),
        );
        expect(find.byType(PlatformViewLink), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });

  testWidgets('supports 200% text scale, semantics, and keyboard traversal', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _testApp(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: const SingleChildScrollView(
            child: Column(
              children: [
                MarkdownBody(
                  data: '# Accessible\n\n[Docs](https://example.com)',
                ),
                MathView(expression: r'x^2', displayMode: true),
                MermaidView(source: 'flowchart TD\nA[One] --> B[Two]'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('Markdown content')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Display formula')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Flowchart, 2 nodes')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(FocusManager.instance.primaryFocus, isNotNull);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'keeps bounded malicious and performance corpus responsive',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final corpus = StringBuffer();
      for (var index = 0; index < 120; index++) {
        corpus
          ..writeln('## Section $index')
          ..writeln('- [${index.isEven ? 'x' : ' '}] item')
          ..writeln('`code$index` and \\(x_$index^2\\)')
          ..writeln('| a | b |\n| - | - |\n| $index | value |');
      }
      final hostileCode = List<String>.filled(2000, r'/* " ${').join();
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(
        _testApp(
          SingleChildScrollView(
            child: Column(
              children: [
                MarkdownBody(data: corpus.toString()),
                CodeBlockView(code: hostileCode, language: 'dart'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 8)));
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );

  test('records exact renderer dependencies and reviewed boundaries', () {
    expect(
      rendererDependencyInventory.map(
        (entry) => '${entry.package}:${entry.version}',
      ),
      containsAll(<String>[
        'markdown:7.3.1',
        'flutter_math_fork:0.7.4',
        're_highlight:0.0.3',
      ]),
    );
    expect(
      rendererDependencyInventory.every(
        (entry) => entry.license.isNotEmpty && entry.runtimeBoundary.isNotEmpty,
      ),
      isTrue,
    );
    expect(
      rendererDependencyEvaluations.map(
        (entry) => '${entry.package}:${entry.version}:${entry.outcome}',
      ),
      containsAll(<String>[
        'mermaid_flutter:0.1.0:not selected',
        'mermaid_core:0.1.0:not selected',
        'highlight:0.7.0:not selected',
        'syntax_highlight:0.5.0:not selected',
      ]),
    );
  });
}

Widget _testApp(Widget child) => MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  ),
  home: Scaffold(body: child),
);
