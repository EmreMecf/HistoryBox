// lib/services/apis/gemini_api_client.dart
//
// 🤖 Google Gemini istemcisi — metin ve görsel (vision) üretimi.
// OpenAI ChatGPT yerine kullanılır.
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/utils/logger.dart';

class GeminiApiClient {
  final Dio _dio;
  GeminiApiClient(this._dio);

  // Maliyet koruması: bir masal en fazla bu kadar çıktı token'ı üretir
  // (~1500 kelime; 15 dakikalık masala fazlasıyla yeter, kaçak maliyeti önler).
  static const int maxOutputTokens = 2048;

  String get _model => dotenv.maybeGet('GEMINI_MODEL') ?? 'gemini-2.0-flash';

  /// Metinden metin üretir.
  Future<String> generateText(String prompt) async {
    AppLogger.debug('Gemini metin isteği', tag: 'Gemini');
    final response = await _dio.post(
      '/models/$_model:generateContent',
      data: {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'maxOutputTokens': maxOutputTokens},
      },
    );
    return _extractText(response.data);
  }

  /// Görsel (çizim, base64) + metinden metin üretir (çoklu-mod).
  Future<String> generateTextWithImage(String prompt, String base64Image) async {
    AppLogger.debug('Gemini vision isteği', tag: 'Gemini');
    final response = await _dio.post(
      '/models/$_model:generateContent',
      data: {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
            ],
          },
        ],
        'generationConfig': {'maxOutputTokens': maxOutputTokens},
      },
    );
    return _extractText(response.data);
  }

  String _extractText(dynamic data) {
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini yanıt vermedi (güvenlik filtresi olabilir)');
    }
    final parts = candidates.first['content']?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw Exception('Gemini boş yanıt döndürdü');
    }
    final buffer = StringBuffer();
    for (final part in parts) {
      final text = part['text'];
      if (text is String) buffer.write(text);
    }
    return buffer.toString();
  }
}
