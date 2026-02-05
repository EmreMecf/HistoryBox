import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:historybox/core/translations/l10n/app_localizations.dart';
import 'package:historybox/features/story/detail/presentation/screens/story_detail_screen.dart';
import 'package:historybox/services/advert/ad_service.dart';
import 'package:historybox/services/injector.dart';
import 'package:historybox/services/models/firebase/story_model.dart';
import 'package:historybox/services/models/network/result.dart';
import 'package:historybox/shared/services/story_service.dart';

// Fakes
class FakeStoryService implements StoryService {
  StoryModel? storyToReturn;
  bool toggleCalled = false;
  bool lastToggleValue = false;

  @override
  Future<Result<StoryModel, Exception>> getStory(String storyId) async {
    if (storyToReturn != null) {
      return Success(storyToReturn!);
    }
    return Failure(Exception('Story not found'));
  }

  @override
  Future<Result<void, Exception>> toggleFavorite(String storyId, bool isFavorite) async {
    toggleCalled = true;
    lastToggleValue = isFavorite;
    if (storyToReturn != null) {
       storyToReturn = storyToReturn!.copyWith(isFavorite: isFavorite);
    }
    return const Success(null);
  }

  @override
  Future<Result<String, Exception>> createStory({required String title, required String content, required String category, required String ageGroup, required String userId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> deleteStory(String storyId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<StoryModel>> getFavoriteStories(String userId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<StoryModel>> getRecentStories({int limit = 10}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<StoryModel>> getStoriesByAgeGroup(String ageGroup) {
    throw UnimplementedError();
  }

  @override
  Stream<List<StoryModel>> getStoriesByCategory(String category) {
    throw UnimplementedError();
  }

  @override
  Stream<List<StoryModel>> getUserStories(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<StoryModel>, Exception>> searchStories(String query, String userId) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> updateStory(String storyId, Map<String, dynamic> updates) {
    throw UnimplementedError();
  }
}

class FakeAdService implements AdService {
  @override
  Future<void> showInterstitialAd() async {
    // No-op
  }

  @override
  Future<void> initialize({bool enableAds = true}) async {}

  @override
  Future<Widget?> loadBannerAd() async => null;

  @override
  Future<void> showRewardedAd({required Function onRewarded}) async {}

  @override
  void dispose() {}
}

void main() {
  late FakeStoryService fakeStoryService;
  late FakeAdService fakeAdService;

  setUp(() {
    fakeStoryService = FakeStoryService();
    fakeAdService = FakeAdService();

    injector.allowReassignment = true;
    injector.registerSingleton<StoryService>(fakeStoryService);
    injector.registerSingleton<AdService>(fakeAdService);
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StoryDetailScreen(storyId: 'test-story-id'),
    );
  }

  testWidgets('StoryDetailScreen loads story and toggles favorite', (WidgetTester tester) async {
    // Arrange
    final story = StoryModel(
      id: 'test-story-id',
      title: 'Test Story',
      content: 'Once upon a time...',
      category: 'Fairy Tale',
      ageGroup: '3-5',
      userId: 'user1',
      createdAt: DateTime.now(),
      isFavorite: false,
    );
    fakeStoryService.storyToReturn = story;

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading

    // Verify initial state
    expect(find.text('Test Story'), findsAtLeastNWidgets(1));
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    // Tap favorite
    // await tester.tap(find.byType(FloatingActionButton));
    final fabBefore = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    fabBefore.onPressed!();

    await tester.pump(); // Rebuild for optimistic UI

    // Verify optimistic update
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(fakeStoryService.toggleCalled, isTrue);
    expect(fakeStoryService.lastToggleValue, isTrue);

    // Verify tooltip
    final fabAfter = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    // Default locale is English in tests usually
    expect(fabAfter.tooltip, 'Remove from Favorites');
  });
}
