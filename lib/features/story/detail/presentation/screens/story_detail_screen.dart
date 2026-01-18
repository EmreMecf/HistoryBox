// lib/features/story/detail/presentation/screens/story_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../../../core/core.dart';
import '../../../../../services/models/firebase/story_model.dart';
import '../../../../../shared/services/story_service.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/animated_button.dart';
import '../../../../../services/injector.dart';
import '../../../../../services/models/network/result.dart';
import '../../../../../core/widgets/premium_app_bar.dart';

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

  @override
  void initState() {
    super.initState();
    _loadStory();
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hikaye'),
        ),
        body: const LoadingWidget(message: 'Hikaye yükleniyor...'),
      );
    }

    if (_errorMessage != null || _story == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hata'),
        ),
        body: EmptyState(
          emoji: AppAssets.cloudEmoji,
          title: 'Bir Hata Oluştu',
          message: _errorMessage ?? 'Hikaye bulunamadı',
          buttonText: 'Tekrar Dene',
          onButtonPressed: _loadStory,
        ),
      );
    }

    final categoryColor = AppColors.categoryColors[_story!.category] ?? 
                          AppColors.primaryRed;

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
            title: Text(
              _story!.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            flexibleSpace: const PremiumAppBarBackground(),
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
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _storyService.toggleFavorite(
            _story!.id,
            !_story!.isFavorite,
          );
          
          _loadStory(); // Reload to get updated favorite status
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
