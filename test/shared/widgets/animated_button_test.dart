import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:historybox/shared/widgets/animated_button.dart';

void main() {
  testWidgets('AnimatedButton has correct semantics', (WidgetTester tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            text: 'Click Me',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    // Verify semantics
    final finder = find.bySemanticsLabel('Click Me');
    expect(
      tester.getSemantics(finder),
      matchesSemantics(
        label: 'Click Me',
        isButton: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
        hasEnabledState: true,
      ),
    );

    // Verify tap works via semantics
    final semanticsId = tester.getSemantics(finder).id;
    tester.binding.pipelineOwner.semanticsOwner!.performAction(semanticsId, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
  });

  testWidgets('AnimatedButton loading state semantics', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            text: 'Loading',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      ),
    );

    // Verify disabled state
    final finder = find.bySemanticsLabel('Loading');
    expect(
      tester.getSemantics(finder),
      matchesSemantics(
        label: 'Loading',
        isButton: true,
        isEnabled: false,
        hasEnabledState: true,
        isFocusable: true,
      ),
    );
  });
}
