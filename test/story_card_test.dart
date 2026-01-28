import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:historybox/shared/widgets/story_card.dart';
import 'package:historybox/core/translations/l10n/app_localizations.dart';

void main() {
  testWidgets('StoryCard shows correct favorite tooltip', (WidgetTester tester) async {
    // Create a StoryCard
    final card = StoryCard(
      title: 'Test Story',
      category: 'masal', // Using a lowercase key as seen in similar apps, or fallback will work
      ageGroup: '3-5',
      createdAt: DateTime.now(),
      isFavorite: false, // Initially not favorite
      onTap: () {},
      onFavoriteToggle: () {},
    );

    // Pump the widget into the tree
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'), // Force English for testing
        home: Scaffold(
          body: card,
        ),
      ),
    );

    // Wait for localizations to load
    await tester.pumpAndSettle();

    // Verify initial state (Add to Favorites)
    final iconButton = find.byType(IconButton);
    expect(iconButton, findsOneWidget);

    // Check tooltip
    final button = tester.widget<IconButton>(iconButton);
    expect(button.tooltip, 'Add to Favorites');

    // Rebuild with isFavorite: true
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: StoryCard(
            title: 'Test Story',
            category: 'masal',
            ageGroup: '3-5',
            createdAt: DateTime.now(),
            isFavorite: true, // Now favorite
            onTap: () {},
            onFavoriteToggle: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify new state (Remove from Favorites)
    final iconButton2 = find.byType(IconButton);
    final button2 = tester.widget<IconButton>(iconButton2);
    expect(button2.tooltip, 'Remove from Favorites');
  });
}
