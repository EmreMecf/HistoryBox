// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryRed,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: AppTextStyles.fontFamily,

      colorScheme: ColorScheme.light(
        primary: AppColors.primaryRed,
        secondary: AppColors.secondaryRed,
        tertiary: AppColors.accentOrange,
        surface: AppColors.surfaceLight,
        surfaceContainerHighest: AppColors.backgroundLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDarkOnLight,
        onError: Colors.white,
        primaryContainer: AppColors.primaryRed.withOpacity(0.2),
        secondaryContainer: AppColors.accentOrange.withOpacity(0.2),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textDarkOnLight,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: AppTextStyles.fontFamily,
          color: AppColors.textDarkOnLight,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.textLight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          elevation: 2,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: AppColors.textLight,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundLight,
        selectedColor: AppColors.primaryRed.withOpacity(0.15),
        secondarySelectedColor: AppColors.accentTeal.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(color: Colors.black87),
        titleMedium: TextStyle(color: Colors.black87),
        titleSmall: TextStyle(color: Colors.black87),
      ),

      // IconTheme
      iconTheme: const IconThemeData(
        color: Colors.black87,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
      ),


      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        modalBackgroundColor: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),


      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        contentTextStyle: const TextStyle(color: AppColors.textDarkOnLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryRed,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: AppTextStyles.fontFamily,

      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryRed,
        secondary: AppColors.secondaryRed,
        tertiary: AppColors.accentOrange,
        surface: AppColors.surfaceDark,
        surfaceContainerHighest: AppColors.darkRed,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark,
        onError: Colors.white,
        primaryContainer: AppColors.primaryRed.withOpacity(0.3),
        secondaryContainer: AppColors.accentOrange.withOpacity(0.2),
      ),


      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkRed,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: AppTextStyles.fontFamily,
          color: AppColors.textDark,
        ),
      ),


      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 4,
        margin: const EdgeInsets.all(8),
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
      ),


      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.textDark,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          elevation: 4,
        ),
      ),


      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: AppColors.textDark,
      ),


      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.primaryRed),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide(
            color: AppColors.primaryRed.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(
            color: AppColors.primaryRed,
            width: 2,
          ),
        ),
        hintStyle: TextStyle(color: AppColors.textDark.withOpacity(0.6)),
        labelStyle: const TextStyle(color: AppColors.textDark),
      ),


      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedColor: AppColors.primaryRed,
        secondarySelectedColor: AppColors.accentTeal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        labelStyle: const TextStyle(color: AppColors.textDark),
      ),

      // IconTheme
      iconTheme: const IconThemeData(
        color: AppColors.textDark,
      ),


      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.textDark),
        titleLarge: TextStyle(color: AppColors.textDark),
        titleMedium: TextStyle(color: AppColors.textDark),
        titleSmall: TextStyle(color: AppColors.textDark),
      ),


      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
      ),


      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        modalBackgroundColor: AppColors.surfaceDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),


      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: const TextStyle(color: AppColors.textDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}