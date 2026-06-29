import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Services
import 'apis/gemini_api_client.dart';
import 'apis/story_image_service.dart';
import 'apis/purchase_service.dart';
import 'apis/eleven_labs_tts_service.dart';
import 'apis/image_gen_service.dart';
import 'apis/moderation_service.dart';
import 'apis/eleven_labs_voice_service.dart';
import '../shared/services/voice_profile_service.dart';
import 'advert/ad_service.dart';
import 'firebase/firebase_auth_service.dart';
import 'firebase/token_service.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/token_repository.dart';
import 'navigation/navigation.dart';
import '../shared/services/firestore_service.dart';
import '../shared/services/story_service.dart';
import '../shared/services/ai_story_service.dart';
import '../shared/services/community_service.dart';
import '../shared/services/child_profile_service.dart';
import '../shared/services/parental_controls_service.dart';
import '../shared/services/print_order_service.dart';
import '../features/story/video/story_video_service.dart';

// ViewModels
import '../viewmodel/thema_view_model.dart';
import '../viewmodel/sign_out_view_model.dart';
import '../features/auth/presentation/viewmodels/auth_view_model.dart';
import '../features/home/presentation/viewmodels/home_view_model.dart';
import '../features/story/create/presentation/viewmodels/story_create_view_model.dart';
import '../viewmodel/token_view_model.dart';

final injector = GetIt.instance;

Future<void> initInjector() async {
  // Dio instance for Gemini
  final geminiDio = Dio(
    BaseOptions(
      baseUrl: dotenv.maybeGet('GEMINI_BASE_URL') ??
          'https://generativelanguage.googleapis.com/v1beta',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': dotenv.maybeGet('GEMINI_API_KEY') ?? '',
      },
    ),
  );
  geminiDio.interceptors.add(
    PrettyDioLogger(
      requestBody: true,
      responseBody: true,
      compact: true,
      maxWidth: 90,
      enabled: kDebugMode,
    ),
  );

  // Packages
  injector.registerLazySingleton<Dio>(
    () => geminiDio,
    instanceName: "GeminiDio",
  );
  injector.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  injector.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  // Core Services
  injector.registerLazySingleton(() => FirebaseAuthService());
  injector.registerLazySingleton(() => FirestoreService());
  injector.registerFactory<GeminiApiClient>(
    () => GeminiApiClient(injector(instanceName: "GeminiDio")),
  );
  injector.registerFactory<TokenService>(
    () => TokenService(injector<FirebaseFirestore>()),
  );
  injector.registerFactory<AdService>(() => AdService());
  injector.registerLazySingleton(() => PurchaseService(
        injector<TokenRepository>(),
        FirebaseAuth.instance,
      ));
  injector.registerLazySingleton(() => ElevenLabsTtsService());
  injector.registerLazySingleton(
    () => ImageGenService(injector(instanceName: "GeminiDio")),
  );
  injector.registerLazySingleton(
    () => ModerationService(injector<GeminiApiClient>()),
  );
  injector.registerLazySingleton(
    () => StoryVideoService(
      injector<ElevenLabsTtsService>(),
      injector<ImageGenService>(),
    ),
  );

  // Repositories
  injector.registerLazySingleton<FirebaseAuthRepository>(
    () => FirebaseAuthRepository(injector()),
  );
  injector.registerFactory<TokenRepository>(
    () => TokenRepository(injector()),
  );

  // Business Services
  injector.registerLazySingleton(() => StoryService(injector()));
  injector.registerLazySingleton(
    () => AiStoryService(injector<GeminiApiClient>()),
  );
  injector.registerLazySingleton(() => CommunityService());
  injector.registerLazySingleton(() => ChildProfileService());
  injector.registerLazySingleton(() => ParentalControlsService());
  injector.registerLazySingleton(() => ElevenLabsVoiceService());
  injector.registerLazySingleton(() => VoiceProfileService());
  injector.registerLazySingleton(() => PrintOrderService());
  injector.registerLazySingleton(() => StoryImageService());

  // Navigation
  injector.registerLazySingleton(() => NavigationService(injector()));

  // ViewModels
  injector.registerLazySingleton<ThemeViewModel>(() => ThemeViewModel());
  injector.registerFactory<SignOutViewModel>(
    () => SignOutViewModel(injector(), injector()),
  );
  injector.registerFactory<AuthViewModel>(
    () => AuthViewModel(injector(), injector()),
  );
  injector.registerFactory<HomeViewModel>(
    () => HomeViewModel(injector()),
  );
  injector.registerFactory<StoryCreateViewModel>(
    () => StoryCreateViewModel(injector(), injector()),
  );
  injector.registerFactory<TokenViewModel>(
    () => TokenViewModel(
      injector<TokenRepository>(),
      FirebaseAuth.instance,
      injector<PurchaseService>(),
    ),
  );
}