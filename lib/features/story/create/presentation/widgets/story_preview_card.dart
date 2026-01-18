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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık bölümü
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [categoryColor, categoryColor.withOpacity(0.7)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusL),
                      topRight: Radius.circular(AppDimensions.radiusL),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppAssets.categoryEmojis[category] ?? 
                              AppAssets.bookEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
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
                    ],
                  ),
                ),
                
                // İçerik bölümü
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
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
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
