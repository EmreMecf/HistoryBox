// lib/shared/services/parental_controls_service.dart
//
// 👪 Ebeveyn kontrolleri: PIN + topluluk erişimi.
import 'package:shared_preferences/shared_preferences.dart';

class ParentalControlsService {
  static const _kPin = 'parent_pin';
  static const _kCommunityEnabled = 'community_enabled';

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_kPin) ?? '').isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPin, pin);
  }

  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPin);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_kPin) ?? '') == pin;
  }

  /// Topluluk (sosyal akış) açık mı? Varsayılan: açık.
  Future<bool> isCommunityEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kCommunityEnabled) ?? true;
  }

  Future<void> setCommunityEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCommunityEnabled, enabled);
  }
}
