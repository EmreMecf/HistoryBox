import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/thema/app_colors.dart';
import '../../core/thema/app_dimensions.dart';
import '../../core/translations/l10n/app_localizations.dart';
import '../../viewmodel/token_view_model.dart';
import 'token_purchase_dialog.dart';

class TokenWarningDialog extends StatelessWidget {
  const TokenWarningDialog({Key? key}) : super(key: key);

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
              localizations.insufficientTokens,
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
                color: AppColors.accentOrange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.accentOrange,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.tokenWarningMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondaryColor),
            ),
            const SizedBox(height: 24),
            InkWell(
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
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.video_library, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      localizations.watchAd(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const TokenPurchaseDialog(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(color: AppColors.primaryRed),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, color: AppColors.primaryRed),
                    const SizedBox(width: 8),
                    Text(
                      localizations.buyTokens,
                      style: const TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
}
