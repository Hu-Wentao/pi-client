import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/widgets/diff_view/diff_view.dart';

import '../components/support/component_test_support.dart';
import '../fixtures/output_renderer_fixtures.dart';

void main() {
  group('UnifiedDiffParser', () {
    test('parses files, headers, hunks, changes, and line numbers', () {
      const parser = UnifiedDiffParser();
      final document = parser.parse(unifiedDiffFixture);

      expect(document.files, hasLength(1));
      expect(document.files.single.oldPath, 'lib/example.dart');
      expect(document.files.single.newPath, 'lib/example.dart');
      expect(document.files.single.hunks, hasLength(1));
      final hunk = document.files.single.hunks.single;
      expect(hunk.oldStart, 1);
      expect(hunk.oldCount, 3);
      expect(hunk.newStart, 1);
      expect(hunk.newCount, 4);
      expect(hunk.heading, 'class Example {');
      expect(document.additions, 2);
      expect(document.deletions, 1);

      final removal = document.lines.firstWhere(
        (line) => line.kind == UnifiedDiffLineKind.deletion,
      );
      final additions = document.lines
          .where((line) => line.kind == UnifiedDiffLineKind.addition)
          .toList(growable: false);
      expect(removal.oldLineNumber, 2);
      expect(removal.newLineNumber, isNull);
      expect(additions[0].oldLineNumber, isNull);
      expect(additions[0].newLineNumber, 2);
      expect(additions[1].newLineNumber, 3);
      expect(
        document.lines.last.kind,
        anyOf(UnifiedDiffLineKind.noNewline, UnifiedDiffLineKind.context),
      );
    });

    test('bounds overlong patches, line counts, and individual lines', () {
      const parser = UnifiedDiffParser(
        maxPatchCodeUnits: 80,
        maxLines: 4,
        maxLineCodeUnits: 12,
      );
      final document = parser.parse(
        List<String>.generate(
          20,
          (index) => '+line-$index-very-long',
        ).join('\n'),
      );

      expect(document.truncated, isTrue);
      expect(document.lines.length, lessThanOrEqualTo(5));
      expect(document.lines.any((line) => line.truncated), isTrue);
      expect(document.lines.last.text, contains('truncated'));
    });

    test('malformed and fuzz patches never throw or exceed parser bounds', () {
      const parser = UnifiedDiffParser(
        maxPatchCodeUnits: 8192,
        maxLines: 512,
        maxLineCodeUnits: 512,
      );
      for (final fixture in malformedDiffFixtures) {
        expect(() => parser.parse(fixture), returnsNormally, reason: fixture);
      }

      final random = Random(97331);
      const alphabet = '+- @\\\r\n\u001babcdef0123456789';
      for (var sample = 0; sample < 500; sample += 1) {
        final input = String.fromCharCodes(
          List<int>.generate(
            random.nextInt(2048),
            (_) => alphabet.codeUnitAt(random.nextInt(alphabet.length)),
          ),
        );
        final document = parser.parse(input);
        expect(document.lines.length, lessThanOrEqualTo(513));
      }
    });

    test('parses a 1 MiB patch within a bounded performance budget', () {
      final buffer = StringBuffer(
        'diff --git a/large.txt b/large.txt\n'
        '--- a/large.txt\n'
        '+++ b/large.txt\n'
        '@@ -1,30000 +1,30000 @@\n',
      );
      var line = 0;
      while (buffer.length < 1024 * 1024) {
        buffer.writeln(
          ' context line ${line.toString().padLeft(6, '0')} payload',
        );
        line += 1;
      }

      final stopwatch = Stopwatch()..start();
      final document = const UnifiedDiffParser().parse(buffer.toString());
      stopwatch.stop();

      expect(document.lines.length, greaterThan(20000));
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
    });
  });

  testWidgets('wrapped DiffView exposes semantics and copy action', (
    tester,
  ) async {
    String? copied;
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      componentTestApp(
        Padding(
          padding: const EdgeInsets.all(8),
          child: DiffView(
            patch: unifiedDiffFixture,
            layoutMode: DiffLayoutMode.wrapped,
            height: 260,
            copyHandler: (value) => copied = value,
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(RegExp('Unified diff, 1 files')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('Removed line 2')), findsOneWidget);
    await tester.tap(find.byKey(const Key('diffCopyButton')));
    await tester.pump();
    expect(copied, unifiedDiffFixture);
    expect(find.text('Diff copied'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('copy remains keyboard reachable', (tester) async {
    String? copied;
    await tester.pumpWidget(
      componentTestApp(
        DiffView(
          patch: unifiedDiffFixture,
          height: 180,
          copyHandler: (value) => copied = value,
        ),
      ),
    );

    for (var index = 0; index < 8 && copied == null; index += 1) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
    }
    expect(copied, unifiedDiffFixture);
  });

  testWidgets('side-by-side mode wraps safely at 200% text scale', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(960, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: componentTestApp(
          const Padding(
            padding: EdgeInsets.all(8),
            child: DiffView(
              patch: unifiedDiffFixture,
              layoutMode: DiffLayoutMode.sideBySide,
              height: 360,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Side by side'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Removed line 2.*Added line 2')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('large patches build only visible virtualized rows', (
    tester,
  ) async {
    final patch = StringBuffer(
      'diff --git a/large b/large\n--- a/large\n+++ b/large\n'
      '@@ -1,20000 +1,20000 @@\n',
    );
    for (var index = 0; index < 20000; index += 1) {
      patch.writeln(' context $index');
    }

    await tester.pumpWidget(
      componentTestApp(
        DiffView(
          patch: patch.toString(),
          layoutMode: DiffLayoutMode.wrapped,
          height: 240,
          showToolbar: false,
        ),
      ),
    );

    final materializedRows = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith('diff-row-'),
    );
    expect(materializedRows.evaluate().length, lessThan(100));
    expect(find.byKey(const Key('diffVirtualizedList')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
