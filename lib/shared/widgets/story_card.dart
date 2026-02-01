// lib/shared/widgets/story_card.dart
import 'package:flutter/material.dart';
import '../../core/thema/app_dimensions.dart';
import '../../core/thema/app_colors.dart';
import '../../core/extensions/date_extensions.dart';
import 'package:historybox/core/translations/l10n/app_localizations.dart';

class StoryCard extends StatelessWidget {
  final String title;
  final String category;
  final String ageGroup;
  final DateTime createdAt;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final String? preview;

  const StoryCard({
    super.key,
    required this.title,
    required this.category,
    required this.ageGroup,
    required this.createdAt,
    required this.isFavorite,
    required this.onTap,
    this.onFavoriteToggle,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor =
        AppColors.categoryColors[category] ?? AppColors.primaryRed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                        Colors.white.withOpacity(0.04),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusL),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onFavoriteToggle != null)
                            IconButton(
                              onPressed: onFavoriteToggle,
                              tooltip: isFavorite
                                  ? AppLocalizations.of(context)
                                      ?.removeFromFavorites
                                  : AppLocalizations.of(context)
                                      ?.addToFavorites,
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      if (preview != null) ...[
                        Text(
                          preview!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                      ],
                      Row(
                        children: [
                          _buildChip(
                            context,
                            category,
                            categoryColor,
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          _buildChip(
                            context,
                            ageGroup,
                            AppColors.ageGroupColors[ageGroup] ??
                                AppColors.accentBlue,
                          ),
                          const Spacer(),
                          Text(
                            createdAt.toFormattedDate(),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
