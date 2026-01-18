// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors._();

  // 🎨 Ana Renkler - Modern ve Eğlenceli Kırmızı/Pembe Tonları
  static const Color primaryRed = Color(0xFFEA7B7B); // Ana kırmızı-pembe
  static const Color secondaryRed = Color(0xFFD25353); // Orta kırmızı
  static const Color darkRed = Color(0xFF9E3B3B); // Koyu kırmızı
  
  // Tamamlayıcı Renkler - Çocuklara özel canlı tonlar
  static const Color accentOrange = Color(0xFFFF9F40); // Portakal
  static const Color accentYellow = Color(0xFFFFC93C); // Sarı
  static const Color accentGreen = Color(0xFF5FD068); // Yeşil
  static const Color accentBlue = Color(0xFF4A90E2); // Mavi
  static const Color accentPurple = Color(0xFF9B59B6); // Mor
  static const Color accentTeal = Color(0xFF4ECDC4); // Turkuaz
  static const Color accentPink = Color(0xFFFF85A2); // Açık pembe
  static const Color accentIndigo = Color(0xFF4F46E5);
  static const Color accentViolet = Color(0xFF7C3AED);

  // Light Theme
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textLight = Colors.white;
  static const Color textDarkOnLight = Color(0xFF0F172A);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Dark Theme
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color darkPurple = Color(0xFF0F3460);
  static const Color textDark = Color(0xFFFFF8F0);

  // Status Colors
  static const Color success = Color(0xFF5FD068);
  static const Color warning = Color(0xFFFFC93C);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF4A90E2);

  // Kategori Renkleri - Modern ve Eğlenceli
  static const Map<String, Color> categoryColors = {
    'Masal': Color(0xFFEA7B7B), // Ana kırmızı-pembe
    'Hikaye': Color(0xFFD25353), // Orta kırmızı
    'Şiir': Color(0xFFFF85A2), // Açık pembe
    'Bilim': Color(0xFF4A90E2), // Mavi
    'Macera': Color(0xFF9E3B3B), // Koyu kırmızı
    'Komedi': Color(0xFFFFC93C), // Sarı
  };

  // Additional Category Colors
  static const Color categoryMagenta = Color(0xFFFF6B9D);
  static const Color categoryOrange = Color(0xFFFF9F40);
  static const Color categoryGreen = Color(0xFF5FD068);
  static const Color categoryPurple = Color(0xFF9B59B6);
  static const Color categoryBlue = Color(0xFF4A90E2);
  static const Color categoryTeal = Color(0xFF4ECDC4);

  // Gradient Kombinasyonları - Modern ve Canlı
  static const List<Color> primaryGradient = [
    Color(0xFFEA7B7B), // Ana kırmızı-pembe
    Color(0xFFD25353), // Orta kırmızı
  ];

  static const List<Color> premiumGradient = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
  ];

  static const List<Color> premiumWarmGradient = [
    Color(0xFFF97316),
    Color(0xFFEC4899),
  ];

  static const List<Color> premiumAppBarGradient = [
    Color(0xFF1F1D2B),
    Color(0xFF2B2152),
  ];

  static const List<Color> premiumBackgroundGradient = [
    Color(0xFFF8FAFC),
    Color(0xFFF3F4F6),
  ];

  static const List<Color> warmGradient = [
    Color(0xFFEA7B7B),
    Color(0xFFFF9F40), // Portakal
  ];

  static const List<Color> sweetGradient = [
    Color(0xFFFF85A2), // Açık pembe
    Color(0xFFEA7B7B), // Ana pembe
  ];

  static const List<Color> adventureGradient = [
    Color(0xFF9E3B3B), // Koyu kırmızı
    Color(0xFFD25353), // Orta kırmızı
  ];

  static const List<Color> funGradient = [
    Color(0xFFFFC93C), // Sarı
    Color(0xFFFF9F40), // Portakal
  ];

  static const List<Color> oceanGradient = [
    Color(0xFF4ECDC4), // Turkuaz
    Color(0xFF4A90E2), // Mavi
  ];

  static const List<Color> rainbowGradient = [
    Color(0xFFEA7B7B),
    Color(0xFFFF85A2),
    Color(0xFFFF9F40),
    Color(0xFFFFC93C),
    Color(0xFF5FD068),
    Color(0xFF4A90E2),
  ];

  // Yaş Grubu Renkleri
  static const Map<String, Color> ageGroupColors = {
    '3-5 Yaş': Color(0xFFFFB347),
    '6-8 Yaş': Color(0xFF5FD068),
    '9-12 Yaş': Color(0xFF4A90E2),
    '13+ Yaş': Color(0xFF9B59B6),
  };
}