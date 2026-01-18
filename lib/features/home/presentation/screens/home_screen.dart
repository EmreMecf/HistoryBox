// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/category_card.dart';
import '../../../../shared/widgets/story_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/animated_greeting_card.dart';
import '../widgets/category_section.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/premium_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    
    // Floating animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Son hikayeleri dinlemeye başla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().listenToRecentStories();
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final homeViewModel = context.watch<HomeViewModel>();

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
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            _buildAppBar(context, authViewModel),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Hoşgeldin Kartı
                  AnimatedGreetingCard(
                    userName: authViewModel.currentUser?.displayName ?? 'Arkadaşım',
                    floatingAnimation: _floatingController,
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingXL),
                  
                  // Kategoriler
                  const CategorySection(),
                  
                  const SizedBox(height: AppDimensions.paddingXL),
                  
                  // Son Hikayeler Başlık
                  Row(
                    children: [
                      Text(
                        AppAssets.starEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      const Text(
                        'Son Oluşturulan Hikayeler',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingM),
                  
                  // Son Hikayeler Listesi
                  _buildRecentStories(homeViewModel, authViewModel),
                ]),
              ),
            ),
          ],
        ),
      ),
      
      // Floating Action Button - Yeni Hikaye
      floatingActionButton: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -10 * _floatingController.value),
            child: FloatingActionButton.extended(
              onPressed: () {
                context.go('/story-create');
              },
              icon: Text(
                AppAssets.magicEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              label: const Text(
                'Yeni Hikaye',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.accentOrange,
              elevation: 8,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AuthViewModel authViewModel) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: const Text(
        AppConstants.appName,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      flexibleSpace: const PremiumAppBarBackground(),
      actions: [
        // Profil
        IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: authViewModel.currentUser?.photoURL != null
                ? ClipOval(
                    child: Image.network(
                      authViewModel.currentUser!.photoURL!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    AppAssets.crownEmoji,
                    style: const TextStyle(fontSize: 18),
                  ),
          ),
          onPressed: () {
            context.go('/profile');
          },
        ),
        const SizedBox(width: AppDimensions.paddingS),
      ],
    );
  }

  Widget _buildRecentStories(HomeViewModel homeViewModel, AuthViewModel authViewModel) {
    if (homeViewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.paddingXL),
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
        onButtonPressed: () {
          context.go('/story-create');
        },
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
          onTap: () {
            context.go('/story/detail/${story.id}');
          },
          onFavoriteToggle: authViewModel.isAuthenticated
              ? () {
                  // TODO: Toggle favorite
                }
              : null,
        );
      }).toList(),
    );
  }
}
