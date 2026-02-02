import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:historybox/shared/widgets/animated_button.dart';

void main() {
  testWidgets('AnimatedButton has button semantics and label', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            text: 'Click Me',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Click Me'), findsOneWidget);

    // This should fail currently
    expect(
      tester.getSemantics(find.text('Click Me')),
      matchesSemantics(
        isButton: true,
        label: 'Click Me',
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
        isFocusable: true,
      ),
    );
  });

  testWidgets('AnimatedButton is disabled when loading', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            text: 'Submit',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Can't easily test semantics here without a stable finder for the button wrapper
    // But once we implement Semantics, we can find it by type Semantics.
  });
}
