import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Uygulama yapilandirmasi ve API anahtarlarini yonetir.
///
/// Anahtarlar oncelik sirasiyla su kaynaklardan gelir:
///   1. Firebase Remote Config (yayindaki asil kaynak — repoda anahtar tutmaya
///      gerek kalmaz; degistirmek icin yeniden yayin gerekmez)
///   2. Yerel `.env` dosyasi (varsa — sadece gelistirme kolayligi icin)
///   3. Koddaki guvenli varsayilanlar (gizli olmayan taban URL / model adlari)
///
/// Remote Config'ten gelen degerler [dotenv]'in haritasina yazilir; boylece
/// mevcut `dotenv.maybeGet('...')` cagrilari degismeden calismaya devam eder.
class AppConfig {
  AppConfig._();
  static final AppConfig instance = AppConfig._();

  /// Remote Config / .env icinde aranan tum parametre adlari.
  static const List<String> keys = [
    'GEMINI_BASE_URL',
    'GEMINI_API_KEY',
    'GEMINI_MODEL',
    'GEMINI_IMAGE_MODEL',
    'TTS_PROVIDER',
    'ELEVENLABS_API_KEY',
    'ELEVENLABS_VOICE_ID',
    'ELEVENLABS_MODEL',
    'VOXCPM_BASE_URL',
    'VOXCPM_API_KEY',
  ];

  /// Gizli olmayan varsayilanlar (Remote Config bos/erisilemez oldugunda kullanilir).
  static const Map<String, String> _defaults = {
    'GEMINI_BASE_URL': 'https://generativelanguage.googleapis.com/v1beta',
    'GEMINI_API_KEY': '',
    'GEMINI_MODEL': 'gemini-2.0-flash',
    'GEMINI_IMAGE_MODEL': 'gemini-2.5-flash-image',
    'TTS_PROVIDER': 'elevenlabs',
    'ELEVENLABS_API_KEY': '',
    'ELEVENLABS_VOICE_ID': 'EXAVITQu4vr4xnSDxMaL',
    'ELEVENLABS_MODEL': 'eleven_multilingual_v2',
    'VOXCPM_BASE_URL': '',
    'VOXCPM_API_KEY': '',
  };

  bool _initialized = false;

  /// main() icinde Firebase.initializeApp'tan SONRA cagrilmalidir.
  Future<void> init() async {
    if (_initialized) return;

    // 1) Yerel .env'i (varsa) yukle. Yoksa dotenv'i bos baslat ki
    //    dotenv.maybeGet cagrilari hata firlatmasin.
    try {
      await dotenv.load();
    } catch (_) {
      dotenv.testLoad(fileInput: '');
    }

    // 2) Firebase Remote Config'ten anahtarlari cek ve dotenv'e yaz.
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // Gelistirmede aninda; yayinda saatte bir cek.
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 1),
      ));
      await rc.setDefaults(_defaults);
      await rc.fetchAndActivate();

      for (final key in keys) {
        final value = rc.getString(key);
        if (value.isNotEmpty) {
          dotenv.env[key] = value;
        }
      }
    } catch (e) {
      // Cevrimdisi ya da Remote Config henuz yapilandirilmamis olabilir;
      // bu durumda .env / kod varsayilanlari kullanilir.
      debugPrint('AppConfig: Remote Config alinamadi, varsayilanlar kullanilacak. $e');
    }

    // 3) Hala bos olan gizli-olmayan degerler icin kod varsayilanlarini uygula.
    _defaults.forEach((key, def) {
      final current = dotenv.maybeGet(key);
      if ((current == null || current.isEmpty) && def.isNotEmpty) {
        dotenv.env[key] = def;
      }
    });

    _initialized = true;
  }

  /// Zorunlu API anahtarlari mevcut mu? (Teshis / uyari icin.)
  bool get hasGeminiKey => (dotenv.maybeGet('GEMINI_API_KEY') ?? '').isNotEmpty;
  bool get hasElevenLabsKey =>
      (dotenv.maybeGet('ELEVENLABS_API_KEY') ?? '').isNotEmpty;
}
