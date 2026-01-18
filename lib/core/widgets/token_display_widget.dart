import 'package:flutter/material.dart';
import 'package:historybox/viewmodel/token_view_model.dart';
import 'package:historybox/core/thema/app_colors.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class TokenDisplay extends StatelessWidget {
  const TokenDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokenViewModel = context.watch<TokenViewModel>();
    final tokenCount = tokenViewModel.tokenCount ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.funGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentYellow.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Ionicons.sparkles,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: tokenCount),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
