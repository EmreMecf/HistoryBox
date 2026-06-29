// lib/services/apis/eleven_labs_tts_service.dart
//
// 🎙️ ElevenLabs ile stüdyo kalitesinde sesli masal anlatımı.
// `eleven_multilingual_v2` modeli Türkçe'yi doğru telaffuz eder.
// Uyku (sakin) modunda yüksek "stability" ile daha yumuşak, tekdüze bir ton.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/utils/logger.dart';

class ElevenLabsTtsService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.elevenlabs.io/v1',
      responseType: ResponseType.bytes,
      headers: {'Accept': 'audio/mpeg'},
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 90),
    ),
  );

  // Aynı metni tekrar seslendirirken API'yi yeniden çağırmamak için önbellek.
  final Map<String, String> _cache = {};

  String get _apiKey => dotenv.maybeGet('ELEVENLABS_API_KEY') ?? '';

  /// API anahtarı tanımlı mı? (placeholder ise devre dışı sayılır)
  bool get isConfigured =>
      _apiKey.isNotEmpty && !_apiKey.toLowerCase().contains('your_');

  /// Metni seslendirip oluşturulan MP3 dosyasının yolunu döndürür.
  /// [voiceIdOverride] verilirse (örn. klonlanmış ses) onu kullanır.
  /// Hata olursa exception fırlatır (çağıran taraf cihaz sesine düşebilir).
  Future<String> synthesizeToFile(
    String text, {
    required bool calm,
    String? voiceIdOverride,
  }) async {
    final voiceId = voiceIdOverride ??
        dotenv.maybeGet('ELEVENLABS_VOICE_ID') ??
        'EXAVITQu4vr4xnSDxMaL';

    final cacheKey = '${calm ? 'c' : 'n'}_${voiceId.hashCode}_${text.hashCode}';
    final cached = _cache[cacheKey];
    if (cached != null && File(cached).existsSync()) {
      return cached;
    }
    final model =
        dotenv.maybeGet('ELEVENLABS_MODEL') ?? 'eleven_multilingual_v2';

    // Uyku modu: yüksek stability + düşük style → sakin, yumuşak, tekdüze.
    final voiceSettings = calm
        ? {
            'stability': 0.85,
            'similarity_boost': 0.75,
            'style': 0.0,
            'use_speaker_boost': true,
          }
        : {
            'stability': 0.55,
            'similarity_boost': 0.80,
            'style': 0.15,
            'use_speaker_boost': true,
          };

    final data = <String, dynamic>{
      'text': text,
      'model_id': model,
      'voice_settings': voiceSettings,
    };

    // Sadece turbo/flash/v3 modelleri language_code kabul eder; multilingual_v2
    // metinden otomatik Türkçe algılar.
    final lower = model.toLowerCase();
    if (lower.contains('turbo') ||
        lower.contains('flash') ||
        lower.contains('v3')) {
      data['language_code'] = 'tr';
    }

    AppLogger.log('ElevenLabs seslendirme isteği (calm: $calm)',
        tag: 'ElevenLabs');

    final response = await _dio.post(
      '/text-to-speech/$voiceId',
      queryParameters: {'output_format': 'mp3_44100_128'},
      options: Options(
        headers: {
          'xi-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
      ),
      data: data,
    );

    final bytes = response.data as List<int>;
    if (bytes.isEmpty) {
      throw Exception('ElevenLabs boş ses yanıtı döndürdü');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/narration_$cacheKey.mp3');
    await file.writeAsBytes(bytes, flush: true);
    _cache[cacheKey] = file.path;

    AppLogger.success('ElevenLabs ses dosyası hazır (${bytes.length} bayt)',
        tag: 'ElevenLabs');
    return file.path;
  }
}
