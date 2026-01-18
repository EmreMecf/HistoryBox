import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/translations/l10n/app_localizations.dart';

// Core
import 'core/thema/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/configs/historybox_cache_manager.dart';
import 'firebase_options.dart';

// Services & DI
import 'services/advert/ad_service.dart';
import 'services/injector.dart';
import 'services/navigation/navigation.dart';

// ViewModels
import 'viewmodel/thema_view_model.dart';
import 'viewmodel/token_view_model.dart';
import 'viewmodel/profile_view_model.dart';
import 'viewmodel/sign_out_view_model.dart';
import 'viewmodel/language_view_model.dart';
import 'features/auth/presentation/viewmodels/auth_view_model.dart';
import 'features/home/presentation/viewmodels/home_view_model.dart';
import 'features/story/create/presentation/viewmodels/story_create_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Firebase initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup dependency injection
  await initInjector();

  // Clear cache on startup
  await HistoryBoxCacheManager.instance.clearCache();

  // Initialize ads
  final adService = AdService();
  await adService.initialize(enableAds: !kDebugMode);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => injector<TokenViewModel>()..loadTokens(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel()..loadUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) => injector<SignOutViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => injector<AuthViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => injector<HomeViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (_) => injector<StoryCreateViewModel>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeViewModel, LanguageViewModel>(
      builder: (context, themeViewModel, languageViewModel, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          routerConfig: injector<NavigationService>().router,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeViewModel.themeMode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('tr', ''),
          ],
          locale: languageViewModel.currentLocale,
        );
      },
    );
  }
}