import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:historybox/shared/widgets/animated_button.dart';

void main() {
  testWidgets('AnimatedButton has Semantics', (WidgetTester tester) async {
    // Build the widget
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

    // Verify Semantics
    expect(find.bySemanticsLabel('Click Me'), findsOneWidget);

    final semanticsFinder = find.byWidgetPredicate((widget) =>
      widget is Semantics && widget.properties.label == 'Click Me');
    expect(semanticsFinder, findsOneWidget);

    final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
    expect(semanticsWidget.properties.button, isTrue);
    expect(semanticsWidget.properties.enabled, isTrue);
    expect(semanticsWidget.excludeSemantics, isTrue);
  });

  testWidgets('AnimatedButton Semantics disabled when loading', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            text: 'Loading',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      ),
    );

    // Verify Semantics
    final semanticsFinder = find.byWidgetPredicate((widget) =>
      widget is Semantics && widget.properties.label == 'Loading');
    expect(semanticsFinder, findsOneWidget);

    final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
    expect(semanticsWidget.properties.button, isTrue);
    // When loading, enabled should be false
    expect(semanticsWidget.properties.enabled, isFalse);
  });
}
