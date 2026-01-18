import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageViewModel extends ChangeNotifier {
  Locale _currentLocale = const Locale('tr', '');

  Locale get currentLocale => _currentLocale;

  LanguageViewModel() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'tr';
      _currentLocale = Locale(languageCode, '');
      notifyListeners();
    } catch (e) {
      // Varsayılan dil Türkçe
      _currentLocale = const Locale('tr', '');
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

  void toggleLanguage() {
    if (_currentLocale.languageCode == 'tr') {
      changeLanguage(const Locale('en', ''));
    } else {
      changeLanguage(const Locale('tr', ''));
    }
  }
}
