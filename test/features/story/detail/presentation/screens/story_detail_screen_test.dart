import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:historybox/features/story/detail/presentation/screens/story_detail_screen.dart';
import 'package:historybox/services/injector.dart';
import 'package:historybox/services/models/firebase/story_model.dart';
import 'package:historybox/services/models/network/result.dart';
import 'package:historybox/shared/services/story_service.dart';
import 'package:historybox/services/advert/ad_service.dart';
import 'package:historybox/core/translations/l10n/app_localizations.dart';

// Manual Mock for StoryService
class MockStoryService implements StoryService {
  final Map<String, StoryModel> _stories = {};

  void addStory(StoryModel story) {
    _stories[story.id] = story;
  }

  @override
  Future<Result<StoryModel, Exception>> getStory(String storyId) async {
    if (_stories.containsKey(storyId)) {
      return Success(_stories[storyId]!);
    }
    return Failure(Exception('Story not found'));
  }

  @override
  Future<Result<void, Exception>> toggleFavorite(String storyId, bool isFavorite) async {
    if (_stories.containsKey(storyId)) {
      final story = _stories[storyId]!;
      _stories[storyId] = story.copyWith(isFavorite: isFavorite);
      return const Success(null);
    }
    return Failure(Exception('Story not found'));
  }

  // Stub other methods that are not used
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockStoryService mockStoryService;

  setUp(() async {
    // Reset GetIt
    await injector.reset();

    // Register Mock StoryService
    mockStoryService = MockStoryService();
    injector.registerSingleton<StoryService>(mockStoryService);

    // Disable Ads
    await AdService().initialize(enableAds: false);
  });

  tearDown(() {
    injector.reset();
  });

  testWidgets('Favorite button toggles state optimistically and has tooltip', (WidgetTester tester) async {
    // Set screen size to ensure FAB is visible
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetPhysicalSize);

    // Setup Data
    final story = StoryModel(
      id: 'story1',
      title: 'Test Story',
      content: 'Once upon a time...',
      category: 'Adventure',
      ageGroup: '3-5',
      userId: 'user1',
      createdAt: DateTime.now(),
      isFavorite: false,
    );
    mockStoryService.addStory(story);

    // Pump Widget
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StoryDetailScreen(storyId: 'story1'),
      ),
    );

    // Wait for initial load
    // We use pump(Duration) to allow animations to proceed without timeout
    await tester.pump(const Duration(seconds: 1));

    // Verify initial state
    expect(find.text('Test Story'), findsAtLeastNWidgets(1));
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    // Find FAB
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    // Tap FAB manually to bypass hit test issues with animated background
    final fab = tester.widget<FloatingActionButton>(fabFinder);
    fab.onPressed!();

    // Optimistic Update check: should happen immediately
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);

    // Verify Service call (implicit via mock state update)
    final updatedStoryResult = await mockStoryService.getStory('story1');
    final updatedStory = (updatedStoryResult as Success<StoryModel, Exception>).value;
    expect(updatedStory!.isFavorite, true);

    // Check Tooltip
    // Tooltip widget wraps the FAB content or is part of FAB
    // FloatingActionButton has a tooltip property which creates a Tooltip widget
    final tooltipFinder = find.byType(Tooltip);
    expect(tooltipFinder, findsOneWidget);
    final tooltip = tester.widget<Tooltip>(tooltipFinder);

    // This expectation will likely fail before I implement the fix, confirming the issue
    expect(tooltip.message, isNotEmpty, reason: 'FAB should have a tooltip');
  });
}
