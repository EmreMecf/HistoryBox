import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/thema/app_colors.dart';
import '../../core/thema/app_dimensions.dart';
import '../../core/translations/l10n/app_localizations.dart';
import '../../viewmodel/token_view_model.dart';

class TokenPurchaseDialog extends StatelessWidget {
  const TokenPurchaseDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tokenViewModel = Provider.of<TokenViewModel>(context);
    tokenViewModel.setContext(context);

    final textPrimaryColor = Theme.of(context).colorScheme.onSurface;
    final textSecondaryColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final localizations = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.buyTokens,
              style: TextStyle(
                color: textPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.toll_rounded,
                color: AppColors.primaryRed,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.currentTokens(tokenViewModel.tokenCount),
              style: TextStyle(
                color: textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ..._buildTokenPackages(context, tokenViewModel),
            const SizedBox(height: 16),
            _buildAdButton(context, tokenViewModel),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                localizations.cancel_button,
                style: TextStyle(color: textSecondaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTokenPackages(BuildContext context, TokenViewModel viewModel) {
    final packages = viewModel.getTokenPackages();
    final localizations = AppLocalizations.of(context)!;

    return packages.map((package) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            onTap: () async {
              Navigator.pop(context);
              final success = await viewModel.purchaseTokens(package['id']);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      localizations.tokensPurchased(package['amount']),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.primaryRed,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryRed,
                    AppColors.primaryRed.withBlue(220),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.toll_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        "${package['amount']} Token",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    package['price'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildAdButton(BuildContext context, TokenViewModel tokenViewModel) {
    final textPrimaryColor = Theme.of(context).colorScheme.onSurface;
    final localizations = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () async {
        Navigator.pop(context);

        final success = await tokenViewModel.addTokensByAd();

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.watchAd(2),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primaryRed,
            ),
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tokenViewModel.errorMessage ?? localizations.error_occurred,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.primaryRed),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, color: textPrimaryColor),
            const SizedBox(width: 8),
            Text(
              localizations.watchAd(2),
              style: TextStyle(
                color: textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
