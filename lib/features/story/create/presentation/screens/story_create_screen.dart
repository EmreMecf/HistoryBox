import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/core.dart';
import '../../../../../shared/widgets/animated_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../shared/widgets/category_card.dart';
import '../../../../../viewmodel/token_view_model.dart';
import '../../../../../viewmodel/profile_view_model.dart';
import '../../../../../services/injector.dart';
import '../../../../../shared/services/child_profile_service.dart';
import '../../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../viewmodels/story_create_view_model.dart';
import '../widgets/age_group_card.dart';
import '../widgets/story_preview_card.dart';
import '../../../../../core/widgets/premium_header_card.dart';

class StoryCreateScreen extends StatefulWidget {
  const StoryCreateScreen({super.key});

  @override
  State<StoryCreateScreen> createState() => _StoryCreateScreenState();
}

class _StoryCreateScreenState extends State<StoryCreateScreen> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _heroController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();
  final ChildProfileService _profileService = injector<ChildProfileService>();

  static const List<String> _languages = [
    'Türkçe',
    'English',
    'Deutsch',
    'Français',
    'Español',
    'العربية',
    'Italiano',
  ];

  @override
  void initState() {
    super.initState();
    _loadChildProfile();
  }

  Future<void> _loadChildProfile() async {
    final profile = await _profileService.load();
    if (!mounted) return;
    _heroController.text = profile.childName;
    _interestsController.text = profile.interests;
    final vm = context.read<StoryCreateViewModel>();
    vm.setChildName(profile.childName);
    vm.setInterests(profile.interests);
    vm.setLanguage(profile.language);
  }

  Future<void> _saveChildProfile(StoryCreateViewModel vm) async {
    await _profileService.save(ChildProfile(
      childName: _heroController.text.trim(),
      interests: _interestsController.text.trim(),
      language: vm.language,
    ));
  }

  @override
  void dispose() {
    _topicController.dispose();
    _heroController.dispose();
    _interestsController.dispose();
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
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.premiumBackgroundGradient.last,
          systemNavigationBarDividerColor: AppColors.premiumBackgroundGradient.last,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: AnimatedSoftBackground(
            colors: AppColors.premiumBackgroundGradient,
            backgroundColor: AppColors.premiumBackgroundGradient.last,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  BackButtonHeader(
                    title: 'Yeni Hikaye Oluştur',
                    fallbackRoute: '/',
                  ),
                  Expanded(
                    child: _buildBody(viewModel, authViewModel),
                  ),
                ],
              ),
            ),
          ),
        ),
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

  Widget _buildCategorySelection(StoryCreateViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumHeaderCard(
            icon: Icons.auto_awesome,
            title: 'Hikaye Türü Seç',
            subtitle: 'Sana uygun kategoriyle hikayeni başlat',
          ),
          const SizedBox(height: AppDimensions.paddingL),
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

  Widget _buildAgeGroupSelection(StoryCreateViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumHeaderCard(
            icon: Icons.child_care_rounded,
            title: 'Yaş Grubu',
            subtitle: 'Hikayeyi yaşa uygun hale getirelim',
          ),
          const SizedBox(height: AppDimensions.paddingL),
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

  Widget _buildTopicInput(StoryCreateViewModel viewModel) {
    final tokenViewModel = context.watch<TokenViewModel>();
    final isPremium = context.watch<ProfileViewModel>().isPremium;
    final hasTokens = isPremium || tokenViewModel.hasTokens;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumHeaderCard(
            icon: Icons.edit_rounded,
            title: 'Hikaye Konusu',
            subtitle: 'Kısa bir konu gir, gerisini AI yazsın',
          ),
          const SizedBox(height: AppDimensions.paddingL),
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
          
          CustomTextField(
            label: 'Hikaye Konusu',
            hint: 'Örn: Uzayda macera yaşayan bir astronot',
            controller: _topicController,
            maxLines: 3,
            maxLength: 200,
            onChanged: (value) => viewModel.setTopic(value),
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Kişiselleştirme — çocuğu masalın kahramanı yap
          CustomTextField(
            label: 'Kahramanın adı (isteğe bağlı)',
            hint: 'Örn: Elif',
            controller: _heroController,
            maxLength: 30,
            onChanged: (value) => viewModel.setChildName(value),
          ),

          const SizedBox(height: AppDimensions.paddingM),

          CustomTextField(
            label: 'İlgi alanları (isteğe bağlı)',
            hint: 'Örn: dinozorlar, uzay, futbol',
            controller: _interestsController,
            maxLength: 60,
            onChanged: (value) => viewModel.setInterests(value),
          ),

          const SizedBox(height: AppDimensions.paddingM),

          // Masal dili
          Row(
            children: [
              const Icon(Icons.translate_rounded,
                  color: AppColors.brandIndigo, size: 20),
              const SizedBox(width: 8),
              const Text('Masal dili:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: viewModel.language,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusM),
                  items: _languages
                      .map((l) =>
                          DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) viewModel.setLanguage(value);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingL),
          
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
          
          AnimatedButton(
            text: 'Hikaye Oluştur',
            onPressed: viewModel.topic != null && viewModel.topic!.isNotEmpty
                ? () async {
                    if (!hasTokens) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Token bitti. Hikaye oluşturamazsın.'),
                        ),
                      );
                      return;
                    }
                    // Çocuk profilini hatırla
                    await _saveChildProfile(viewModel);
                    // Önce hikayeyi üret; token'ı yalnızca başarılı üretimde harca
                    await viewModel.generateStory();
                    if (!context.mounted) return;
                    if (!isPremium &&
                        viewModel.currentStep == StoryCreationStep.preview) {
                      await tokenViewModel.useToken();
                    }
                  }
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
      onRegenerate: () async {
        final tokenViewModel = context.read<TokenViewModel>();
        final isPremium = context.read<ProfileViewModel>().isPremium;
        if (!isPremium && !tokenViewModel.hasTokens) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token bitti. Yeniden oluşturamazsın.'),
            ),
          );
          return;
        }
        await viewModel.regenerateStory();
        if (!mounted) return;
        // Token'ı yalnızca başarılı yeniden üretimde harca (premium hariç)
        if (!isPremium &&
            viewModel.currentStep == StoryCreationStep.preview) {
          await tokenViewModel.useToken();
        }
      },
      onEdit: () {
        // TODO: Edit mode
      },
      isLoading: viewModel.isLoading,
    );
  }

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
