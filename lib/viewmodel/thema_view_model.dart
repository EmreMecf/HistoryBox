import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/thema/app_palette.dart';

class ThemeViewModel extends ChangeNotifier {
  static const _kPalette = 'app_palette';

  ThemeMode _themeMode = ThemeMode.light;
  AppPalette _palette = AppPalette.aurora;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AppPalette get palette => _palette;

  ThemeViewModel() {
    _loadPalette();
  }

  Future<void> _loadPalette() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kPalette);
    final loaded = AppPalette.byId(id);
    if (loaded.id != _palette.id) {
      _palette = loaded;
      notifyListeners();
    }
  }

  Future<void> setPalette(AppPalette p) async {
    _palette = p;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPalette, p.id);
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void changeThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
