// lib/core/thema/app_palette.dart
//
// 🎨 Seçilebilir vurgu renk temaları. Aurora ücretsiz; diğerleri premium.
import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class AppPalette {
  final String id;
  final String name;
  final String emoji;
  final Color primary;
  final Color secondary;
  final bool isPremium;

  const AppPalette({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primary,
    required this.secondary,
    this.isPremium = false,
  });

  List<Color> get gradient => [primary, secondary];

  static const AppPalette aurora = AppPalette(
    id: 'aurora',
    name: 'Aurora',
    emoji: '🌌',
    primary: AppColors.brandIndigo,
    secondary: AppColors.brandViolet,
    isPremium: false,
  );

  static const List<AppPalette> all = [
    aurora,
    AppPalette(
      id: 'okyanus',
      name: 'Okyanus',
      emoji: '🌊',
      primary: Color(0xFF2BB3C0),
      secondary: Color(0xFF4C8DFF),
      isPremium: true,
    ),
    AppPalette(
      id: 'gunbatimi',
      name: 'Gün Batımı',
      emoji: '🌅',
      primary: Color(0xFFFF7A59),
      secondary: Color(0xFFFF5BA0),
      isPremium: true,
    ),
    AppPalette(
      id: 'orman',
      name: 'Orman',
      emoji: '🌲',
      primary: Color(0xFF2FB36B),
      secondary: Color(0xFF33D9C0),
      isPremium: true,
    ),
    AppPalette(
      id: 'galaksi',
      name: 'Galaksi',
      emoji: '🪐',
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFFC026D3),
      isPremium: true,
    ),
  ];

  static AppPalette byId(String? id) =>
      all.firstWhere((p) => p.id == id, orElse: () => aurora);
}
