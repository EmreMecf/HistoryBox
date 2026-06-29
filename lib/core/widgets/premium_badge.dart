// lib/core/widgets/premium_badge.dart
import 'package:flutter/material.dart';
import '../thema/app_colors.dart';

/// Premium kullanıcıları işaretleyen altın rozet.
/// [compact] true ise yalnızca taç ikonu (isim yanında), false ise "Premium" pill.
class PremiumBadge extends StatelessWidget {
  final bool compact;
  final double size;

  const PremiumBadge({super.key, this.compact = true, this.size = 18});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: AppColors.premiumWarmGradient),
        ),
        child: Icon(
          Icons.workspace_premium_rounded,
          size: size * 0.66,
          color: const Color(0xFF5A3A00),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.premiumWarmGradient),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded,
              size: 13, color: Color(0xFF5A3A00)),
          SizedBox(width: 4),
          Text(
            'Premium',
            style: TextStyle(
              color: Color(0xFF5A3A00),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
