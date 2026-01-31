import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:historybox/shared/widgets/story_card.dart';
import 'package:historybox/core/translations/l10n/app_localizations.dart';

void main() {
  testWidgets('StoryCard has favorite button with correct tooltip', (WidgetTester tester) async {
    // We need to wrap with MaterialApp to provide Localizations and Theme
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'), // Test English first
        home: Scaffold(
          body: StoryCard(
            title: 'Test Story',
            category: 'Masal', // Must be a valid key in AppColors.categoryColors
            ageGroup: '3-5 Yaş',
            createdAt: DateTime.now(),
            isFavorite: false, // Start with not favorite
            onTap: () {},
            onFavoriteToggle: () {},
            preview: 'Preview text',
          ),
        ),
      ),
    );

    // Wait for localizations to load if needed
    await tester.pumpAndSettle();

    // Find the favorite button
    final favoriteButtonFinder = find.byType(IconButton);
    expect(favoriteButtonFinder, findsOneWidget);

    // Check tooltip for !isFavorite (Add)
    // In English, it should be "Favorite" (from ARB)
    expect(
      find.byTooltip('Favorite'),
      findsOneWidget,
      reason: 'Should show "Favorite" tooltip when not favorite in English',
    );

    // Now test with isFavorite = true
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: StoryCard(
            title: 'Test Story',
            category: 'Masal',
            ageGroup: '3-5 Yaş',
            createdAt: DateTime.now(),
            isFavorite: true, // Now favorite
            onTap: () {},
            onFavoriteToggle: () {},
            preview: 'Preview text',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check tooltip for isFavorite (Remove)
    // In English fallback logic: "Remove from Favorites"
    expect(
      find.byTooltip('Remove from Favorites'),
      findsOneWidget,
      reason: 'Should show "Remove from Favorites" tooltip when favorite in English',
    );

    // Test Turkish Locale
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        home: Scaffold(
          body: StoryCard(
            title: 'Test Story',
            category: 'Masal',
            ageGroup: '3-5 Yaş',
            createdAt: DateTime.now(),
            isFavorite: false,
            onTap: () {},
            onFavoriteToggle: () {},
            preview: 'Preview text',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // !isFavorite in TR -> "Favorilere Ekle"
    expect(
      find.byTooltip('Favorilere Ekle'),
      findsOneWidget,
      reason: 'Should show "Favorilere Ekle" tooltip when not favorite in Turkish',
    );

     // Test Turkish Locale isFavorite=true
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        home: Scaffold(
          body: StoryCard(
            title: 'Test Story',
            category: 'Masal',
            ageGroup: '3-5 Yaş',
            createdAt: DateTime.now(),
            isFavorite: true,
            onTap: () {},
            onFavoriteToggle: () {},
            preview: 'Preview text',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // isFavorite in TR -> "Favorilerden Çıkar" (Hardcoded fallback)
    expect(
      find.byTooltip('Favorilerden Çıkar'),
      findsOneWidget,
      reason: 'Should show "Favorilerden Çıkar" tooltip when favorite in Turkish',
    );
  });
}
