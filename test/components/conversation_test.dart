import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/components/conversation/conversation.dart';
import 'package:pi_client/widgets/pi_message_bubble/pi_message_bubble.dart';

import 'support/component_test_support.dart';

void main() {
  testWidgets('shows no-session, loading, and retryable error states', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentTestApp(const ConversationView(messages: <PiMessage>[])),
    );
    expect(find.text('Select a session'), findsOneWidget);

    await tester.pumpWidget(
      componentTestApp(
        ConversationView(
          session: testSession('loading'),
          messages: const <PiMessage>[],
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
          messages: const <PiMessage>[],
          errorMessage: 'Conversation could not be loaded.',
          onRetry: () => retried = true,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('conversationRetryButton')));
    expect(retried, isTrue);
  });

  testWidgets('renders typed messages without narrow-layout overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final messages = <PiMessage>[
      testMessage(
        'user',
        role: PiMessageRole.user,
        text: 'Please inspect the current project state.',
      ),
      testMessage(
        'assistant',
        text: 'I will run the focused checks now.',
        isStreaming: true,
      ),
      testMessage(
        'tool',
        role: PiMessageRole.tool,
        text: 'flutter test test/components',
      ),
      testMessage(
        'system',
        role: PiMessageRole.system,
        text: 'Connection restored.',
      ),
    ];

    await tester.pumpWidget(
      componentTestApp(
        ConversationView(
          session: testSession('active', isRunning: true),
          messages: messages,
        ),
      ),
    );

    expect(find.byType(PiMessageBubble), findsNWidgets(4));
    expect(find.text('Connection restored.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('follows the tail when messages arrive from an empty timeline', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    final harnessKey = GlobalKey<_ConversationHarnessState>();

    await tester.pumpWidget(
      componentTestApp(
        _ConversationHarness(
          key: harnessKey,
          scrollController: scrollController,
        ),
      ),
    );
    harnessKey.currentState!.showMessages(
      List<PiMessage>.generate(
        30,
        (index) => testMessage(
          'message-$index',
          text: 'A sufficiently long message row $index for scrolling.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      scrollController.offset,
      closeTo(scrollController.position.maxScrollExtent, 1),
    );
  });

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
            'Recent history message $index with enough content for scrolling.';
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
      expect(harnessKey.currentState!.messages.length, 50);
    },
  );

  testWidgets(
    'offers accessible edit-from-here and fork actions only for eligible user entries',
    (tester) async {
      final user = testMessage(
        'user-entry',
        role: PiMessageRole.user,
        text: 'Try another approach',
      );
      final assistant = testMessage('assistant-entry', text: 'Current answer');
      PiMessage? edited;
      PiMessage? forked;

      await tester.pumpWidget(
        componentTestApp(
          SizedBox(
            height: 500,
            child: ConversationView(
              session: testSession('conversation-session'),
              messages: <PiMessage>[user, assistant],
              editableMessageIds: <PiMessageId>{user.id},
              forkableMessageIds: <PiMessageId>{user.id},
              onEditFromHere: (message) => edited = message,
              onForkFromHere: (message) => forked = message,
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Branch actions for user message'),
        findsOneWidget,
      );
      expect(find.text('Edit from here'), findsOneWidget);
      expect(find.text('Fork'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey<String>('messageEditFromHere-user-entry')),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('messageForkFromHere-user-entry')),
      );
      expect(edited, user);
      expect(forked, user);
      expect(
        find.byKey(
          const ValueKey<String>('messageEditFromHere-assistant-entry'),
        ),
        findsNothing,
      );
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
  List<PiMessage> messages = List<PiMessage>.generate(
    40,
    (index) => testMessage(
      'recent-$index',
      text: 'Recent history message $index with enough content for scrolling.',
    ),
  );

  void prependOlder() {
    setState(() {
      messages = <PiMessage>[
        ...List<PiMessage>.generate(
          10,
          (index) => testMessage(
            'older-$index',
            text: 'Older history message $index with enough content.',
          ),
        ),
        ...messages,
      ];
    });
  }

  @override
  Widget build(BuildContext context) => ConversationView(
    session: testSession('paged'),
    messages: messages,
    canLoadOlder: messages.length == 40,
    onLoadOlder: prependOlder,
    scrollController: widget.scrollController,
  );
}

class _ConversationHarness extends StatefulWidget {
  const _ConversationHarness({required this.scrollController, super.key});

  final ScrollController scrollController;

  @override
  State<_ConversationHarness> createState() => _ConversationHarnessState();
}

class _ConversationHarnessState extends State<_ConversationHarness> {
  List<PiMessage> messages = const <PiMessage>[];

  void showMessages(List<PiMessage> value) => setState(() => messages = value);

  @override
  Widget build(BuildContext context) => ConversationView(
    session: testSession('tail'),
    messages: messages,
    scrollController: widget.scrollController,
  );
}
