// lib/features/story/create/presentation/widgets/story_preview_card.dart
import 'package:flutter/material.dart';
import '../../../../../core/core.dart';
import '../../../../../shared/widgets/animated_button.dart';
import '../../../../../shared/widgets/loading_widget.dart';

class StoryPreviewCard extends StatelessWidget {
  final String title;
  final String content;
  final String category;
  final String ageGroup;
  final VoidCallback onSave;
  final VoidCallback onRegenerate;
  final VoidCallback onEdit;
  final bool isLoading;

  const StoryPreviewCard({
    super.key,
    required this.title,
    required this.content,
    required this.category,
    required this.ageGroup,
    required this.onSave,
    required this.onRegenerate,
    required this.onEdit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.categoryColors[category] ?? 
                          AppColors.primaryRed;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Text(
                AppAssets.starEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              const Expanded(
                child: Text(
                  'Hikayen Hazır!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingL),
          
          // Hikaye Kartı
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık bölümü
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      Row(
                        children: [
                          _buildChip(category, categoryColor),
                          const SizedBox(width: AppDimensions.paddingS),
                          _buildChip(
                            ageGroup,
                            AppColors.ageGroupColors[ageGroup] ??
                                AppColors.accentBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.7,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingXL),
          
          // Aksiyon butonları
          if (!isLoading) ...[
            AnimatedButton(
              text: 'Hikayeyi Kaydet',
              onPressed: onSave,
              icon: Icons.save,
              gradientColors: AppColors.primaryGradient,
              width: double.infinity,
            ),
            
            const SizedBox(height: AppDimensions.paddingM),
            
            Row(
              children: [
                Expanded(
                  child: AnimatedButton(
                    text: 'Yeniden Oluştur',
                    onPressed: onRegenerate,
                    icon: Icons.refresh,
                    backgroundColor: AppColors.accentOrange,
                  ),
                ),
                // const SizedBox(width: AppDimensions.paddingM),
                // Expanded(
                //   child: AnimatedButton(
                //     text: 'Düzenle',
                //     onPressed: onEdit,
                //     icon: Icons.edit,
                //     backgroundColor: AppColors.accentTeal,
                //   ),
                // ),
              ],
            ),
          ] else
            const LoadingWidget(message: 'Hikaye oluşturuluyor...'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
