import 'package:flutter/material.dart';
import '../core/translations/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/thema/app_colors.dart';
import '../core/widgets/back_button_header.dart';
import '../core/widgets/premium_header_card.dart';
import '../core/widgets/animated_soft_background.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: AnimatedSoftBackground(
          colors: AppColors.premiumBackgroundGradient,
          backgroundColor: theme.colorScheme.surface,
          child: Column(
            children: [
              BackButtonHeader(
                title: l10n.feedback_screen_app_bar_label,
                fallbackRoute: '/settings',
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            PremiumHeaderCard(
              icon: Icons.feedback_outlined,
              title: l10n.feedback_description_heading,
              subtitle: l10n.feedback_description_title,
            ),
            const SizedBox(height: 24),
            _buildContactButton(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              subtitle: 'support@historybox.com',
              onTap: () => _launchUrl('mailto:support@historybox.com'),
            ),
            const SizedBox(height: 16),
            _buildContactButton(
              context,
              icon: Icons.web,
              label: 'Website',
              subtitle: 'www.historybox.com',
              onTap: () => _launchUrl('https://historybox.com'),
            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
