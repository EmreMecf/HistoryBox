// lib/features/story/detail/presentation/screens/story_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:historybox/core/translations/l10n/app_localizations.dart';
import '../../../../../core/core.dart';
import '../../../../../services/models/firebase/story_model.dart';
import '../../../../../shared/services/story_service.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../services/injector.dart';
import '../../../../../services/models/network/result.dart';
import '../../../../../services/advert/ad_service.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({
    super.key,
    required this.storyId,
  });

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final StoryService _storyService = injector<StoryService>();
  StoryModel? _story;
  bool _isLoading = true;
  String? _errorMessage;
  bool _didShowInterstitial = false;

  @override
  void initState() {
    super.initState();
    _loadStory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInterstitialOnce();
    });
  }

  Future<void> _showInterstitialOnce() async {
    if (_didShowInterstitial) return;
    _didShowInterstitial = true;
    await injector<AdService>().showInterstitialAd();
  }

  Future<void> _loadStory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _storyService.getStory(widget.storyId);

    if (result is Success<StoryModel, Exception>) {
      setState(() {
        _story = (result as Success<StoryModel, Exception>).value;
        _isLoading = false;
      });
    } else if (result is Failure<StoryModel, Exception>) {
      setState(() {
        _errorMessage = (result as Failure<StoryModel, Exception>).exception.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: SafeArea(
          child: LoadingWidget(message: 'Hikaye yükleniyor...'),
        ),
      );
    }

    if (_errorMessage != null || _story == null) {
      return Scaffold(
        body: SafeArea(
          child: EmptyState(
            emoji: AppAssets.cloudEmoji,
            title: 'Bir Hata Oluştu',
            message: _errorMessage ?? 'Hikaye bulunamadı',
            buttonText: 'Tekrar Dene',
            onButtonPressed: _loadStory,
          ),
        ),
      );
    }

    final categoryColor = AppColors.categoryColors[_story!.category] ??
                          AppColors.primaryRed;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: AnimatedSoftBackground(
          colors: AppColors.premiumBackgroundGradient,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: BackButtonHeader(
                  title: _story!.title,
                  fallbackRoute: '/history',
                ),
              ),
              // Content
              SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            AppAssets.categoryEmojis[_story!.category] ??
                                AppAssets.bookEmoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Text(
                          _story!.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Metadata
                Row(
                  children: [
                    _buildChip(
                      _story!.category,
                      categoryColor,
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    _buildChip(
                      _story!.ageGroup,
                      AppColors.ageGroupColors[_story!.ageGroup] ??
                        AppColors.accentBlue,
                    ),
                    const Spacer(),
                    Text(
                      _story!.createdAt.toFormattedDate(),
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingXL),

                const BannerAdSlot(),

                const SizedBox(height: AppDimensions.paddingXL),

                // Content
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
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
                  child: Text(
                    _story!.content,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingXL),
              ]),
            ),
          ),
            ],
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        tooltip: _story!.isFavorite
            ? AppLocalizations.of(context)!.favorite_remove_button
            : AppLocalizations.of(context)!.favorite_button,
        onPressed: () async {
          final isCurrentlyFavorite = _story!.isFavorite;
          final newFavoriteState = !isCurrentlyFavorite;

          // Optimistic update
          setState(() {
            _story = _story!.copyWith(isFavorite: newFavoriteState);
          });

          final result = await _storyService.toggleFavorite(
            _story!.id,
            newFavoriteState,
          );

          if (result is Failure) {
            if (!context.mounted) return;
            // Revert if failed
            setState(() {
              _story = _story!.copyWith(isFavorite: isCurrentlyFavorite);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Hata: ${result.exception}',
                ),
              ),
            );
          }
        },
        child: Icon(
          _story!.isFavorite ? Icons.favorite : Icons.favorite_border,
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
