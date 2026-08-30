import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_client/components/prompt_composer/prompt_composer.dart';

import 'support/component_test_support.dart';

void main() {
  testWidgets('submits with Enter and keeps Shift+Enter as a newline', (
    tester,
  ) async {
    final submitted = <String>[];
    await tester.pumpWidget(
      componentTestApp(PromptComposerView(onSubmitted: submitted.add)),
    );

    final field = find.byKey(const Key('promptComposerField'));
    await tester.tap(field);
    await tester.enterText(field, 'Run focused tests');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(submitted, <String>['Run focused tests']);
    expect(find.text('Run focused tests'), findsNothing);

    await tester.enterText(field, 'Line one');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();

    expect(submitted, hasLength(1));
    final editable = tester.widget<TextField>(field);
    expect(editable.controller!.text, contains('\n'));
  });

  testWidgets('uses external controllers without owning their lifecycle', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'External draft');
    addTearDown(controller.dispose);
    final submitted = <String>[];

    await tester.pumpWidget(
      componentTestApp(
        PromptComposerView(
          controller: controller,
          clearOnSubmit: false,
          onSubmitted: submitted.add,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('promptComposerSendButton')));
    expect(submitted, <String>['External draft']);
    expect(controller.text, 'External draft');

    await tester.pumpWidget(componentTestApp(const SizedBox.shrink()));
    controller.text = 'Still usable';
    expect(controller.text, 'Still usable');
  });

  testWidgets('shows stop, submission, error, and narrow states', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 320));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var stopped = false;

    await tester.pumpWidget(
      componentTestApp(
        PromptComposerView(
          onSubmitted: (_) {},
          onStop: () => stopped = true,
          isRunning: true,
          errorMessage: 'The previous prompt was rejected.',
        ),
      ),
    );
    expect(find.text('The previous prompt was rejected.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('promptComposerStopButton')));
    expect(stopped, isTrue);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      componentTestApp(
        PromptComposerView(onSubmitted: (_) {}, isSubmitting: true),
      ),
    );
    expect(
      find.byKey(const Key('promptComposerSubmittingButton')),
      findsOneWidget,
    );
  });
}
