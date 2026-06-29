import 'package:flutter/material.dart';
import 'package:historybox/core/core.dart';
import 'package:historybox/core/widgets/historybox_bottom_navigation_bar.dart';
import 'package:historybox/features/home/presentation/widgets/modern_home_header.dart';
import 'package:historybox/features/home/presentation/widgets/category_section.dart';
import 'package:historybox/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:historybox/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_assets.dart';
import '../core/translations/l10n/app_localizations.dart';
import '../core/thema/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/story_card.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/empty_state.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().listenToRecentStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final profileViewModel = context.watch<ProfileViewModel>();
    final homeViewModel = context.watch<HomeViewModel>();
    final userId = profileViewModel.userId;

    if (userId == null || userId.isEmpty) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.home_login_required_title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.home_login_required_subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.login_button_label),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AnimatedSoftBackground(
        colors: AppColors.premiumBackgroundGradient,
        backgroundColor: theme.colorScheme.surface,
        child: SafeArea(
          top: true,
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: ModernHomeHeader()),
              SliverToBoxAdapter(child: _buildPromoSection(context)),
              SliverToBoxAdapter(child: _buildQuickActions(context)),
              const SliverToBoxAdapter(child: CategorySection()),
              SliverToBoxAdapter(child: _buildRecentStories(context, homeViewModel)),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // Bottom padding for nav bar
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const HistoryBoxBottomNavigationBar(
        currentPageIndex: 0,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _quickAction(
              context,
              emoji: '🖍️',
              label: 'Çizimden Masal',
              colors: AppColors.oceanGradient,
              route: '/drawing-story',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _quickAction(
              context,
              emoji: '🌙',
              label: 'Ninni & Meditasyon',
              colors: AppColors.sweetGradient,
              route: '/relax',
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required String emoji,
    required String label,
    required List<Color> colors,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: AppShadows.soft(colors.first),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: AppShadows.glow(AppColors.brandIndigo),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: Stack(
          children: [
            // İmza gradyan zemin
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.premiumGradient,
                  ),
                ),
              ),
            ),
            // Dekoratif ışık halkaları
            Positioned(
              right: -28,
              top: -28,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              ),
            ),
            Positioned(
              right: 18,
              bottom: 16,
              child: Text(
                AppAssets.magicEmoji,
                style: const TextStyle(fontSize: 46),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Text(
                      l10n.home_promo_heading,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.home_promo_title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Material(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                      onTap: () => context.push('/story-create'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 13),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome,
                                color: AppColors.brandIndigo, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.home_promo_button,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.brandIndigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentStories(BuildContext context, HomeViewModel homeViewModel) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recent_stories_title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/history'),
                child: Text(l10n.view_all_button),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecentStoriesContent(context, homeViewModel),
        ],
      ),
    );
  }

  Widget _buildRecentStoriesContent(
    BuildContext context,
    HomeViewModel homeViewModel,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (homeViewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: LoadingWidget(message: 'Hikayeler yükleniyor...'),
      );
    }

    if (homeViewModel.errorMessage != null) {
      return EmptyState(
        emoji: AppAssets.cloudEmoji,
        title: 'Bir Hata Oluştu',
        message: homeViewModel.errorMessage!,
        buttonText: 'Tekrar Dene',
        onButtonPressed: () {
          homeViewModel.listenToRecentStories();
        },
      );
    }

    if (homeViewModel.recentStories.isEmpty) {
      return EmptyState(
        emoji: AppAssets.magicEmoji,
        title: 'Henüz Hikaye Yok',
        message: 'İlk hikayeni oluştur ve macerana başla!',
        buttonText: 'Hikaye Oluştur',
        onButtonPressed: () => context.go('/story-create'),
      );
    }

    return Column(
      children: homeViewModel.recentStories.map((story) {
        return StoryCard(
          title: story.title,
          category: story.category,
          ageGroup: story.ageGroup,
          createdAt: story.createdAt,
          isFavorite: story.isFavorite,
          preview: story.content.truncate(100),
          onTap: () => context.go('/story-detail/${story.id}'),
          onFavoriteToggle: null,
        );
      }).toList(),
    );
  }
}
