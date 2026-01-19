// lib/features/story/list/presentation/screens/story_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/core.dart';
import '../../../../../services/models/firebase/story_model.dart';
import '../../../../../shared/services/story_service.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/story_card.dart';
import '../../../../../services/injector.dart';
import '../../../../../core/widgets/premium_app_bar.dart';

class StoryListScreen extends StatefulWidget {
  final String category;

  const StoryListScreen({
    super.key,
    required this.category,
  });

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  final StoryService _storyService = injector<StoryService>();

  @override
  Widget build(BuildContext context) {
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
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppAssets.categoryEmojis[widget.category] ??
                    AppAssets.bookEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            flexibleSpace: const PremiumAppBarBackground(),
          ),

          // Story List
          StreamBuilder<List<StoryModel>>(
            stream: _storyService.getStoriesByCategory(widget.category),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: LoadingWidget(message: 'Hikayeler yükleniyor...'),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: EmptyState(
                    emoji: AppAssets.cloudEmoji,
                    title: 'Bir Hata Oluştu',
                    message: snapshot.error.toString(),
                    buttonText: 'Tekrar Dene',
                    onButtonPressed: () {
                      setState(() {});
                    },
                  ),
                );
              }

              final stories = snapshot.data ?? [];

              if (stories.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    emoji: AppAssets.magicEmoji,
                    title: 'Henüz Hikaye Yok',
                    message: 'Bu kategoride henüz hikaye oluşturulmamış.',
                    buttonText: 'Hikaye Oluştur',
                    onButtonPressed: () {
                      context.go('/story-create');
                    },
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
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
                          await _storyService.toggleFavorite(
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
          ],
        ),
      ),
    );
  }
}
