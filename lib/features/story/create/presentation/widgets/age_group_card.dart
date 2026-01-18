// lib/features/story/create/presentation/widgets/age_group_card.dart
import 'package:flutter/material.dart';
import '../../../../../core/core.dart';

class AgeGroupCard extends StatelessWidget {
  final String ageGroup;
  final Color color;
  final VoidCallback onTap;

  const AgeGroupCard({
    super.key,
    required this.ageGroup,
    required this.color,
    required this.onTap,
  });

  String _getAgeGroupDescription(String ageGroup) {
    switch (ageGroup) {
      case '3-5 Yaş':
        return 'Çok basit kelimeler ve kısa cümleler';
      case '6-8 Yaş':
        return 'Kolay anlaşılır ve eğlenceli hikayeler';
      case '9-12 Yaş':
        return 'Daha karmaşık ve heyecanlı hikayeler';
      case '13+ Yaş':
        return 'Zengin kelime hazinesi ve derin konular';
      default:
        return '';
    }
  }

  String _getAgeGroupEmoji(String ageGroup) {
    switch (ageGroup) {
      case '3-5 Yaş':
        return '🍼';
      case '6-8 Yaş':
        return '🎈';
      case '9-12 Yaş':
        return '🎯';
      case '13+ Yaş':
        return '🚀';
      default:
        return '📚';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getAgeGroupEmoji(ageGroup),
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ageGroup,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getAgeGroupDescription(ageGroup),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
