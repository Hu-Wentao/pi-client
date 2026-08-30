import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/api/pi_node/pi_node.dart';
import 'package:pi_client/components/node_connection/node_connection.dart';
import 'package:pi_client/protocol/pi_protocol.dart';

import 'support/component_test_support.dart';

void main() {
  testWidgets('shows negotiated protocol and disconnects', (tester) async {
    var disconnectCount = 0;
    await tester.pumpWidget(
      componentTestApp(
        SizedBox(
          width: 700,
          child: NodeConnectionView(
            snapshot: PiNodeConnectionSnapshot.connected(
              PiProtocolVersion(1, 2, 3),
            ),
            onDisconnect: () => disconnectCount += 1,
          ),
        ),
      ),
    );

    expect(find.text('Connected · v1.2.3'), findsOneWidget);
    expect(find.text('Protocol 1.2.3 is ready.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nodeConnectionDisconnectAction')));
    expect(disconnectCount, 1);
  });

  testWidgets('presents retryable error responsively', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 420));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var retryCount = 0;

    await tester.pumpWidget(
      componentTestApp(
        NodeConnectionView(
          snapshot: const PiNodeConnectionSnapshot.disconnected(),
          errorMessage: 'Pi Node is unavailable.',
          onRetry: () => retryCount += 1,
        ),
      ),
    );

    expect(find.text('Pi Node is unavailable.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nodeConnectionPrimaryAction')));
    expect(retryCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('announces connection progress and supports cancellation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var cancelled = false;

    await tester.pumpWidget(
      componentTestApp(
        NodeConnectionView(
          snapshot: const PiNodeConnectionSnapshot.connecting(),
          onDisconnect: () => cancelled = true,
        ),
      ),
    );

    expect(
      find.bySemanticsLabel(RegExp('Connecting to Pi Node')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('nodeConnectionDisconnectAction')));
    expect(cancelled, isTrue);
    semantics.dispose();
  });
}
