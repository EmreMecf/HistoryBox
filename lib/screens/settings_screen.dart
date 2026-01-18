import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/translations/l10n/app_localizations.dart';
import 'package:historybox/viewmodel/thema_view_model.dart';
import 'package:historybox/viewmodel/language_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final themeViewModel = context.watch<ThemeViewModel>();
    final languageViewModel = context.watch<LanguageViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.setting_screen_app_bar_label),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
