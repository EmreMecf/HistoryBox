import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../screens/new_home_screen.dart';
import '../../screens/history_screen.dart';
import '../../screens/calendar_screen.dart';
import '../../screens/settings_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/community/presentation/screens/saved_stories_screen.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';
import '../../features/parental/presentation/screens/parental_controls_screen.dart';
import '../../features/voice/presentation/screens/voice_clone_screen.dart';
import '../../features/story/drawing/presentation/screens/drawing_story_screen.dart';
import '../../features/relax/presentation/screens/relax_screen.dart';
import '../../screens/feedback_screen.dart';
import '../../screens/profile_screen.dart';
import '../../features/story/create/presentation/screens/story_create_screen.dart';
import '../../features/story/detail/presentation/screens/story_detail_screen.dart';
import '../../features/story/list/presentation/screens/story_list_screen.dart';
import '../repositories/firebase_auth_repository.dart';

class NavigationService {
  final FirebaseAuthRepository _firebaseAuthRepository;
  late GoRouter _router;

  GoRouter get router => _router;

  NavigationService(this._firebaseAuthRepository) {
    _initRouter();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      _router.refresh();
    });
  }

  void _initRouter() {
    _router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = _firebaseAuthRepository.currentUser != null;
        final isLoginRoute = state.matchedLocation == '/login';

        // Eğer giriş yapmamışsa ve login sayfasında değilse, login'e yönlendir
        if (!isLoggedIn && !isLoginRoute) {
          return '/login';
        }

        // Eğer giriş yapmışsa ve login sayfasındaysa, home'a yönlendir
        if (isLoggedIn && isLoginRoute) {
          return '/';
        }

        return null;
      },
      routes: [
        // Login
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Home
        GoRoute(
          path: '/',
          builder: (context, state) => const NewHomeScreen(),
        ),

        // History
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),

        // Calendar
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),

        // Community (Topluluk)
        GoRoute(
          path: '/community',
          builder: (context, state) => const CommunityScreen(),
        ),

        // Saved (Kayıtlı Masallar)
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedStoriesScreen(),
        ),

        // Premium
        GoRoute(
          path: '/premium',
          builder: (context, state) => const PremiumScreen(),
        ),

        // Parental controls (Ebeveyn Kontrolleri)
        GoRoute(
          path: '/parental',
          builder: (context, state) => const ParentalControlsScreen(),
        ),

        // Voice cloning (Sesini Klonla)
        GoRoute(
          path: '/voice-clone',
          builder: (context, state) => const VoiceCloneScreen(),
        ),

        // Çizimden Masal
        GoRoute(
          path: '/drawing-story',
          builder: (context, state) => const DrawingStoryScreen(),
        ),

        // Ninni & Meditasyon
        GoRoute(
          path: '/relax',
          builder: (context, state) => const RelaxScreen(),
        ),

        // Settings
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),

        // Feedback
        GoRoute(
          path: '/feedback',
          builder: (context, state) => const FeedbackScreen(),
        ),

        // Profile
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        // Story Create
        GoRoute(
          path: '/story-create',
          builder: (context, state) => const StoryCreateScreen(),
        ),

        // Story Detail
        GoRoute(
          path: '/story-detail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return StoryDetailScreen(storyId: id);
          },
        ),

        // Story List by Category
        GoRoute(
          path: '/story-list/:category',
          builder: (context, state) {
            final category = state.pathParameters['category']!;
            return StoryListScreen(category: category);
          },
        ),
      ],
    );
  }

  void goHome() {
    _router.go('/');
  }

  void goLogin() {
    _router.go('/login');
  }
}

