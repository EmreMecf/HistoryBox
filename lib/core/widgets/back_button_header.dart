import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackButtonHeader extends StatelessWidget {
  final String? title;
  final String fallbackRoute;
  final EdgeInsets padding;

  const BackButtonHeader({
    super.key,
    this.title,
    this.fallbackRoute = '/',
    this.padding = const EdgeInsets.fromLTRB(8, 8, 12, 8),
  });

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: theme.colorScheme.onSurface,
            onPressed: () => _handleBack(context),
          ),
          if (title != null && title!.isNotEmpty)
            Expanded(
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
