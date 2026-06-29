import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/translations/l10n/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/category_card.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final categories = [
      {'name': l10n.category_fairy_tale, 'emoji': '🧚', 'color': AppColors.categoryMagenta},
      {'name': l10n.category_adventure, 'emoji': '🗺️', 'color': AppColors.categoryOrange},
      {'name': l10n.category_educational, 'emoji': '📚', 'color': AppColors.categoryGreen},
      {'name': l10n.category_bedtime, 'emoji': '🌙', 'color': AppColors.categoryPurple},
      {'name': l10n.category_fantasy, 'emoji': '🐉', 'color': AppColors.categoryBlue},
      {'name': l10n.category_science, 'emoji': '🔬', 'color': AppColors.categoryTeal},
    ];

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.story_categories_title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
                title: category['name'] as String,
                emoji: category['emoji'] as String,
                color: category['color'] as Color,
                onTap: () {
                  context.push('/story-list/${category['name']}');
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
