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

  testWidgets(
    'offers accessible rename, auto-name, and inline delete actions',
    (tester) async {
      final session = testSession('admin', title: 'Admin session');
      String? renamed;
      var customNameCleared = false;
      var autoNamed = false;
      PiDeleteSessionConfirmation? deletion;

      await tester.pumpWidget(
        componentTestApp(
          SessionBrowserView(
            sessions: <PiSessionSummary>[session],
            onSessionSelected: (_) {},
            onRenameSession: (_, name) => renamed = name,
            onClearSessionName: (_) => customNameCleared = true,
            onAutoNameSession: (_) => autoNamed = true,
            onDeleteSessionConfirmed: (confirmation) => deletion = confirmation,
          ),
        ),
      );

      final actions = find.byKey(
        ValueKey<String>('sessionActions-${session.id.value}'),
      );
      expect(actions, findsOneWidget);
      expect(
        find.byTooltip('Session actions for Admin session'),
        findsOneWidget,
      );
      await tester.tap(actions);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sessionRenameDialog')), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('sessionRenameField')),
        'Focused admin name',
      );
      await tester.tap(find.byKey(const Key('sessionRenameSaveButton')));
      await tester.pumpAndSettle();
      expect(renamed, 'Focused admin name');

      await tester.tap(actions);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear custom name'));
      await tester.pump();
      expect(customNameCleared, isTrue);

      await tester.tap(actions);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate name'));
      await tester.pump();
      expect(autoNamed, isTrue);

      await tester.tap(actions);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(
        find.byKey(
          ValueKey<String>('sessionDeleteConfirmation-${session.id.value}'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .getSemantics(
              find.byKey(
                ValueKey<String>(
                  'sessionDeleteConfirmationSemantics-${session.id.value}',
                ),
              ),
            )
            .label,
        contains('Confirm deletion of Admin session'),
      );
      await tester.tap(find.byKey(const Key('sessionDeleteConfirmButton')));
      await tester.pump();
      expect(deletion?.sessionId, session.id);
      expect(deletion?.adminRevision, session.adminRevision);
      expect(deletion?.destructiveActionAcknowledged, isTrue);
    },
  );

  testWidgets('shows session action progress as a live region', (tester) async {
    final session = testSession('progress', title: 'Progress session');
    await tester.pumpWidget(
      componentTestApp(
        SessionBrowserView(
          sessions: <PiSessionSummary>[session],
          onSessionSelected: (_) {},
          onAutoNameSession: (_) {},
          sessionActionInProgressId: session.id,
          sessionActionInProgressOperation: PiSessionAdminOperation.autoName,
        ),
      ),
    );

    expect(
      tester
          .getSemantics(
            find.byKey(
              ValueKey<String>('sessionActionProgress-${session.id.value}'),
            ),
          )
          .label,
      contains('Session autoName in progress'),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
