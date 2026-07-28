import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageViewModel extends ChangeNotifier {
  // Varsayılan dil: İngilizce
  Locale _currentLocale = const Locale('en', '');

  Locale get currentLocale => _currentLocale;

  /// Desteklenen arayüz dilleri (kod → görünen ad).
  static const Map<String, String> supported = {
    'en': 'English',
    'tr': 'Türkçe',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'it': 'Italiano',
  };

  LanguageViewModel() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      _currentLocale = Locale(languageCode, '');
      notifyListeners();
    } catch (e) {
      // Varsayılan dil İngilizce
      _currentLocale = const Locale('en', '');
    }
  }

  Future<void> changeLanguage(Locale newLocale) async {
    if (_currentLocale == newLocale) return;

    _currentLocale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', newLocale.languageCode);
    } catch (e) {
      // Hata durumunda log
      debugPrint('Error saving language: $e');
    }
  }
}
