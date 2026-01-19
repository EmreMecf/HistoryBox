// lib/features/auth/presentation/screens/login_screen.dart
import 'dart:math' as math;
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
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _backgroundController;
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
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

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
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          _AnimatedLoginBackground(controller: _backgroundController),
          SafeArea(
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
        ],
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
      child: _GlassPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Google Sign In Button
            AnimatedButton(
              text: 'Google ile Giriş Yap',
              onPressed: () => _handleGoogleSignIn(authViewModel),
              isLoading: authViewModel.isLoading,
              backgroundColor: Colors.white,
              textColor: AppColors.textDarkOnLight,
              width: double.infinity,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            // Ayırıcı
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.white.withOpacity(0.5),
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
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.white.withOpacity(0.5),
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
                foregroundColor: Colors.white,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

class _GlassPanel extends StatelessWidget {
  final Widget child;

  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
        ),
        child: child,
      ),
    );
  }
}

class _AnimatedLoginBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedLoginBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final alignment = Alignment(
          math.sin(t * math.pi * 2) * 0.6,
          math.cos(t * math.pi * 2) * 0.6,
        );
        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: alignment,
                    end: -alignment,
                    colors: [
                      AppColors.primaryRed.withOpacity(0.35),
                      AppColors.accentOrange.withOpacity(0.35),
                      AppColors.accentBlue.withOpacity(0.35),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 40 + 20 * math.sin(t * math.pi * 2),
              top: 120 + 30 * math.cos(t * math.pi * 2),
              child: _GlowBubble(
                size: 160,
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            Positioned(
              right: 20 + 24 * math.cos(t * math.pi * 2),
              top: 40 + 20 * math.sin(t * math.pi * 2),
              child: _GlowBubble(
                size: 120,
                color: Colors.white.withOpacity(0.14),
              ),
            ),
            Positioned(
              left: 60 + 30 * math.cos(t * math.pi * 2),
              bottom: 80 + 22 * math.sin(t * math.pi * 2),
              child: _GlowBubble(
                size: 200,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlowBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}
