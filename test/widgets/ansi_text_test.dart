import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/widgets/ansi_text/ansi_text.dart';

import '../components/support/component_test_support.dart';
import '../fixtures/output_renderer_fixtures.dart';

void main() {
  group('AnsiParser', () {
    test('parses reset, attributes, 16, 256, and true-color SGR', () {
      const parser = AnsiParser();
      final document = parser.parse(
        '\u001b[1;31mbold red\u001b[22;39m plain '
        '\u001b[38;5;46mgreen\u001b[0m '
        '\u001b[48;2;1;2;3mbackground\u001b[0m',
      );

      expect(document.plainText, 'bold red plain green background');
      expect(document.runs, hasLength(5));
      expect(document.runs[0].style.bold, isTrue);
      expect(document.runs[0].style.foreground, const Color(0xffaa0000));
      expect(document.runs[1].style.bold, isFalse);
      expect(document.runs[1].style.foreground, isNull);
      expect(document.runs[2].style.foreground, const Color(0xff00ff00));
      expect(document.runs[4].style.background, const Color(0xff010203));
    });

    test('discards OSC, cursor, malformed, C0, C1, and DEL controls', () {
      const parser = AnsiParser();
      for (final fixture in ansiSecurityFixtures) {
        final document = parser.parse(fixture);
        expect(document.unsafeSequenceSeen, isTrue, reason: fixture);
        expect(document.plainText, isNot(contains('\u001b')), reason: fixture);
        expect(
          document.plainText.codeUnits.where(
            (value) =>
                (value < 0x20 && value != 0x09 && value != 0x0a) ||
                value == 0x7f ||
                (value >= 0x80 && value <= 0x9f),
          ),
          isEmpty,
          reason: fixture,
        );
      }
      expect(parser.parse('\u001b]0;forged\u0007visible').plainText, 'visible');
      expect(parser.parse('\u001b[2Jafter').plainText, 'after');
      expect(parser.parse('a\r\nb\rc').plainText, 'a\nb\nc');
    });

    test('bounds input, sequences, parameters, and generated runs', () {
      const parser = AnsiParser(
        maxInputCodeUnits: 32,
        maxSequenceCodeUnits: 8,
        maxParameters: 4,
        maxRuns: 2,
      );
      final document = parser.parse(
        List<String>.generate(
          40,
          (index) => '\u001b[${index % 8 + 30}mX',
        ).join(),
      );

      expect(document.truncated, isTrue);
      expect(document.runs.length, lessThanOrEqualTo(2));
      expect(document.plainText, endsWith('…'));
    });

    test('deterministic fuzz never emits terminal controls or throws', () {
      const parser = AnsiParser(maxInputCodeUnits: 4096);
      final random = Random(47821);
      for (var sample = 0; sample < 800; sample += 1) {
        final length = random.nextInt(512);
        final input = String.fromCharCodes(
          List<int>.generate(length, (_) => random.nextInt(256)),
        );
        final document = parser.parse(input);
        expect(
          document.plainText.codeUnits.where(
            (value) =>
                value == 0x1b ||
                (value < 0x20 && value != 0x09 && value != 0x0a) ||
                value == 0x7f ||
                (value >= 0x80 && value <= 0x9f),
          ),
          isEmpty,
          reason: 'sample $sample',
        );
      }
    });
  });

  testWidgets('AnsiText is selectable, semantic, and safe at 200% scale', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(320, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: componentTestApp(
          const SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: AnsiText(
              '\u001b[1;32mSuccess\u001b[0m\n\u001b]0;hidden\u0007Visible',
              semanticLabel: 'Safe terminal output',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.bySemanticsLabel('Safe terminal output'), findsOneWidget);
    expect(find.textContaining('hidden'), findsNothing);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
