import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:historybox/core/widgets/back_button_header.dart';

void main() {
  testWidgets('BackButtonHeader IconButton has a tooltip', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BackButtonHeader(title: 'Test Title'),
        ),
      ),
    );

    // Find the IconButton
    final iconButtonFinder = find.byType(IconButton);
    expect(iconButtonFinder, findsOneWidget);

    // Verify that the tooltip is present
    final iconButton = tester.widget<IconButton>(iconButtonFinder);
    expect(iconButton.tooltip, isNotNull, reason: "Tooltip should be present for accessibility");
    expect(iconButton.tooltip, 'Back'); // Default English localization
  });
}
