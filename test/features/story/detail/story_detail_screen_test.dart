import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:historybox/features/story/detail/presentation/screens/story_detail_screen.dart';
import 'package:historybox/services/advert/ad_service.dart';
import 'package:historybox/services/models/firebase/story_model.dart';
import 'package:historybox/services/models/network/result.dart';
import 'package:historybox/shared/services/story_service.dart';
import 'package:historybox/core/core.dart';

// Mock StoryService implements StoryService to avoid super constructor
// which triggers Firebase initialization.
class MockStoryService implements StoryService {
  bool toggleFavoriteCalled = false;
  String? lastStoryId;
  bool? lastIsFavorite;

  @override
  Future<Result<StoryModel, Exception>> getStory(String storyId) async {
    return Success(StoryModel(
      id: storyId,
      title: 'Test Story',
      content: 'Content',
      category: 'Adventure',
      ageGroup: '3-5',
      userId: 'user1',
      createdAt: DateTime.now(),
      isFavorite: false,
    ));
  }

  @override
  Future<Result<void, Exception>> toggleFavorite(String storyId, bool isFavorite) async {
    toggleFavoriteCalled = true;
    lastStoryId = storyId;
    lastIsFavorite = isFavorite;
    return const Success(null);
  }

  // Stub other methods
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

// Mock AdService
class MockAdService implements AdService {
  @override
  Future<void> showInterstitialAd() async {}

  @override
  Future<void> initialize({bool enableAds = true}) async {}

  @override
  Future<Widget?> loadBannerAd() async { return null; }

  @override
  Future<void> showRewardedAd({required Function onRewarded}) async {}

  @override
  void dispose() {}
}

void main() {
  late MockStoryService mockStoryService;
  late MockAdService mockAdService;

  setUp(() {
    mockStoryService = MockStoryService();
    mockAdService = MockAdService();

    final getIt = GetIt.instance;
    getIt.reset();

    getIt.registerSingleton<StoryService>(mockStoryService);
    getIt.registerFactory<AdService>(() => mockAdService);
  });

  testWidgets('StoryDetailScreen toggle favorite optimistic update', (WidgetTester tester) async {
    // Pump the widget
    await tester.pumpWidget(const MaterialApp(
      home: StoryDetailScreen(storyId: 'test-story-1'),
    ));

    // Wait for the story to load
    // pumpAndSettle fails due to infinite background animation
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify initial state
    expect(find.text('Test Story'), findsWidgets);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    // Tap the favorite button
    await tester.tap(find.byType(FloatingActionButton));

    // Pump to process the tap and optimistic update (no wait for future)
    await tester.pump();

    // Verify UI updated immediately (optimistic)
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);

    // Verify tooltip
    final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
    expect(fab.tooltip, 'Favorilerden Çıkar');

    // Verify service called
    expect(mockStoryService.toggleFavoriteCalled, isTrue);
    expect(mockStoryService.lastStoryId, 'test-story-1');
    expect(mockStoryService.lastIsFavorite, isTrue);

    // Verify SnackBar
    expect(find.text('Favorilere eklendi'), findsOneWidget);

    // Allow SnackBar animation to start/finish logic without waiting for background
    await tester.pump();
  });
}
