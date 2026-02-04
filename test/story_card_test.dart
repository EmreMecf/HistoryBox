import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:historybox/shared/widgets/story_card.dart';
import 'package:historybox/core/translations/l10n/app_localizations.dart';

void main() {
  testWidgets('StoryCard favorite button has correct tooltip (Add)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tr')],
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

    await tester.pumpAndSettle();

    // Expect to find "Add to Favorites" tooltip
    expect(find.byTooltip('Add to Favorites'), findsOneWidget);
  });

  testWidgets('StoryCard favorite button has correct tooltip (Remove)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tr')],
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

    await tester.pumpAndSettle();

    // Expect to find "Remove from Favorites" tooltip
    expect(find.byTooltip('Remove from Favorites'), findsOneWidget);
  });
}
