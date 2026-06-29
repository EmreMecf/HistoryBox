import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:historybox/viewmodel/profile_view_model.dart';
import 'package:historybox/viewmodel/sign_out_view_model.dart';
import 'package:provider/provider.dart';
import '../core/translations/l10n/app_localizations.dart';
import '../core/thema/app_colors.dart';
import '../core/widgets/back_button_header.dart';
import '../core/widgets/premium_header_card.dart';
import '../core/widgets/premium_badge.dart';
import '../core/widgets/animated_soft_background.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final profileViewModel = context.watch<ProfileViewModel>();
    final signOutViewModel = context.watch<SignOutViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: AnimatedSoftBackground(
          colors: AppColors.premiumBackgroundGradient,
          backgroundColor: theme.colorScheme.surface,
          child: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                BackButtonHeader(
                  title: l10n.profile_screen_app_bar_label,
                  fallbackRoute: '/',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
            const SizedBox(height: 20),
            // Profile Header
            Hero(
              tag: 'profile_avatar',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: profileViewModel.userPhoto != null
                      ? CachedNetworkImageProvider(profileViewModel.userPhoto!)
                      : null,
                  child: profileViewModel.userPhoto == null
                      ? Icon(
                          Icons.person_outline,
                          size: 60,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    profileViewModel.userName ?? 'User',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (profileViewModel.isPremium) ...[
                  const SizedBox(width: 8),
                  const PremiumBadge(compact: false),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              profileViewModel.userEmail ?? '',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PremiumHeaderCard(
                icon: Icons.auto_awesome,
                title: 'Profilin Hazır',
                subtitle: 'Hikayelerini yönet ve ayarlarını kişiselleştir',
              ),
            ),
            const SizedBox(height: 24),
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    icon: Icons.auto_stories_rounded,
                    label: l10n.stories_created,
                    value: profileViewModel.storiesCount.toString(),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.borderLight,
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.favorite_rounded,
                    label: l10n.favorite_stories,
                    value: profileViewModel.favoriteCount.toString(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuCard(
                    context,
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.edit_outlined,
                        title: l10n.profile_edit_button,
                        onTap: () {
                          // TODO: Edit profile
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        context,
                        icon: Icons.bookmark_outline_rounded,
                        title: 'Kayıtlı Masallar',
                        onTap: () => context.push('/saved'),
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        context,
                        icon: Icons.record_voice_over_outlined,
                        title: 'Sesini Klonla',
                        onTap: () => context.push('/voice-clone'),
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        context,
                        icon: Icons.spa_outlined,
                        title: 'Ninni & Meditasyon',
                        onTap: () => context.push('/relax'),
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        context,
                        icon: Icons.settings_outlined,
                        title: l10n.profile_menu_settings,
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumCard(context, profileViewModel.isPremium),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.logout_outlined,
                        title: l10n.profile_menu_logout,
                        isDestructive: true,
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.profile_menu_logout),
                              content: const Text('Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text(l10n.cancel_button),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text(
                                    l10n.profile_menu_logout,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && context.mounted) {
                            await signOutViewModel.signOut();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, bool isPremium) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.push('/premium'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.premiumGradient),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandIndigo.withValues(alpha: 0.30),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -6,
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('💎', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? 'Premium Aktif ✨' : 'HistoryBox Premium',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isPremium
                          ? 'Filigransız ve sınırsız keyif'
                          : 'Filigranları kaldır, premium özellikler',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isPremium)
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: color.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }
}
