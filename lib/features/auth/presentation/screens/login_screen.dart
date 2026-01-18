// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/core.dart';
import '../../../../shared/widgets/animated_button.dart';
import '../viewmodels/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.surfaceLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Logo ve Başlık
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildLogoSection(),
                ),
              ),
              const Spacer(),
              // Giriş Butonları
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildLoginButtons(authViewModel),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arka plan deseni
              Positioned(
                top: 24,
                child: Opacity(
                  opacity: 0.08,
                  child: Text(
                    AppAssets.bookEmoji,
                    style: const TextStyle(fontSize: 44),
                  ),
                ),
              ),
              // Ana ikon
              Text(
                AppAssets.bookEmoji,
                style: const TextStyle(fontSize: 64),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXL),
        
        // App Name
        const Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.textDarkOnLight,
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingM),
        
        // Slogan
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppAssets.magicEmoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Text(
              AppConstants.appSlogan,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDarkOnLight.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Text(
              AppAssets.magicEmoji,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButtons(AuthViewModel authViewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Google Sign In Button
          AnimatedButton(
            text: 'Google ile Giriş Yap',
            onPressed: () => _handleGoogleSignIn(authViewModel),
            isLoading: authViewModel.isLoading,
            backgroundColor: AppColors.surfaceLight,
            textColor: AppColors.textDarkOnLight,
            width: double.infinity,
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          // Ayırıcı
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColors.borderLight,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                ),
                child: Text(
                  'veya',
                  style: TextStyle(
                    color: AppColors.textDarkOnLight.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.borderLight,
                  thickness: 1,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingM),
          
          // Misafir Girişi
          TextButton(
            onPressed: authViewModel.isLoading
                ? null
                : () => authViewModel.signInAsGuest(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textDarkOnLight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppAssets.rocketEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                const Text(
                  'Misafir Olarak Devam Et',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn(AuthViewModel viewModel) async {
    try {
      await viewModel.signInWithGoogle();
      
      if (viewModel.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
