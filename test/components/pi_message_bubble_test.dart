import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/widgets/pi_message_bubble/pi_message_bubble.dart';

import 'support/component_test_support.dart';

void main() {
  testWidgets('renders role-specific selectable content at narrow widths', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 220));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      componentTestApp(
        Padding(
          padding: const EdgeInsets.all(8),
          child: PiMessageBubble(
            message: testMessage(
              'tool-message',
              role: PiMessageRole.tool,
              text: 'flutter test test/components',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tool'), findsOneWidget);
    expect(find.text('flutter test test/components'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('announces streaming assistant messages', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      componentTestApp(
        Center(
          child: PiMessageBubble(
            message: testMessage(
              'assistant-message',
              text: 'Working on the change',
              isStreaming: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Pi'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Pi message, streaming')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('Receiving message')), findsOneWidget);
    semantics.dispose();
  });
}
