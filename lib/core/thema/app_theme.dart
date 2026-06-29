// lib/core/thema/app_theme.dart
//
// 🌙 AURORA DREAM — premium aydınlık + premium gece teması.
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_palette.dart';
import 'app_text_styles.dart';

class AppTheme {
  // Geriye dönük uyumluluk (varsayılan Aurora paleti)
  static ThemeData get lightTheme => light(AppPalette.aurora);
  static ThemeData get darkTheme => dark(AppPalette.aurora);

  // ===================== AYDINLIK TEMA =====================
  static ThemeData light(AppPalette p) {
    const onSurface = AppColors.textDarkOnLight;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: p.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      splashColor: p.primary.withValues(alpha: 0.08),
      highlightColor: p.primary.withValues(alpha: 0.05),

      colorScheme: ColorScheme.light(
        primary: p.primary,
        secondary: p.secondary,
        tertiary: AppColors.gold,
        surface: AppColors.surfaceLight,
        surfaceContainerHighest: AppColors.surfaceLightAlt,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        onError: Colors.white,
        primaryContainer: p.primary.withValues(alpha: 0.12),
        secondaryContainer: AppColors.gold.withValues(alpha: 0.16),
        outline: AppColors.borderLight,
      ),

      textTheme: AppTextStyles.textTheme(onSurface),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: onSurface),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shadowColor: p.primary.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        hintStyle: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textMutedOnLight),
        labelStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textMutedOnLight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingM,
        ),
        border: _inputBorder(AppColors.borderLight),
        enabledBorder: _inputBorder(AppColors.borderLight),
        focusedBorder: _inputBorder(p.primary, width: 1.8),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLightAlt,
        selectedColor: p.primary.withValues(alpha: 0.14),
        labelStyle: AppTextStyles.labelSmall.copyWith(color: onSurface),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),

      iconTheme: const IconThemeData(color: onSurface),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        modalBackgroundColor: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textDarkOnLight,
        contentTextStyle:
            AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ===================== GECE (DARK) TEMA =====================
  static ThemeData dark(AppPalette p) {
    const onSurface = AppColors.textDark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: p.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      splashColor: Colors.white.withValues(alpha: 0.06),
      highlightColor: Colors.white.withValues(alpha: 0.04),

      colorScheme: ColorScheme.dark(
        primary: p.primary,
        secondary: p.secondary,
        tertiary: AppColors.gold,
        surface: AppColors.surfaceDark,
        surfaceContainerHighest: AppColors.surfaceDarkAlt,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        onError: Colors.white,
        primaryContainer: p.primary.withValues(alpha: 0.30),
        secondaryContainer: AppColors.gold.withValues(alpha: 0.18),
        outline: Colors.white.withValues(alpha: 0.12),
      ),

      textTheme: AppTextStyles.textTheme(onSurface),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: onSurface),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shadowColor: Colors.black.withValues(alpha: 0.40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.goldSoft,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDarkAlt,
        hintStyle: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textMutedOnDark),
        labelStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textMutedOnDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingM,
        ),
        border: _inputBorder(Colors.white.withValues(alpha: 0.10)),
        enabledBorder: _inputBorder(Colors.white.withValues(alpha: 0.10)),
        focusedBorder: _inputBorder(p.primary, width: 1.8),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDarkAlt,
        selectedColor: p.primary,
        labelStyle: AppTextStyles.labelSmall.copyWith(color: onSurface),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
      ),

      iconTheme: const IconThemeData(color: onSurface),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        modalBackgroundColor: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDarkAlt,
        contentTextStyle:
            AppTextStyles.bodyMedium.copyWith(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1.2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
