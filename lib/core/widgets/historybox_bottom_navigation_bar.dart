import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../translations/l10n/app_localizations.dart';
import '../thema/app_colors.dart';
import '../thema/app_dimensions.dart';

class HistoryBoxBottomNavigationBar extends StatelessWidget {
  final int currentPageIndex;

  const HistoryBoxBottomNavigationBar({
    super.key,
    this.currentPageIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final profileLabel =
        Localizations.localeOf(context).languageCode == 'en' ? 'Profile' : 'Profil';

    final items = [
      _NavItem(
        icon: Icons.home_rounded,
        label: l10n.nav_bar_home_label,
        route: '/',
        index: 0,
      ),
      _NavItem(
        icon: Icons.auto_stories_rounded,
        label: l10n.nav_bar_history_label,
        route: '/history',
        index: 1,
      ),
      // index 2 = ortadaki "+" (aşağıda ayrı render edilir)
      _NavItem(
        icon: Icons.public_rounded,
        label: Localizations.localeOf(context).languageCode == 'en'
            ? 'Community'
            : 'Topluluk',
        route: '/community',
        index: 3,
      ),
      _NavItem(
        icon: Icons.person_rounded,
        label: profileLabel,
        route: '/profile',
        index: 4,
      ),
    ];

    final barColor = isDark
        ? AppColors.surfaceDark.withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.82);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : AppColors.borderLight.withValues(alpha: 0.9);
    final inactive = isDark
        ? AppColors.textMutedOnDark
        : AppColors.textMutedOnLight;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: barColor,
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : AppColors.brandIndigo)
                            .withValues(alpha: isDark ? 0.35 : 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: -6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildItem(context, items[0], inactive),
                      _buildItem(context, items[1], inactive),
                      const SizedBox(width: 64), // ortadaki + için boşluk
                      _buildItem(context, items[2], inactive),
                      _buildItem(context, items[3], inactive),
                    ],
                  ),
                ),
              ),
            ),
            // Ortadaki yükseltilmiş gradyan "+" butonu
            Positioned(
              top: -8,
              child: GestureDetector(
                onTap: () => context.push('/story-create'),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.primaryGradient,
                    ),
                    border: Border.all(
                      color: (isDark ? AppColors.backgroundDark : Colors.white),
                      width: 4,
                    ),
                    boxShadow: AppShadows.glow(AppColors.brandIndigo),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, _NavItem item, Color inactiveColor) {
    final isActive = item.index == currentPageIndex;
    final color = isActive ? AppColors.brandIndigo : inactiveColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        onTap: () {
          if (item.index == currentPageIndex) return;
          context.go(item.route);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: color, size: 25),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.0,
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  final int index;

  _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.index,
  });
}
