// lib/shared/services/voice_profile_service.dart
//
// Klonlanmış ses tercihini kalıcı saklar.
import 'package:shared_preferences/shared_preferences.dart';

class VoiceProfileService {
  static const _kVoiceId = 'cloned_voice_id';
  static const _kVoiceName = 'cloned_voice_name';
  static const _kUseCloned = 'use_cloned_voice';

  Future<void> saveClonedVoice(String voiceId, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kVoiceId, voiceId);
    await prefs.setString(_kVoiceName, name);
    await prefs.setBool(_kUseCloned, true);
  }

  Future<String?> clonedVoiceId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kVoiceId);
    return (id != null && id.isNotEmpty) ? id : null;
  }

  Future<String?> clonedVoiceName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kVoiceName);
  }

  Future<bool> useCloned() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kUseCloned) ?? false;
  }

  Future<void> setUseCloned(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUseCloned, value);
  }

  /// Aktif ses (klon seçiliyse onun id'si, değilse null → varsayılan ses).
  Future<String?> activeVoiceId() async {
    if (await useCloned()) {
      return clonedVoiceId();
    }
    return null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kVoiceId);
    await prefs.remove(_kVoiceName);
    await prefs.remove(_kUseCloned);
  }
}
