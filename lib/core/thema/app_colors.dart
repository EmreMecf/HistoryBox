// lib/core/thema/app_colors.dart
//
// 🌙 AURORA DREAM — Premium "gece masalı" tasarım paleti.
// Indigo/mor gece tonları + altın/amber premium vurgu + mücevher renkli
// kategori tonları. Eski sabit isimleri korunur (geriye dönük uyumluluk),
// değerler premium palete güncellenmiştir.
import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors._();

  // ===================== MARKA RENKLERİ =====================
  // Ana marka: indigo→mor. (Eski "red" isimleri marka moruna eşlenir.)
  static const Color brandIndigo = Color(0xFF6D5DF6);
  static const Color brandViolet = Color(0xFF9A5CF0);
  static const Color brandDeep = Color(0xFF3A2E8F);

  // Premium vurgu: altın / amber
  static const Color gold = Color(0xFFFFB454);
  static const Color goldSoft = Color(0xFFFFC56F);

  // Geriye dönük uyumluluk (eski isimler → yeni değerler)
  static const Color primaryRed = brandIndigo; // ana marka
  static const Color secondaryRed = Color(0xFF5A4BD4); // koyu indigo
  static const Color darkRed = brandDeep; // gece indigo

  // ===================== TAMAMLAYICI RENKLER =====================
  static const Color accentOrange = gold; // premium altın vurgu
  static const Color accentYellow = Color(0xFFFFD479);
  static const Color accentGreen = Color(0xFF34D399);
  static const Color accentBlue = Color(0xFF4C8DFF);
  static const Color accentPurple = brandViolet;
  static const Color accentTeal = Color(0xFF33D9C0);
  static const Color accentPink = Color(0xFFFF7AA2);
  static const Color accentIndigo = brandIndigo;
  static const Color accentViolet = brandViolet;

  // ===================== AYDINLIK TEMA =====================
  static const Color backgroundLight = Color(0xFFF6F5FF); // yumuşak lavanta-beyaz
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightAlt = Color(0xFFF1EEFF); // hafif renkli yüzey
  static const Color textLight = Colors.white; // renkli zemin üstü metin
  static const Color textDarkOnLight = Color(0xFF1E1B3A); // indigo-mürekkep
  static const Color textMutedOnLight = Color(0xFF6B6794);
  static const Color borderLight = Color(0xFFE7E3FB); // yumuşak lavanta kenar

  // ===================== GECE (DARK) TEMA =====================
  static const Color backgroundDark = Color(0xFF0E0B2B); // gece yarısı
  static const Color backgroundDarkAlt = Color(0xFF150E3D);
  static const Color surfaceDark = Color(0xFF1A1542); // gece yüzeyi
  static const Color surfaceDarkAlt = Color(0xFF231C56);
  static const Color darkPurple = Color(0xFF2A1B63);
  static const Color textDark = Color(0xFFF3F1FF);
  static const Color textMutedOnDark = Color(0xFFB9B2E8);

  // ===================== CAM (GLASS) TOKENLARI =====================
  static const Color glassFillLight = Color(0x14FFFFFF); // beyaz %8
  static const Color glassBorderLight = Color(0x1FFFFFFF); // beyaz %12
  static const Color glassFillOnLight = Color(0x0A6D5DF6); // indigo çok hafif
  static const Color glassBorderOnLight = Color(0x1A6D5DF6);

  // ===================== DURUM RENKLERİ =====================
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFFB454);
  static const Color error = Color(0xFFFF6B7A);
  static const Color info = Color(0xFF4C8DFF);

  // ===================== KATEGORİ RENKLERİ (mücevher tonları) =====================
  static const Map<String, Color> categoryColors = {
    'Masal': Color(0xFF7C5CFF), // büyülü mor
    'Hikaye': Color(0xFF4C8DFF), // mavi
    'Şiir': Color(0xFFFF7AA2), // pembe
    'Bilim': Color(0xFF33D9C0), // turkuaz
    'Macera': Color(0xFFFFB454), // altın
    'Komedi': Color(0xFFFF8A5C), // mercan
  };

  static const Color categoryMagenta = Color(0xFFFF6FB5);
  static const Color categoryOrange = Color(0xFFFFB454);
  static const Color categoryGreen = Color(0xFF34D399);
  static const Color categoryPurple = brandViolet;
  static const Color categoryBlue = Color(0xFF4C8DFF);
  static const Color categoryTeal = Color(0xFF33D9C0);

  // ===================== GRADYANLAR =====================
  static const List<Color> primaryGradient = [
    Color(0xFF6D5DF6),
    Color(0xFF9A5CF0),
  ];

  // İmza hero gradyanı: indigo → mor → pembe
  static const List<Color> premiumGradient = [
    Color(0xFF6D5DF6),
    Color(0xFF9A5CF0),
    Color(0xFFFF7AA2),
  ];

  // Sıcak premium: altın → amber
  static const List<Color> premiumWarmGradient = [
    Color(0xFFFFC56F),
    Color(0xFFFF9D5C),
  ];

  // Gece app bar / arka plan üst
  static const List<Color> premiumAppBarGradient = [
    Color(0xFF1F1746),
    Color(0xFF2B1F63),
  ];

  // Aydınlık scaffold arka planı (yumuşak lavanta)
  static const List<Color> premiumBackgroundGradient = [
    Color(0xFFF6F5FF),
    Color(0xFFFBFAFF),
  ];

  // Gece scaffold arka planı (yıldızlı gökyüzü)
  static const List<Color> nightBackgroundGradient = [
    Color(0xFF2A1B63),
    Color(0xFF150E3D),
    Color(0xFF0B0824),
  ];

  static const List<Color> warmGradient = [
    Color(0xFFFFB454),
    Color(0xFFFF8A5C),
  ];

  static const List<Color> sweetGradient = [
    Color(0xFFFF7AA2),
    Color(0xFF9A5CF0),
  ];

  static const List<Color> adventureGradient = [
    Color(0xFF3A2E8F),
    Color(0xFF6D5DF6),
  ];

  static const List<Color> funGradient = [
    Color(0xFFFFC56F),
    Color(0xFFFFB454),
  ];

  static const List<Color> oceanGradient = [
    Color(0xFF33D9C0),
    Color(0xFF4C8DFF),
  ];

  static const List<Color> rainbowGradient = [
    Color(0xFF6D5DF6),
    Color(0xFF9A5CF0),
    Color(0xFFFF7AA2),
    Color(0xFFFFB454),
    Color(0xFF34D399),
    Color(0xFF4C8DFF),
  ];

  // ===================== YAŞ GRUBU RENKLERİ =====================
  static const Map<String, Color> ageGroupColors = {
    '3-5 Yaş': Color(0xFFFFB454),
    '6-8 Yaş': Color(0xFF34D399),
    '9-12 Yaş': Color(0xFF4C8DFF),
    '13+ Yaş': Color(0xFF9A5CF0),
  };
}
