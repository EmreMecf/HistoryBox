import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:historybox/shared/widgets/story_card.dart';
import 'package:historybox/core/translations/l10n/app_localizations.dart';

void main() {
  testWidgets('StoryCard tooltip test (English)', (WidgetTester tester) async {
    // 1. Test "not favorite" state (Add to Favorites)
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: StoryCard(
            title: 'Test Story',
            category: 'Adventure',
            ageGroup: '3-5',
            createdAt: DateTime.now(),
            isFavorite: false,
            onTap: () {},
            onFavoriteToggle: () {},
          ),
        ),
      ),
    );

    // Initial state: Not favorite.
    // Expect tooltip to be "Favorite" (based on app_en.arb)
    expect(find.byTooltip('Favorite'), findsOneWidget);

    // 2. Test "favorite" state (Remove from Favorites)
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: StoryCard(
            title: 'Test Story',
            category: 'Adventure',
            ageGroup: '3-5',
            createdAt: DateTime.now(),
            isFavorite: true,
            onTap: () {},
            onFavoriteToggle: () {},
          ),
        ),
      ),
    );

    // Favorite state: Should be "Remove from Favorites" (fallback)
    expect(find.byTooltip('Remove from Favorites'), findsOneWidget);
  });

  testWidgets('StoryCard tooltip test (Turkish)', (WidgetTester tester) async {
    // 1. Test "not favorite" state (Add to Favorites)
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        home: Scaffold(
          body: StoryCard(
            title: 'Test Hikaye',
            category: 'Adventure',
            ageGroup: '3-5',
            createdAt: DateTime.now(),
            isFavorite: false,
            onTap: () {},
            onFavoriteToggle: () {},
          ),
        ),
      ),
    );

    // Initial state: Not favorite.
    // Expect tooltip to be "Favorilere Ekle" (based on app_tr.arb)
    expect(find.byTooltip('Favorilere Ekle'), findsOneWidget);

    // 2. Test "favorite" state (Remove from Favorites)
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        home: Scaffold(
          body: StoryCard(
            title: 'Test Hikaye',
            category: 'Adventure',
            ageGroup: '3-5',
            createdAt: DateTime.now(),
            isFavorite: true,
            onTap: () {},
            onFavoriteToggle: () {},
          ),
        ),
      ),
    );

    // Favorite state: Should be "Favorilerden Çıkar" (fallback)
    expect(find.byTooltip('Favorilerden Çıkar'), findsOneWidget);
  });
}
