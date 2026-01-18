import 'dart:ui';

import 'package:flutter/material.dart';
import '../thema/app_colors.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double height;
  final bool showDivider;
  final Color foregroundColor;

  const PremiumAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.height = kToolbarHeight,
    this.showDivider = true,
    this.foregroundColor = Colors.white,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      foregroundColor: foregroundColor,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      flexibleSpace: PremiumAppBarBackground(showDivider: showDivider),
    );
  }
}

class PremiumAppBarBackground extends StatelessWidget {
  final bool showDivider;

  const PremiumAppBarBackground({
    super.key,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.premiumAppBarGradient,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.white.withOpacity(0.02),
            ),
          ),
          if (showDivider)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
        ],
      ),
    );
  }
}
