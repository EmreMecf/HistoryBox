import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/translations/l10n/app_localizations.dart';
import 'package:historybox/viewmodel/thema_view_model.dart';
import 'package:historybox/viewmodel/language_view_model.dart';
import 'package:historybox/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/thema/app_colors.dart';
import '../core/thema/app_palette.dart';
import '../core/widgets/back_button_header.dart';
import '../core/widgets/premium_header_card.dart';
import '../core/widgets/animated_soft_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final themeViewModel = context.watch<ThemeViewModel>();
    final languageViewModel = context.watch<LanguageViewModel>();

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
                title: l10n.setting_screen_app_bar_label,
                fallbackRoute: '/',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
            PremiumHeaderCard(
              icon: Icons.tune_rounded,
              title: l10n.setting_screen_app_bar_label,
              subtitle: 'Görünüm ve dil ayarlarını düzenle',
            ),
          _buildSection(
            context,
            title: 'Appearance',
            children: [
              SwitchListTile(
                title: Text(l10n.theme_settings_label),
                subtitle: const Text('Enable dark mode'),
                value: themeViewModel.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeViewModel.changeThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
                secondary: Icon(
                  themeViewModel.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildThemeColorSection(context, themeViewModel),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Language',
            children: [
              ListTile(
                leading: Icon(
                  Icons.language,
                  color: theme.colorScheme.primary,
                ),
                title: Text(l10n.settings_language_label),
                subtitle: Text(
                  languageViewModel.currentLocale.languageCode == 'tr'
                      ? 'Türkçe'
                      : 'English',
                ),
                trailing: Switch(
                  value: languageViewModel.currentLocale.languageCode == 'en',
                  onChanged: (value) {
                    languageViewModel.changeLanguage(
                      value ? const Locale('en', '') : const Locale('tr', ''),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Support',
            children: [
              ListTile(
                leading: Icon(
                  Icons.shield_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Ebeveyn Kontrolleri'),
                subtitle: const Text('PIN ve topluluk erişimi'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/parental'),
              ),
              ListTile(
                leading: Icon(
                  Icons.feedback_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(l10n.settings_feedback_label),
                subtitle: const Text('Send us your feedback'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/feedback'),
              ),
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('About'),
                subtitle: const Text('Version 1.0.0'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'HistoryBox',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.auto_stories, size: 48),
                    children: [
                      const Text(
                        'AI-powered story creation app for children.',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Container(
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
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeColorSection(
      BuildContext context, ThemeViewModel themeViewModel) {
    final theme = Theme.of(context);
    final isPremium = context.watch<ProfileViewModel>().isPremium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Tema Rengi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              if (!isPremium)
                const Icon(Icons.workspace_premium_rounded,
                    size: 15, color: AppColors.gold),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 14,
            children: AppPalette.all.map((p) {
              final selected = themeViewModel.palette.id == p.id;
              final locked = p.isPremium && !isPremium;
              return GestureDetector(
                onTap: () {
                  if (locked) {
                    context.push('/premium');
                    return;
                  }
                  themeViewModel.setPalette(p);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: p.gradient,
                        ),
                        border: Border.all(
                          color: selected ? AppColors.gold : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: locked
                            ? const Icon(Icons.lock_rounded,
                                color: Colors.white, size: 20)
                            : (selected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 22)
                                : null),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${p.emoji} ${p.name}',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: theme.colorScheme.onSurface,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
