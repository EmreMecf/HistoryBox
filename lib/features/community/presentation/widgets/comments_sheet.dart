// lib/features/community/presentation/widgets/comments_sheet.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../services/injector.dart';
import '../../../../services/models/firebase/comment_model.dart';
import '../../../../shared/services/community_service.dart';

Future<void> showStoryCommentsSheet(BuildContext context, String storyId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CommentsSheet(storyId: storyId),
  );
}

class _CommentsSheet extends StatefulWidget {
  final String storyId;
  const _CommentsSheet({required this.storyId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final CommunityService _service = injector<CommunityService>();
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (text.isEmpty || user == null || _sending) return;

    setState(() => _sending = true);
    try {
      await _service.addComment(
        widget.storyId,
        CommentModel(
          id: '',
          userId: user.uid,
          userName: user.displayName ?? 'Misafir',
          userPhoto: user.photoURL,
          text: text,
          createdAt: DateTime.now(),
        ),
      );
      _controller.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.mode_comment_rounded,
                      color: AppColors.brandIndigo, size: 20),
                  const SizedBox(width: 8),
                  Text('Yorumlar',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: theme.colorScheme.onSurface)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<CommentModel>>(
                stream: _service.comments(widget.storyId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final comments = snapshot.data ?? [];
                  if (comments.isEmpty) {
                    return Center(
                      child: Text(
                        'İlk yorumu sen yaz 💬',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textMutedOnLight),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    itemBuilder: (context, i) => _CommentTile(comments[i]),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Yorum yaz…',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  const _CommentTile(this.comment);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.brandIndigo.withValues(alpha: 0.12),
            backgroundImage:
                (comment.userPhoto != null && comment.userPhoto!.isNotEmpty)
                    ? NetworkImage(comment.userPhoto!)
                    : null,
            child: (comment.userPhoto == null || comment.userPhoto!.isEmpty)
                ? const Icon(Icons.person, size: 16, color: AppColors.brandIndigo)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.userName,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: theme.colorScheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.createdAt.toFormattedDate(),
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textMutedOnLight),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.text,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
