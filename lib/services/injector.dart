import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Services
import 'apis/chat_gpt_api_client.dart';
import 'apis/purchase_service.dart';
import 'advert/ad_service.dart';
import 'firebase/firebase_auth_service.dart';
import 'firebase/token_service.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/token_repository.dart';
import 'navigation/navigation.dart';
import '../shared/services/firestore_service.dart';
import '../shared/services/story_service.dart';
import '../shared/services/ai_story_service.dart';

// ViewModels
import '../viewmodel/thema_view_model.dart';
import '../viewmodel/sign_out_view_model.dart';
import '../features/auth/presentation/viewmodels/auth_view_model.dart';
import '../features/home/presentation/viewmodels/home_view_model.dart';
import '../features/story/create/presentation/viewmodels/story_create_view_model.dart';
import '../viewmodel/token_view_model.dart';

final injector = GetIt.instance;

Future<void> initInjector() async {
  // Dio instance for ChatGPT
  final chatGptDio = Dio(
    BaseOptions(
      baseUrl: dotenv.get('CHATGPT_BASE_URL'),
      headers: {
        "Authorization": "Bearer ${dotenv.get('CHATGPT_SECRET_KEY')}",
        "Content-Type": "application/json",
        "OpenAI-Organization": dotenv.get('CHATGPT_ORGANIZATION'),
        "OpenAI-Project": dotenv.get('CHATGPT_PROJECT'),
      },
    ),
  );

  chatGptDio.interceptors.add(
    PrettyDioLogger(
      requestHeader: false,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
      enabled: kDebugMode,
    ),
  );

  // Packages
  injector.registerLazySingleton<Dio>(
    () => chatGptDio,
    instanceName: "ChatGPTDio",
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
  injector.registerFactory<ChatGptApiClient>(
    () => ChatGptApiClient(injector(instanceName: "ChatGPTDio")),
  );
  injector.registerFactory<TokenService>(
    () => TokenService(injector<FirebaseFirestore>()),
  );
  injector.registerFactory<AdService>(() => AdService());
  injector.registerLazySingleton(() => PurchaseService(
        injector<TokenRepository>(),
        FirebaseAuth.instance,
      ));

  // Repositories
  injector.registerLazySingleton<FirebaseAuthRepository>(
    () => FirebaseAuthRepository(injector()),
  );
  injector.registerFactory<TokenRepository>(
    () => TokenRepository(injector()),
  );

  // Business Services
  injector.registerLazySingleton(() => StoryService(injector()));
  injector.registerLazySingleton(() => AiStoryService(injector()));

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