import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:historybox/shared/widgets/animated_button.dart';

void main() {
  testWidgets('AnimatedButton has correct semantics and handles taps', (WidgetTester tester) async {
    bool isPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedButton(
              text: 'Test Button',
              onPressed: () {
                isPressed = true;
              },
            ),
          ),
        ),
      ),
    );

    // Verify Semantics
    final handle = tester.ensureSemantics();

    // Find the widget via label.
    final finder = find.bySemanticsLabel('Test Button');
    expect(finder, findsOneWidget);

    // Get the semantics data to verify properties
    final semanticsNode = tester.getSemantics(finder);
    final semanticsData = semanticsNode.getSemanticsData();

    // Verify it is a button.
    // This check is expected to FAIL before the fix.
    expect(semanticsData.hasFlag(SemanticsFlag.isButton), isTrue, reason: 'Should be identified as a button');

    // Verify it has tap action.
    expect(semanticsData.hasAction(SemanticsAction.tap), isTrue, reason: 'Should support tap action');

    // Perform the tap action via semantics
    tester.binding.pipelineOwner.semanticsOwner!.performAction(semanticsNode.id, SemanticsAction.tap);
    await tester.pumpAndSettle();

    expect(isPressed, isTrue, reason: 'Callback should be called');

    handle.dispose();
  });
}
