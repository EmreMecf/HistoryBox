import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/sign_out_view_model.dart';
import '../core/thema/app_colors.dart';
import '../core/thema/app_dimensions.dart';
import '../viewmodel/thema_view_model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final signOutViewModel = context.watch<SignOutViewModel>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryRed,
            AppColors.accentTeal,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusXL),
          bottomRight: Radius.circular(AppDimensions.radiusXL),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        centerTitle: true,
        leading: showBackButton
            ? IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textLight,
          ),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        actions: [
          if (actions != null) ...actions!,
          // Çıkış Butonu
          IconButton(
            icon: signOutViewModel.isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLight),
              ),
            )
                : const Icon(
              Icons.logout_rounded,
              color: AppColors.textLight,
            ),
            onPressed: signOutViewModel.isLoading
                ? null
                : () => _handleSignOut(context, signOutViewModel),
          ),
          // Tema Değiştirme Butonu
          IconButton(
            icon: Icon(
              themeViewModel.isDarkMode
                  ? Icons.wb_sunny_rounded
                  : Icons.nightlight_round,
              color: AppColors.textLight,
            ),
            onPressed: () => themeViewModel.toggleTheme(),
          ),
          const SizedBox(width: AppDimensions.paddingS),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context, SignOutViewModel viewModel) async {
    try {
      await viewModel.signOut();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çıkış yapılırken bir hata oluştu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}