// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/animated_button.dart';
import '../../../../shared/widgets/story_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.sweetGradient,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
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
                                backgroundColor: Colors.white,
                                child: Text(
                                  AppAssets.crownEmoji,
                                  style: const TextStyle(fontSize: 50),
                                ),
                              ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      // Name
                      Text(
                        user?.displayName ?? 'Misafir',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user?.email != null)
                        Text(
                          user!.email!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
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
                          context.go('/story/create');
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
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
