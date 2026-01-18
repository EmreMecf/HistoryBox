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
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getAgeGroupEmoji(ageGroup),
                  style: const TextStyle(fontSize: 22),
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
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getAgeGroupDescription(ageGroup),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
