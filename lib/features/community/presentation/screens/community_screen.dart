// lib/features/community/presentation/screens/community_screen.dart
//
// 🌐 Topluluk akışı — herkesin paylaştığı masallar.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/historybox_bottom_navigation_bar.dart';
import '../../../../core/widgets/premium_badge.dart';
import '../../../../services/injector.dart';
import '../../../../services/models/firebase/story_model.dart';
import '../../../../shared/services/community_service.dart';
import '../../../../shared/services/parental_controls_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityService _service = injector<CommunityService>();
  final ParentalControlsService _parental =
      injector<ParentalControlsService>();
  final TextEditingController _pinController = TextEditingController();
  FeedSort _sort = FeedSort.newest;

  bool _checked = false;
  bool _locked = false;
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final enabled = await _parental.isCommunityEnabled();
    final hasPin = await _parental.hasPin();
    if (!mounted) return;
    setState(() {
      _locked = !enabled;
      _hasPin = hasPin;
      _checked = true;
    });
  }

  Future<void> _tryUnlock() async {
    final ok = await _parental.verifyPin(_pinController.text.trim());
    if (!mounted) return;
    if (ok) {
      _pinController.clear();
      setState(() => _locked = false);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('PIN hatalı')));
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AnimatedSoftBackground(
        colors: AppColors.premiumBackgroundGradient,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Text('🌙', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'Topluluk',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_checked)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_locked)
                Expanded(child: _buildLocked(context))
              else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _sortChip('En Yeni', FeedSort.newest),
                    const SizedBox(width: 8),
                    _sortChip('Popüler', FeedSort.popular),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<StoryModel>>(
                  stream: _service.publicFeed(sort: _sort),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Akış yüklenemedi.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMutedOnLight,
                            ),
                          ),
                        ),
                      );
                    }
                    final stories = snapshot.data ?? [];
                    if (stories.isEmpty) {
                      return _buildEmpty(context);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                      itemCount: stories.length,
                      itemBuilder: (context, i) =>
                          _CommunityCard(story: stories[i]),
                    );
                  },
                ),
              ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const HistoryBoxBottomNavigationBar(
        currentPageIndex: 3,
      ),
    );
  }

  Widget _buildLocked(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Topluluk kapalı',
              style: AppTextStyles.titleMedium
                  .copyWith(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              _hasPin
                  ? 'Devam etmek için ebeveyn PIN’ini gir'
                  : 'Ebeveyn tarafından kapatıldı. Ayarlar > Ebeveyn Kontrolleri’nden açabilirsin.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMutedOnLight),
            ),
            if (_hasPin) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'PIN',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _tryUnlock,
                  child: const Text('Kilidi Aç'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sortChip(String label, FeedSort value) {
    final selected = _sort == value;
    return GestureDetector(
      onTap: () => setState(() => _sort = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brandIndigo
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          border: Border.all(
            color: selected ? AppColors.brandIndigo : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Henüz paylaşılan masal yok',
            style: AppTextStyles.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'İlk masalını paylaşan sen ol!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMutedOnLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final StoryModel story;
  const _CommunityCard({required this.story});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor =
        AppColors.categoryColors[story.category] ?? AppColors.brandIndigo;

    return GestureDetector(
      onTap: () => context.push('/story-detail/${story.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppShadows.soft(AppColors.brandIndigo),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: categoryColor.withValues(alpha: 0.15),
                  backgroundImage: (story.authorPhoto != null &&
                          story.authorPhoto!.isNotEmpty)
                      ? NetworkImage(story.authorPhoto!)
                      : null,
                  child: (story.authorPhoto == null ||
                          story.authorPhoto!.isEmpty)
                      ? Icon(Icons.person, size: 18, color: categoryColor)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          story.authorName ?? 'Misafir',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (story.authorIsPremium) ...[
                        const SizedBox(width: 6),
                        const PremiumBadge(size: 16),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                  child: Text(
                    story.category,
                    style: AppTextStyles.labelSmall.copyWith(color: categoryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              story.title,
              style: AppTextStyles.titleMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              story.content,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMutedOnLight,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.favorite_rounded,
                    size: 18, color: AppColors.accentPink),
                const SizedBox(width: 4),
                Text('${story.likeCount}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: theme.colorScheme.onSurface)),
                const SizedBox(width: 16),
                Icon(Icons.mode_comment_rounded,
                    size: 17, color: AppColors.accentBlue),
                const SizedBox(width: 4),
                Text('${story.commentCount}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: theme.colorScheme.onSurface)),
                const Spacer(),
                Text('Oku →',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.brandIndigo)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
