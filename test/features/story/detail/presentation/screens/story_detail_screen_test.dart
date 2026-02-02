import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:historybox/features/story/detail/presentation/screens/story_detail_screen.dart';
import 'package:historybox/services/models/firebase/story_model.dart';
import 'package:historybox/services/models/network/result.dart';
import 'package:historybox/shared/services/story_service.dart';
import 'package:historybox/services/advert/ad_service.dart';
import 'package:historybox/core/translations/l10n/app_localizations.dart';

// Manual Fakes using Fake from flutter_test
class FakeStoryService extends Fake implements StoryService {
  StoryModel? storyToReturn;
  bool toggleSuccess = true;
  bool lastToggleValue = false;

  @override
  Future<Result<StoryModel, Exception>> getStory(String storyId) async {
    if (storyToReturn != null) {
      return Success(storyToReturn!);
    }
    return Failure(Exception('Not found'));
  }

  @override
  Future<Result<void, Exception>> toggleFavorite(String storyId, bool isFavorite) async {
    lastToggleValue = isFavorite;
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    if (toggleSuccess) {
      if (storyToReturn != null) {
         storyToReturn = storyToReturn!.copyWith(isFavorite: isFavorite);
      }
      return const Success(null);
    }
    return Failure(Exception('Failed'));
  }
}

class FakeAdService extends Fake implements AdService {
  @override
  Future<void> showInterstitialAd() async {
    // Do nothing
  }
}

void main() {
  final injector = GetIt.instance;
  late FakeStoryService fakeStoryService;
  late FakeAdService fakeAdService;

  setUp(() {
    fakeStoryService = FakeStoryService();
    fakeAdService = FakeAdService();

    // Register mocks
    injector.registerSingleton<StoryService>(fakeStoryService);
    injector.registerSingleton<AdService>(fakeAdService);
  });

  tearDown(() {
    injector.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'), // Force English for assertions
      home: const StoryDetailScreen(storyId: 'test-id'),
    );
  }

  testWidgets('FAB toggles favorite icon and tooltip optimistically', (WidgetTester tester) async {
    // Set a large screen size to ensure everything is visible
    tester.view.physicalSize = const Size(2400, 2400);
    tester.view.physicalSize = const Size(2400, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    // Setup initial story
    fakeStoryService.storyToReturn = StoryModel(
      id: 'test-id',
      title: 'Test Story',
      content: 'Once upon a time...',
      category: 'category_adventure',
      ageGroup: '6-8',
      userId: 'user-id',
      createdAt: DateTime.now(),
      isFavorite: false,
    );

    await tester.pumpWidget(createWidgetUnderTest());
    // Pump enough time for story load AND FAB entrance animation
    await tester.pump(const Duration(milliseconds: 500));

    // Verify initial state
    expect(find.text('Test Story'), findsAtLeastNWidgets(1));
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    // Find by tooltip to ensure it's correct and interactable
    final fabFinder = find.byTooltip('Add to Favorites');
    expect(fabFinder, findsOneWidget);

    // Tap FAB (Manual invocation to bypass potential hit-test issues in test env)
    // Use byType to get the widget instance, as byTooltip returns the Tooltip widget
    final fabWidgetFinder = find.byType(FloatingActionButton);
    tester.widget<FloatingActionButton>(fabWidgetFinder).onPressed!();
    await tester.pump(); // Start animation/update (Optimistic)

    // Verify optimistic update
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);

    // Fast forward network request
    await tester.pump(const Duration(milliseconds: 150));

    // Update tooltip verification
    final fabAfter = tester.widget<FloatingActionButton>(fabWidgetFinder);
    expect(fabAfter.tooltip, 'Remove from Favorites');

    // Verify service call
    expect(fakeStoryService.lastToggleValue, true);
  });

  testWidgets('FAB reverts state on failure', (WidgetTester tester) async {
    // Set a large screen size to ensure everything is visible
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    // Setup initial story
    fakeStoryService.storyToReturn = StoryModel(
      id: 'test-id',
      title: 'Test Story',
      content: 'Once upon a time...',
      category: 'Macera',
      ageGroup: '6-8',
      userId: 'user-id',
      createdAt: DateTime.now(),
      isFavorite: false,
    );
    fakeStoryService.toggleSuccess = false; // Fail request

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 500)); // Load story

    // Tap FAB
    final fabFinder = find.byType(FloatingActionButton);
    tester.widget<FloatingActionButton>(fabFinder).onPressed!();
    await tester.pump(); // Optimistic update

    // It should briefly be favorite
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    // Finish async gap (network delay + failure handling)
    await tester.pump(const Duration(milliseconds: 150));

    // Should revert
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    // Should show error snackbar
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('An error occurred'), findsOneWidget);
  });
}
