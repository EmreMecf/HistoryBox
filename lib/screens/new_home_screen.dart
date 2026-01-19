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

  Widget _buildPromoSection(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.premiumWarmGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPink.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.home_promo_heading,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.home_promo_title,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/story-create'),
            icon: const Icon(Icons.add_circle),
            label: Text(l10n.home_promo_button),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.accentOrange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ],
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
                  color: theme.colorScheme.onBackground,
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
