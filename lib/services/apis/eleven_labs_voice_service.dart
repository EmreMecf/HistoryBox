// lib/services/apis/eleven_labs_voice_service.dart
//
// 🗣️ ElevenLabs Instant Voice Cloning — ebeveynin sesini klonlar.
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/utils/logger.dart';

class ElevenLabsVoiceService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.elevenlabs.io/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
    ),
  );

  String get _apiKey => dotenv.maybeGet('ELEVENLABS_API_KEY') ?? '';

  bool get isConfigured =>
      _apiKey.isNotEmpty && !_apiKey.toLowerCase().contains('your_');

  /// Verilen ses kaydından bir klon ses oluşturur, voice_id döndürür.
  /// (ElevenLabs ücretli plan gerektirir.)
  Future<String?> cloneVoice({
    required String name,
    required String filePath,
  }) async {
    if (!isConfigured) return null;
    try {
      final form = FormData.fromMap({
        'name': name,
        'description': 'HistoryBox - $name (ebeveyn sesi)',
        'files': [
          await MultipartFile.fromFile(filePath, filename: 'sample.m4a'),
        ],
      });

      final response = await _dio.post(
        '/voices/add',
        data: form,
        options: Options(headers: {'xi-api-key': _apiKey}),
      );

      final voiceId = response.data['voice_id'] as String?;
      AppLogger.success('Ses klonlandı: $voiceId', tag: 'VoiceClone');
      return voiceId;
    } catch (e) {
      AppLogger.error('Ses klonlama başarısız', tag: 'VoiceClone', error: e);
      return null;
    }
  }

  /// Klonlanan sesi ElevenLabs'tan siler.
  Future<void> deleteVoice(String voiceId) async {
    if (!isConfigured) return;
    try {
      await _dio.delete(
        '/voices/$voiceId',
        options: Options(headers: {'xi-api-key': _apiKey}),
      );
    } catch (e) {
      AppLogger.error('Ses silinemedi', tag: 'VoiceClone', error: e);
    }
  }
}
