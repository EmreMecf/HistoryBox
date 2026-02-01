import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:historybox/core/translations/l10n/app_localizations.dart';
import 'package:historybox/shared/widgets/story_card.dart';

void main() {
  group('StoryCard', () {
    testWidgets('shows correct tooltip when not favorite', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: StoryCard(
              title: 'Test Story',
              category: 'Adventure',
              ageGroup: '3-5 years',
              createdAt: DateTime.now(),
              isFavorite: false,
              onTap: () {},
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      // Wait for localizations to load if needed (usually synchronous in tests)
      await tester.pumpAndSettle();

      final iconButtonFinder = find.byType(IconButton);
      expect(iconButtonFinder, findsOneWidget);

      final iconButton = tester.widget<IconButton>(iconButtonFinder);
      expect(iconButton.tooltip, 'Add to Favorites');
    });

    testWidgets('shows correct tooltip when favorite', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: StoryCard(
              title: 'Test Story',
              category: 'Adventure',
              ageGroup: '3-5 years',
              createdAt: DateTime.now(),
              isFavorite: true,
              onTap: () {},
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final iconButtonFinder = find.byType(IconButton);
      expect(iconButtonFinder, findsOneWidget);

      final iconButton = tester.widget<IconButton>(iconButtonFinder);
      expect(iconButton.tooltip, 'Remove from Favorites');
    });
  });
}
