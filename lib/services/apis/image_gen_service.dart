// lib/services/apis/image_gen_service.dart
//
// 🎨 Google Imagen ile çocuk masalı sahne illüstrasyonu (premium katman).
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/utils/logger.dart';

class ImageGenService {
  final Dio _dio; // GeminiDio (generativelanguage API)
  ImageGenService(this._dio);

  String get _model =>
      dotenv.maybeGet('IMAGEN_MODEL') ?? 'imagen-3.0-generate-002';

  bool get isConfigured {
    final key = dotenv.maybeGet('GEMINI_API_KEY') ?? '';
    return key.isNotEmpty && !key.toLowerCase().contains('your_');
  }

  // Tutarlı görsel stil ön eki
  static const _style =
      'Children\'s storybook illustration, soft warm dreamy colors, gentle '
      'night-time atmosphere, whimsical, cozy, no text, no words, no letters. '
      'Scene: ';

  /// Sahne metninden Imagen ile illüstrasyon üretir, yerel dosya yolunu döndürür.
  /// Hata/yapılandırma yoksa null döner (çağıran taraf temalı karta düşer).
  Future<String?> generateSceneImage(String sceneText, {required int index}) async {
    if (!isConfigured) return null;
    try {
      final prompt = _style + sceneText.trim();
      final response = await _dio.post(
        '/models/$_model:predict',
        data: {
          'instances': [
            {'prompt': prompt},
          ],
          'parameters': {
            'sampleCount': 1,
            'aspectRatio': '9:16',
          },
        },
      );

      final predictions = response.data['predictions'] as List?;
      if (predictions == null || predictions.isEmpty) return null;
      final b64 = predictions.first['bytesBase64Encoded'] as String?;
      if (b64 == null || b64.isEmpty) return null;

      final bytes = base64Decode(b64);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ai_scene_$index.png');
      await file.writeAsBytes(bytes, flush: true);
      AppLogger.success('Imagen sahne görseli üretildi: $index', tag: 'ImageGen');
      return file.path;
    } catch (e) {
      AppLogger.error('Imagen görsel üretilemedi (sahne $index)',
          tag: 'ImageGen', error: e);
      return null;
    }
  }
}
