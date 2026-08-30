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
