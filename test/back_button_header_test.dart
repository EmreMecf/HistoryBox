import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:historybox/core/widgets/back_button_header.dart';

void main() {
  testWidgets('BackButtonHeader has correct tooltip', (WidgetTester tester) async {
    // Build the widget tree
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BackButtonHeader(title: 'Test Title'),
        ),
      ),
    );

    // Verify that the IconButton exists
    expect(find.byType(IconButton), findsOneWidget);

    // Verify that the tooltip is present and correct (English default)
    final iconButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(iconButton.tooltip, isNotNull);
    expect(iconButton.tooltip, 'Back');
  });
}
