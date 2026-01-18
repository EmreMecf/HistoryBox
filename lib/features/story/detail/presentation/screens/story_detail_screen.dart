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
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _story!.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [categoryColor, categoryColor.withOpacity(0.7)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Opacity(
                        opacity: 0.2,
                        child: Text(
                          AppAssets.categoryEmojis[_story!.category] ?? 
                            AppAssets.bookEmoji,
                          style: const TextStyle(fontSize: 150),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
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
                  child: Text(
                    _story!.content,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.8,
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
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
