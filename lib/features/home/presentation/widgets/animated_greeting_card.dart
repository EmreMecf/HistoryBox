// lib/features/home/presentation/widgets/animated_greeting_card.dart
import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class AnimatedGreetingCard extends StatelessWidget {
  final String userName;
  final AnimationController floatingAnimation;

  const AnimatedGreetingCard({
    super.key,
    required this.userName,
    required this.floatingAnimation,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Günaydın';
    } else if (hour < 18) {
      return 'İyi günler';
    } else {
      return 'İyi akşamlar';
    }
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return AppAssets.sunEmoji;
    } else if (hour < 18) {
      return AppAssets.cloudEmoji;
    } else {
      return AppAssets.moonEmoji;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Arka plan emojileri
          Positioned(
            right: -10,
            top: -10,
            child: AnimatedBuilder(
              animation: floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 5 * floatingAnimation.value),
                  child: Opacity(
                    opacity: 0.2,
                    child: Text(
                      AppAssets.rainbowEmoji,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: -5,
            bottom: -5,
            child: AnimatedBuilder(
              animation: floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -5 * floatingAnimation.value),
                  child: Opacity(
                    opacity: 0.2,
                    child: Text(
                      AppAssets.unicornEmoji,
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // İçerik
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getGreetingEmoji(),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()},',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppAssets.magicEmoji,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: AppDimensions.paddingS),
                    Text(
                      'Bugün hangi hikayeyi yaratacaksın?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
