// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/animated_button.dart';
import '../../../../core/translations/l10n/app_localizations.dart';
import '../../../../shared/widgets/story_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../core/widgets/premium_header_card.dart';
import '../../../../shared/services/story_service.dart';
import '../../../../services/injector.dart';
import '../../../../viewmodel/thema_view_model.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final themeViewModel = context.watch<ThemeViewModel>();
    final storyService = injector<StoryService>();
    final user = authViewModel.currentUser;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.premiumBackgroundGradient,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar with Profile Header
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              foregroundColor: Colors.white,
              title: Text(
                l10n.profile_screen_app_bar_label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.premiumAppBarGradient,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 56),
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.7),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: user?.photoURL != null
                            ? ClipOval(
                                child: Image.network(
                                  user!.photoURL!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Text(
                                  AppAssets.crownEmoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      // Name
                      Text(
                        user?.displayName ?? 'Misafir',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (user?.email != null)
                        Text(
                          user!.email!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PremiumHeaderCard(
                    icon: Icons.auto_awesome,
                    title: 'Profilin Hazır',
                    subtitle: 'Hikayelerini yönet ve ayarlarını kişiselleştir',
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  // Settings Section
                  _buildSectionTitle('Ayarlar', AppAssets.magicEmoji),
                  const SizedBox(height: AppDimensions.paddingM),

                  // Theme Toggle
                  _buildSettingCard(
                    context,
                    icon: themeViewModel.isDarkMode
                        ? Icons.wb_sunny_rounded
                        : Icons.nightlight_round,
                    title: 'Tema',
                    subtitle: themeViewModel.isDarkMode
                        ? 'Karanlık Mod'
                        : 'Aydınlık Mod',
                    trailing: Switch(
                      value: themeViewModel.isDarkMode,
                      onChanged: (_) => themeViewModel.toggleTheme(),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // My Stories Section
                  if (user != null) ...[
                    _buildSectionTitle('Hikayelerim', AppAssets.bookEmoji),
                    const SizedBox(height: AppDimensions.paddingM),
                  ],
                ],
              ),
            ),
          ),

          // My Stories List
          if (user != null)
            StreamBuilder(
              stream: storyService.getUserStories(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.paddingXL),
                      child: LoadingWidget(message: 'Hikayeler yükleniyor...'),
                    ),
                  );
                }

                final stories = snapshot.data ?? [];

                if (stories.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: EmptyState(
                        emoji: AppAssets.magicEmoji,
                        title: 'Henüz Hikaye Yok',
                        message: 'İlk hikayeni oluştur!',
                        buttonText: 'Hikaye Oluştur',
                        onButtonPressed: () {
                          context.go('/story-create');
                        },
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final story = stories[index];
                        return StoryCard(
                          title: story.title,
                          category: story.category,
                          ageGroup: story.ageGroup,
                          createdAt: story.createdAt,
                          isFavorite: story.isFavorite,
                          preview: story.content.truncate(100),
                          onTap: () {
                            context.go('/story/detail/${story.id}');
                          },
                          onFavoriteToggle: () async {
                            await storyService.toggleFavorite(
                              story.id,
                              !story.isFavorite,
                            );
                          },
                        );
                      },
                      childCount: stories.length,
                    ),
                  ),
                );
              },
            ),

          // Logout Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: AnimatedButton(
                text: 'Çıkış Yap',
                onPressed: () => authViewModel.signOut(),
                icon: Icons.logout,
                backgroundColor: AppColors.error,
                width: double.infinity,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.paddingXL),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String emoji) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: AppDimensions.paddingS),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryRed),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
