// lib/core/thema/app_dimensions.dart
import 'package:flutter/material.dart';

@immutable
class AppDimensions {
  const AppDimensions._();

  // Kenar boşlukları
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 40.0;

  // Yuvarlak köşeler (premium: daha yumuşak)
  static const double radiusS = 8.0;
  static const double radiusM = 14.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 28.0;
  static const double radiusXXL = 36.0;
  static const double radiusPill = 999.0;

  // İkon boyutları
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Animasyon süreleri
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 550);
}

/// Premium gölge ve dekorasyon yardımcıları.
@immutable
class AppShadows {
  const AppShadows._();

  /// Yumuşak yükseltilmiş kart gölgesi (aydınlık tema).
  static List<BoxShadow> soft(Color tint) => [
        BoxShadow(
          color: tint.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -6,
        ),
      ];

  /// Marka renkli "glow" gölgesi (butonlar / hero kartlar).
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.40),
          blurRadius: 28,
          offset: const Offset(0, 12),
          spreadRadius: -8,
        ),
      ];
}
