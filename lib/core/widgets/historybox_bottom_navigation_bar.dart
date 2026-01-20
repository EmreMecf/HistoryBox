import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../translations/l10n/app_localizations.dart';
import '../thema/app_colors.dart';

class HistoryBoxBottomNavigationBar extends StatelessWidget {
  final int currentPageIndex;

  const HistoryBoxBottomNavigationBar({
    super.key,
    this.currentPageIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: l10n.nav_bar_home_label,
        route: '/',
      ),
      _NavItem(
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        label: l10n.nav_bar_history_label,
        route: '/history',
      ),
      _NavItem(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add,
        label: l10n.nav_bar_create_label,
        route: '/story-create',
      ),
      _NavItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        label: l10n.nav_bar_calendar_label,
        route: '/calendar',
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              height: 78,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isActive = index == currentPageIndex;

                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        if (index == currentPageIndex) return;
                        context.go(item.route);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive
                                  ? AppColors.primaryRed
                                  : theme.colorScheme.onSurface.withOpacity(0.7),
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.1,
                                color: isActive
                                    ? AppColors.primaryRed
                                    : theme.colorScheme.onSurface.withOpacity(0.7),
                                fontWeight:
                                    isActive ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
