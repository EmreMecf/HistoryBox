import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:historybox/features/story/detail/presentation/screens/story_detail_screen.dart';
import 'package:historybox/services/models/firebase/story_model.dart';
import 'package:historybox/shared/services/story_service.dart';
import 'package:historybox/services/advert/ad_service.dart';
import 'package:historybox/services/models/network/result.dart';
import 'package:historybox/core/translations/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Fake implementations
class FakeStoryService implements StoryService {
  final StoryModel story;
  bool toggleCalled = false;

  FakeStoryService(this.story);

  @override
  Future<Result<StoryModel, Exception>> getStory(String id) async {
    return Success(story);
  }

  @override
  Future<Result<void, Exception>> toggleFavorite(String storyId, bool isFavorite) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 50));
    toggleCalled = true;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAdService implements AdService {
  @override
  Future<void> showInterstitialAd() async {
    return;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeStoryService fakeStoryService;
  late FakeAdService fakeAdService;

  final testStory = StoryModel(
    id: '1',
    title: 'Test Story',
    content: 'Once upon a time...',
    category: 'adventure',
    ageGroup: '3-5',
    userId: 'user1',
    createdAt: DateTime.now(),
    isFavorite: false,
  );

  setUp(() {
    fakeStoryService = FakeStoryService(testStory);
    fakeAdService = FakeAdService();

    // Reset injector
    GetIt.instance.reset();

    // Register fakes
    GetIt.instance.registerSingleton<StoryService>(fakeStoryService);
    GetIt.instance.registerSingleton<AdService>(fakeAdService);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const StoryDetailScreen(storyId: '1'),
    );
  }

  testWidgets('StoryDetailScreen displays story and toggles favorite optimistically', (WidgetTester tester) async {
    // Set surface size to avoid overflow in tests
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createWidgetUnderTest());

    // Initial load
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading

    expect(find.text('Test Story'), findsWidgets);

    // Check initial favorite state (unfavorited)
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    // Check tooltip for "Add to Favorites"
    final fab = tester.widget<FloatingActionButton>(fabFinder);
    expect(fab.tooltip, 'Add to Favorites');

    // Verify icon is border
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    // Tap to toggle
    final fabWidget = tester.widget<FloatingActionButton>(fabFinder);
    fabWidget.onPressed!();

    // Pump a short duration to trigger setState but BEFORE service call completes (Optimistic update)
    await tester.pump(const Duration(milliseconds: 10));

    // Verify optimistic state (icon should change to filled)
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    // Verify tooltip changed optimistically
    final fabOptimistic = tester.widget<FloatingActionButton>(fabFinder);
    expect(fabOptimistic.tooltip, 'Remove from Favorites');

    // Wait for service call to complete
    await tester.pump(const Duration(milliseconds: 100));

    // Verify service was called
    expect(fakeStoryService.toggleCalled, true);

    // Cleanup
    addTearDown(() => tester.view.resetPhysicalSize());
  });
}
