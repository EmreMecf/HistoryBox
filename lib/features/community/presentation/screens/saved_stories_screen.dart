// lib/features/community/presentation/screens/saved_stories_screen.dart
//
// 🔖 Kaydedilen (bookmark) masallar.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../services/injector.dart';
import '../../../../shared/services/community_service.dart';

class SavedStoriesScreen extends StatelessWidget {
  const SavedStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = injector<CommunityService>();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AnimatedSoftBackground(
        colors: AppColors.premiumBackgroundGradient,
        backgroundColor: theme.colorScheme.surface,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              BackButtonHeader(
                title: 'Kayıtlı Masallar',
                fallbackRoute: '/profile',
              ),
              Expanded(
                child: uid == null
                    ? _empty(context, 'Giriş yapmalısın')
                    : StreamBuilder<List<Map<String, dynamic>>>(
                        stream: service.savedBookmarks(uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final items = snapshot.data ?? [];
                          if (items.isEmpty) {
                            return _empty(
                                context, 'Henüz kaydettiğin masal yok 🔖');
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: items.length,
                            itemBuilder: (context, i) => _SavedCard(
                              data: items[i],
                              onRemove: () => service.removeBookmark(
                                  uid, items[i]['storyId'] as String),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔖', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textMutedOnLight),
          ),
        ],
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRemove;

  const _SavedCard({required this.data, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storyId = data['storyId'] as String;
    final title = data['title'] as String? ?? 'Masal';
    final category = data['category'] as String? ?? '';
    final author = data['authorName'] as String?;
    final categoryColor =
        AppColors.categoryColors[category] ?? AppColors.brandIndigo;

    return GestureDetector(
      onTap: () => context.push('/story-detail/$storyId'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppShadows.soft(AppColors.brandIndigo),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_stories_rounded, color: categoryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge
                        .copyWith(color: theme.colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [if (category.isNotEmpty) category, if (author != null) author]
                        .join(' • '),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMutedOnLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.bookmark_remove_rounded,
                  color: AppColors.gold),
            ),
          ],
        ),
      ),
    );
  }
}
