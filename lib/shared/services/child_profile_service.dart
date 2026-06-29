// lib/shared/services/child_profile_service.dart
//
// Çocuk profili (kahraman adı, ilgi alanları, masal dili) kalıcı saklama.
import 'package:shared_preferences/shared_preferences.dart';

class ChildProfile {
  final String childName;
  final String interests;
  final String language;

  const ChildProfile({
    this.childName = '',
    this.interests = '',
    this.language = 'Türkçe',
  });
}

class ChildProfileService {
  static const _kName = 'child_name';
  static const _kInterests = 'child_interests';
  static const _kLanguage = 'story_language';

  Future<ChildProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ChildProfile(
      childName: prefs.getString(_kName) ?? '',
      interests: prefs.getString(_kInterests) ?? '',
      language: prefs.getString(_kLanguage) ?? 'Türkçe',
    );
  }

  Future<void> save(ChildProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, profile.childName);
    await prefs.setString(_kInterests, profile.interests);
    await prefs.setString(_kLanguage, profile.language);
  }
}
