// lib/core/thema/app_text_styles.dart
//
// Premium tipografi: Plus Jakarta Sans (UI/gövde) + Fredoka (başlık/display).
// Google Fonts üzerinden çekilir; asset gömmeye gerek yoktur.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppTextStyles {
  const AppTextStyles._();

  // Theme'in kullanması için aile adları
  static String get fontFamily => GoogleFonts.plusJakartaSans().fontFamily!;
  static String get displayFontFamily => GoogleFonts.fredoka().fontFamily!;

  // ===================== DISPLAY / BAŞLIK (Fredoka) =====================
  static TextStyle get displayLarge => GoogleFonts.fredoka(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.3,
      );

  static TextStyle get titleLarge => GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get titleMedium => GoogleFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  // ===================== GÖVDE / UI (Plus Jakarta Sans) =====================
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.4,
      );

  // Hikaye okuma gövdesi — editoryal "kitap" hissi için yumuşak serif
  static TextStyle get storyReading => GoogleFonts.lora(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.8,
        letterSpacing: 0.1,
      );

  // Tüm metin temasını üreten yardımcı (renk theme'den gelir)
  static TextTheme textTheme(Color color) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: color),
      displayMedium: displayMedium.copyWith(color: color),
      headlineMedium: titleLarge.copyWith(color: color),
      titleLarge: titleLarge.copyWith(color: color),
      titleMedium: titleMedium.copyWith(color: color),
      bodyLarge: bodyLarge.copyWith(color: color),
      bodyMedium: bodyMedium.copyWith(color: color),
      bodySmall: bodySmall.copyWith(color: color),
      labelLarge: labelLarge.copyWith(color: color),
      labelSmall: labelSmall.copyWith(color: color),
    );
  }
}
