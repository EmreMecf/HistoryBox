// lib/features/story/create/presentation/screens/story_create_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/core.dart';
import '../../../../../shared/widgets/animated_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../shared/widgets/category_card.dart';
import '../../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../viewmodels/story_create_view_model.dart';
import '../widgets/age_group_card.dart';
import '../widgets/story_preview_card.dart';

class StoryCreateScreen extends StatefulWidget {
  const StoryCreateScreen({super.key});

  @override
  State<StoryCreateScreen> createState() => _StoryCreateScreenState();
}

class _StoryCreateScreenState extends State<StoryCreateScreen> {
  final TextEditingController _topicController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoryCreateViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    return PopScope(
      canPop: viewModel.currentStep == StoryCreationStep.selectCategory,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && viewModel.currentStep != StoryCreationStep.selectCategory) {
          viewModel.goBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yeni Hikaye Oluştur'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              if (viewModel.currentStep != StoryCreationStep.selectCategory) {
                viewModel.goBack();
              } else {
                // Güvenli geri dönüş
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              }
            },
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.sweetGradient,
              ),
            ),
          ),
        ),
        body: _buildBody(viewModel, authViewModel),
      ),
    );
  }

  Widget _buildBody(StoryCreateViewModel viewModel, AuthViewModel authViewModel) {
    switch (viewModel.currentStep) {
      case StoryCreationStep.selectCategory:
        return _buildCategorySelection(viewModel);
      case StoryCreationStep.selectAgeGroup:
        return _buildAgeGroupSelection(viewModel);
      case StoryCreationStep.enterTopic:
        return _buildTopicInput(viewModel);
      case StoryCreationStep.generating:
        return const LoadingWidget(
          message: 'Hikaye oluşturuluyor...\nBu birkaç saniye sürebilir ✨',
        );
      case StoryCreationStep.preview:
        return _buildPreview(viewModel, authViewModel);
      case StoryCreationStep.complete:
        return _buildComplete();
    }
  }

  // 1. Kategori Seçimi
  Widget _buildCategorySelection(StoryCreateViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppAssets.bookEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              const Expanded(
                child: Text(
                  'Hangi tür bir hikaye oluşturmak istersin?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.paddingM,
              mainAxisSpacing: AppDimensions.paddingM,
              childAspectRatio: 1.2,
            ),
            itemCount: AppConstants.storyCategories.length,
            itemBuilder: (context, index) {
              final category = AppConstants.storyCategories[index];
              final color = AppColors.categoryColors[category] ?? 
                            AppColors.primaryRed;
              final emoji = AppAssets.categoryEmojis[category] ?? 
                           AppAssets.bookEmoji;
              
              return CategoryCard(
                title: category,
                emoji: emoji,
                color: color,
                onTap: () => viewModel.selectCategory(category),
              );
            },
          ),
        ],
      ),
    );
  }

  // 2. Yaş Grubu Seçimi
  Widget _buildAgeGroupSelection(StoryCreateViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppAssets.crownEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              const Expanded(
                child: Text(
                  'Hangi yaş grubu için?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.categoryColors[viewModel.selectedCategory]
                  ?.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Row(
              children: [
                Text(
                  AppAssets.categoryEmojis[viewModel.selectedCategory] ?? 
                    AppAssets.bookEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Text(
                  viewModel.selectedCategory ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppConstants.ageGroups.length,
            itemBuilder: (context, index) {
              final ageGroup = AppConstants.ageGroups[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                child: AgeGroupCard(
                  ageGroup: ageGroup,
                  color: AppColors.ageGroupColors[ageGroup] ?? 
                         AppColors.accentBlue,
                  onTap: () => viewModel.selectAgeGroup(ageGroup),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 3. Konu Girişi
  Widget _buildTopicInput(StoryCreateViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppAssets.magicEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              const Expanded(
                child: Text(
                  'Hikayen ne hakkında olsun?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingL),
          
          // Seçilen bilgiler
          Row(
            children: [
              _buildInfoChip(
                viewModel.selectedCategory ?? '',
                AppColors.categoryColors[viewModel.selectedCategory] ?? 
                  AppColors.primaryRed,
              ),
              const SizedBox(width: AppDimensions.paddingS),
              _buildInfoChip(
                viewModel.selectedAgeGroup ?? '',
                AppColors.ageGroupColors[viewModel.selectedAgeGroup] ?? 
                  AppColors.accentBlue,
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingXL),
          
          // Konu input
          CustomTextField(
            label: 'Hikaye Konusu',
            hint: 'Örn: Uzayda macera yaşayan bir astronot',
            controller: _topicController,
            maxLines: 3,
            maxLength: 200,
            onChanged: (value) => viewModel.setTopic(value),
          ),
          
          const SizedBox(height: AppDimensions.paddingL),
          
          // Konu önerileri
          if (viewModel.topicSuggestions.isNotEmpty) ...[
            const Text(
              'Veya bu konulardan birini seç:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Wrap(
              spacing: AppDimensions.paddingS,
              runSpacing: AppDimensions.paddingS,
              children: viewModel.topicSuggestions.map((suggestion) {
                return InkWell(
                  onTap: () {
                    _topicController.text = suggestion;
                    viewModel.setTopic(suggestion);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(
                        color: AppColors.primaryRed.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
          ],
          
          // Oluştur butonu
          AnimatedButton(
            text: 'Hikaye Oluştur',
            onPressed: viewModel.topic != null && viewModel.topic!.isNotEmpty
                ? () => viewModel.generateStory()
                : () {},
            icon: Icons.auto_awesome,
            gradientColors: AppColors.primaryGradient,
            width: double.infinity,
          ),
          
          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: AppDimensions.paddingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: AppDimensions.paddingS),
                  Expanded(
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 4. Önizleme
  Widget _buildPreview(StoryCreateViewModel viewModel, AuthViewModel authViewModel) {
    return StoryPreviewCard(
      title: viewModel.generatedTitle ?? '',
      content: viewModel.generatedContent ?? '',
      category: viewModel.selectedCategory ?? '',
      ageGroup: viewModel.selectedAgeGroup ?? '',
      onSave: () async {
        if (authViewModel.currentUserId != null) {
          final success = await viewModel.saveStory(authViewModel.currentUserId!);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hikaye kaydedildi! 🎉')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hikayeyi kaydetmek için giriş yapmalısınız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      onRegenerate: () => viewModel.regenerateStory(),
      onEdit: () {
        // TODO: Edit mode
      },
      isLoading: viewModel.isLoading,
    );
  }

  // 5. Tamamlandı
  Widget _buildComplete() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppAssets.trophyEmoji,
              style: const TextStyle(fontSize: 100),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            const Text(
              'Harika!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Text(
              'Hikayen başarıyla kaydedildi!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            AnimatedButton(
              text: 'Ana Sayfaya Dön',
              onPressed: () {
                context.go('/');
              },
              icon: Icons.home,
              width: double.infinity,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            AnimatedButton(
              text: 'Yeni Hikaye Oluştur',
              onPressed: () {
                context.read<StoryCreateViewModel>().reset();
              },
              icon: Icons.add,
              backgroundColor: AppColors.accentTeal,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
