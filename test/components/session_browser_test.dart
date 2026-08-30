import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/components/session_browser/session_browser.dart';

import 'support/component_test_support.dart';

void main() {
  testWidgets('shows loading and empty create states', (tester) async {
    await tester.pumpWidget(
      componentTestApp(
        SessionBrowserView(
          sessions: const <PiSessionSummary>[],
          isLoading: true,
          onSessionSelected: (_) {},
        ),
      ),
    );
    expect(find.text('Loading sessions'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    var created = false;
    await tester.pumpWidget(
      componentTestApp(
        SessionBrowserView(
          sessions: const <PiSessionSummary>[],
          onSessionSelected: (_) {},
          onCreateSession: () => created = true,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('sessionBrowserEmptyAction')));
    expect(created, isTrue);
  });

  testWidgets('filters and keyboard-selects typed sessions', (tester) async {
    final sessions = <PiSessionSummary>[
      testSession('a', title: 'Alpha review'),
      testSession(
        'b',
        title: 'Beta implementation',
        isRunning: true,
        hasUnread: true,
      ),
      testSession('c', title: 'Gamma tests'),
    ];
    final selected = <PiSessionId>[];

    await tester.pumpWidget(
      componentTestApp(
        SessionBrowserView(
          sessions: sessions,
          selectedSessionId: sessions.first.id,
          onSessionSelected: selected.add,
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('sessionBrowserFilterField')),
      'beta',
    );
    await tester.pump();
    expect(find.text('Beta implementation'), findsOneWidget);
    expect(find.text('Alpha review'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('sessionBrowserFilterField')),
      '',
    );
    await tester.pump();
    await tester.tap(find.text('Alpha review'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(selected.last, sessions[1].id);
    expect(find.bySemanticsLabel(RegExp('Running')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('Unread activity')), findsWidgets);
  });

  testWidgets('shows a retryable error without hiding existing sessions', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      componentTestApp(
        SessionBrowserView(
          sessions: <PiSessionSummary>[testSession('existing')],
          errorMessage: 'Could not refresh sessions.',
          onRetry: () => retried = true,
          onSessionSelected: (_) {},
        ),
      ),
    );

    expect(find.text('Session existing'), findsOneWidget);
    expect(find.text('Could not refresh sessions.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sessionBrowserRetryButton')));
    expect(retried, isTrue);
  });
}
