// lib/features/community/presentation/widgets/social_action_bar.dart
//
// Beğeni / yorum / kaydet / yayınla aksiyon çubuğu (canlı sayaçlarla).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../services/injector.dart';
import '../../../../services/apis/moderation_service.dart';
import '../../../../viewmodel/profile_view_model.dart';
import '../../../../services/models/firebase/story_model.dart';
import '../../../../shared/services/community_service.dart';
import 'comments_sheet.dart';

class SocialActionBar extends StatelessWidget {
  final StoryModel story;
  const SocialActionBar({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = injector<CommunityService>();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .doc(story.id)
          .snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data();
        final likeCount = (data?['likeCount'] as int?) ?? story.likeCount;
        final commentCount =
            (data?['commentCount'] as int?) ?? story.commentCount;
        final isPublic = (data?['isPublic'] as bool?) ?? story.isPublic;
        final isOwner = uid != null && uid == story.userId;

        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppShadows.soft(AppColors.brandIndigo),
          ),
          child: Row(
            children: [
              // Beğeni
              StreamBuilder<bool>(
                stream: uid == null
                    ? Stream<bool>.value(false)
                    : service.isLiked(story.id, uid),
                builder: (context, likeSnap) {
                  final liked = likeSnap.data ?? false;
                  return _Action(
                    icon: liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: '$likeCount',
                    color: AppColors.accentPink,
                    active: liked,
                    onTap: uid == null
                        ? null
                        : () => service.toggleLike(story.id, uid),
                  );
                },
              ),
              const SizedBox(width: 8),
              // Yorum
              _Action(
                icon: Icons.mode_comment_outlined,
                label: '$commentCount',
                color: AppColors.accentBlue,
                onTap: () => showStoryCommentsSheet(context, story.id),
              ),
              const SizedBox(width: 8),
              // Kaydet (bookmark)
              StreamBuilder<bool>(
                stream: uid == null
                    ? Stream<bool>.value(false)
                    : service.isBookmarked(uid, story.id),
                builder: (context, bmSnap) {
                  final saved = bmSnap.data ?? false;
                  return _Action(
                    icon: saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    label: saved ? 'Kayıtlı' : 'Kaydet',
                    color: AppColors.gold,
                    active: saved,
                    onTap: uid == null
                        ? null
                        : () => service.toggleBookmark(uid, story),
                  );
                },
              ),
              const Spacer(),
              // Yayınla / yayında (yalnızca sahibi)
              if (isOwner)
                GestureDetector(
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final user = FirebaseAuth.instance.currentUser!;
                    final authorPremium =
                        context.read<ProfileViewModel>().isPremium;
                    if (isPublic) {
                      await service.unpublish(story.id);
                      return;
                    }
                    // Yayınlamadan önce içerik moderasyonu
                    messenger.showSnackBar(const SnackBar(
                        content: Text('İçerik kontrol ediliyor…')));
                    final safe = await injector<ModerationService>()
                        .isSafe('${story.title}\n${story.content}');
                    messenger.hideCurrentSnackBar();
                    if (!safe) {
                      messenger.showSnackBar(const SnackBar(
                        content: Text(
                            'Bu içerik topluluk için uygun bulunmadı.'),
                      ));
                      return;
                    }
                    await service.publish(
                      story.id,
                      authorName: user.displayName ?? 'Misafir',
                      authorPhoto: user.photoURL,
                      authorIsPremium: authorPremium,
                    );
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Masalın toplulukta paylaşıldı 🌙')));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: isPublic
                          ? null
                          : const LinearGradient(
                              colors: AppColors.primaryGradient),
                      color: isPublic
                          ? AppColors.success.withValues(alpha: 0.14)
                          : null,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPublic
                              ? Icons.check_circle_rounded
                              : Icons.ios_share_rounded,
                          size: 16,
                          color: isPublic ? AppColors.success : Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPublic ? 'Yayında' : 'Paylaş',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isPublic ? AppColors.success : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback? onTap;

  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: active ? color : theme.colorScheme.onSurface),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: active ? color : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
