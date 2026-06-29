// lib/services/apis/moderation_service.dart
//
// 🛡️ İçerik moderasyonu — Gemini ile çocuk-güvenliği sınıflandırması.
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/utils/logger.dart';
import 'gemini_api_client.dart';

class ModerationService {
  final GeminiApiClient _ai;
  ModerationService(this._ai);

  bool get isConfigured {
    final key = dotenv.maybeGet('GEMINI_API_KEY') ?? '';
    return key.isNotEmpty && !key.toLowerCase().contains('your_');
  }

  /// Metin güvenli mi? (çocuğa uygunsuz içerik değilse true)
  /// Hata durumunda true döner (içerik zaten AI ile çocuk-güvenli üretiliyor).
  Future<bool> isSafe(String text) async {
    if (!isConfigured) return true;
    try {
      final prompt =
          'Aşağıdaki metin bir çocuk masalı uygulamasında herkese açık '
          'yayınlanacak. İçinde şiddet, korku, cinsellik, nefret söylemi, '
          'küfür veya çocuklara uygunsuz herhangi bir şey var mı? '
          'SADECE tek kelime cevap ver: güvenliyse "GUVENLI", değilse "UYGUNSUZ".\n\n'
          'Metin:\n$text';

      final result = (await _ai.generateText(prompt)).toUpperCase();
      final unsafe = result.contains('UYGUNSUZ') || result.contains('UNSAFE');
      if (unsafe) {
        AppLogger.warning('İçerik moderasyonca işaretlendi', tag: 'Moderation');
      }
      return !unsafe;
    } catch (e) {
      AppLogger.error('Moderasyon kontrolü başarısız',
          tag: 'Moderation', error: e);
      return true; // fail-open
    }
  }
}
