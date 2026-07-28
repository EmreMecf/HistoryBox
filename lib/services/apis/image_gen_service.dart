// lib/services/apis/image_gen_service.dart
//
// 🎨 Gemini görsel üretimi + KARAKTER TUTARLILIĞI.
// Yaklaşım: masaldan karakter tarifi çıkar → ilk sahneyi çiz (referans) →
// sonraki her sahnede referans görseli modele geri vererek AYNI karakteri koru.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/utils/logger.dart';

class ImageGenService {
  final Dio _dio; // GeminiDio (generativelanguage API)
  ImageGenService(this._dio);

  // Görsel üreten model (karakter tutarlılığı için referans görsel kabul eder)
  String get _imageModel =>
      dotenv.maybeGet('GEMINI_IMAGE_MODEL') ?? 'gemini-2.5-flash-image';
  String get _textModel =>
      dotenv.maybeGet('GEMINI_MODEL') ?? 'gemini-2.0-flash';

  bool get isConfigured {
    final key = dotenv.maybeGet('GEMINI_API_KEY') ?? '';
    return key.isNotEmpty && !key.toLowerCase().contains('your_');
  }

  static const _style =
      'A warm children\'s picture-book illustration that clearly DEPICTS this '
      'exact moment of the story — show the characters and the action, with a '
      'full background and setting. Storybook art style, soft warm colors, '
      'expressive, cozy. No text, no words, no letters anywhere in the image. ';

  /// Masaldan illüstratör için tutarlı bir karakter tarifi (İngilizce) çıkarır.
  Future<String> characterBrief(String storyText) async {
    try {
      final prompt =
          'Read this children\'s story and describe its main character(s) for '
          'an illustrator in ONE short English sentence — include name, age, '
          'hair, eyes, clothing/colors, and species (human/animal). '
          'Only the description.\n\nStory:\n$storyText';
      final r = await _dio.post(
        '/models/$_textModel:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        },
      );
      final parts = r.data['candidates']?[0]?['content']?['parts'] as List?;
      final buf = StringBuffer();
      for (final p in parts ?? const []) {
        if (p['text'] != null) buf.write(p['text']);
      }
      return buf.toString().trim();
    } catch (e) {
      AppLogger.error('Karakter tarifi alınamadı', tag: 'ImageGen', error: e);
      return '';
    }
  }

  /// Tek görsel üretir; [reference] verilirse o görseldeki karakteri korur.
  Future<Uint8List?> _generate(String prompt, {Uint8List? reference}) async {
    final parts = <Map<String, dynamic>>[
      {'text': prompt}
    ];
    if (reference != null) {
      parts.add({
        'inline_data': {
          'mime_type': 'image/png',
          'data': base64Encode(reference),
        }
      });
    }

    final r = await _dio.post(
      '/models/$_imageModel:generateContent',
      data: {
        'contents': [
          {'parts': parts}
        ],
        'generationConfig': {
          'responseModalities': ['IMAGE']
        },
      },
    );

    final candidates = r.data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;
    final outParts = candidates.first['content']?['parts'] as List?;
    if (outParts == null) return null;
    for (final p in outParts) {
      final inline = p['inline_data'] ?? p['inlineData'];
      final data = inline?['data'];
      if (data is String && data.isNotEmpty) {
        return base64Decode(data);
      }
    }
    return null;
  }

  /// Tüm sahneler için TUTARLI KARAKTERLİ görseller üretir.
  /// İlk başarılı görsel "referans" olur; sonraki sahneler onu koruyarak çizilir.
  /// Başarısız/yapılandırılmamışsa ilgili sahne için null döner (temalı karta düşer).
  Future<List<String?>> generateConsistentScenes({
    required List<String> scenes,
    required String storyText,
    void Function(int done, int total)? onProgress,
  }) async {
    if (!isConfigured) return List.filled(scenes.length, null);

    final brief = await characterBrief(storyText);
    final dir = await getTemporaryDirectory();
    Uint8List? reference;
    final paths = <String?>[];

    for (var i = 0; i < scenes.length; i++) {
      final prompt = _style +
          (brief.isNotEmpty ? 'Main character(s): $brief. ' : '') +
          (reference != null
              ? 'IMPORTANT: keep the character EXACTLY identical to the '
                  'reference image (same face, hair, outfit, colors). '
              : '') +
          'The scene to illustrate: ${scenes[i]}';

      Uint8List? bytes;
      try {
        bytes = await _generate(prompt, reference: reference);
      } catch (e) {
        AppLogger.error('AI görsel üretilemedi (sahne $i)',
            tag: 'ImageGen', error: e);
        bytes = null;
      }

      if (bytes == null) {
        paths.add(null);
      } else {
        reference ??= bytes; // ilk başarılı görsel = referans karakter
        final file = File('${dir.path}/ai_scene_$i.png');
        await file.writeAsBytes(bytes, flush: true);
        paths.add(file.path);
      }
      onProgress?.call(i + 1, scenes.length);
    }

    AppLogger.success('AI sahne görselleri üretildi (tutarlı karakter)',
        tag: 'ImageGen');
    return paths;
  }
}
