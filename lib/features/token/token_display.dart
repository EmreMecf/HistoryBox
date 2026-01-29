import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/thema/app_colors.dart';
import '../../core/translations/l10n/app_localizations.dart';
import '../../viewmodel/token_view_model.dart';
import 'token_purchase_dialog.dart';

class TokenDisplay extends StatefulWidget {
  const TokenDisplay({super.key});

  @override
  State<TokenDisplay> createState() => _TokenDisplayState();
}

class _TokenDisplayState extends State<TokenDisplay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<TokenViewModel>(context, listen: false);
      viewModel.loadTokens();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textPrimaryColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Consumer<TokenViewModel>(
      builder: (context, viewModel, _) {
        return GestureDetector(
          onTap: () => _showTokenInfo(context, viewModel),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryRed.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.toll_rounded,
                  color: AppColors.primaryRed,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  "${viewModel.tokenCount}",
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTokenInfo(BuildContext context, TokenViewModel viewModel) {
    final textPrimaryColor = Theme.of(context).colorScheme.onSurface;
    final textSecondaryColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final localizations = AppLocalizations.of(context)!;
    viewModel.setContext(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text(
          localizations.buyTokens,
          style: TextStyle(color: textPrimaryColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.tokenInfoText,
              style: TextStyle(color: textSecondaryColor),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.toll_rounded, color: AppColors.primaryRed),
                const SizedBox(width: 8),
                Text(
                  localizations.currentTokens(viewModel.tokenCount),
                  style: TextStyle(
                    color: textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel_button),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPurchaseDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: Text(localizations.buyTokens),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TokenPurchaseDialog(),
    );
  }
}
