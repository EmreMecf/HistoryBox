// lib/features/premium/presentation/screens/premium_screen.dart
//
// 💎 Premium tanıtım + plan seçimi (aylık/yıllık) + satın alma + geri yükleme.
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../services/apis/purchase_service.dart';
import '../../../../services/injector.dart';
import '../../../../viewmodel/profile_view_model.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PurchaseService _purchase = injector<PurchaseService>();
  bool _loading = false;
  List<ProductDetails> _products = [];
  String _selectedId = PurchaseService.premiumYearlyId;

  static const _benefits = [
    ('all_inclusive', 'Sınırsız masal',
        'Token harcamadan dilediğin kadar masal oluştur'),
    ('record_voice_over', 'Sesini klonla',
        'Masallar senin sesinle okunsun'),
    ('movie_filter', 'Filigransız + AI illüstrasyon',
        'Stüdyo kalitesinde, logosuz masal videoları'),
    ('block', 'Reklamsız deneyim', 'Hiç reklam görmeden, kesintisiz'),
  ];

  @override
  void initState() {
    super.initState();
    _purchase.onPremiumActivated = _onActivated;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _purchase.premiumProducts();
    if (mounted) setState(() => _products = products);
  }

  ProductDetails? _productById(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> _onActivated() async {
    if (!mounted) return;
    await context.read<ProfileViewModel>().refreshPremium();
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium etkinleştirildi 🎉')),
    );
  }

  Future<void> _buy() async {
    setState(() => _loading = true);
    final started = await _purchase.buyPremium(_selectedId);
    if (!started && mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Satın alma başlatılamadı. Mağaza ürünü tanımlı mı kontrol et.'),
        ),
      );
    }
  }

  Future<void> _restore() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Satın alımlar geri yükleniyor…')),
    );
    await _purchase.restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<ProfileViewModel>().isPremium;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          const Positioned.fill(child: _PremiumBackdrop()),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: [
                      const Center(
                          child: Text('💎', style: TextStyle(fontSize: 56))),
                      const SizedBox(height: 10),
                      Center(
                        child: Text('HistoryBox Premium',
                            style: AppTextStyles.displayMedium
                                .copyWith(color: Colors.white)),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Sınırsız masal, senin sesin, filigransız video 🌙',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._benefits.map(_benefitRow),
                      const SizedBox(height: 8),
                      if (isPremium)
                        _activeBadge()
                      else ...[
                        _planCard(
                          id: PurchaseService.premiumYearlyId,
                          title: 'Yıllık',
                          fallbackPrice: '₺699,99',
                          badge: 'En avantajlı • ~%50 indirim',
                        ),
                        const SizedBox(height: 12),
                        _planCard(
                          id: PurchaseService.premiumMonthlyId,
                          title: 'Aylık',
                          fallbackPrice: '₺99,99',
                        ),
                        const SizedBox(height: 18),
                        _buyButton(),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: _restore,
                            child: const Text('Satın Alımları Geri Yükle',
                                style: TextStyle(color: Colors.white70)),
                          ),
                        ),
                        Center(
                          child: Text(
                            'İlk 7 gün ücretsiz • istediğin zaman iptal et.\nAbonelik mağaza üzerinden yönetilir.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required String id,
    required String title,
    required String fallbackPrice,
    String? badge,
  }) {
    final selected = _selectedId == id;
    final product = _productById(id);
    final price = product?.price ?? fallbackPrice;
    final period = id == PurchaseService.premiumYearlyId ? '/yıl' : '/ay';

    return GestureDetector(
      onTap: () => setState(() => _selectedId = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: selected ? 0.16 : 0.06),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: selected
                ? AppColors.goldSoft
                : Colors.white.withValues(alpha: 0.15),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.goldSoft : Colors.white54,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: AppTextStyles.labelLarge
                              .copyWith(color: Colors.white)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(badge,
                              style: const TextStyle(
                                  color: AppColors.goldSoft,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('$price $period',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow((String, String, String) b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.premiumGradient),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_iconFor(b.$1), color: Colors.white, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.$2,
                    style: AppTextStyles.labelLarge
                        .copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Text(b.$3,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'all_inclusive':
        return Icons.all_inclusive_rounded;
      case 'record_voice_over':
        return Icons.record_voice_over_rounded;
      case 'movie_filter':
        return Icons.movie_filter_rounded;
      case 'block':
        return Icons.block_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Widget _buyButton() {
    return GestureDetector(
      onTap: _loading ? null : _buy,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.premiumWarmGradient),
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          boxShadow: AppShadows.glow(AppColors.gold),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  '7 Gün Ücretsiz Dene',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: const Color(0xFF5A3A00),
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _activeBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: AppColors.success),
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text('Premium aktif ✨',
                style: TextStyle(
                    color: AppColors.success, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _PremiumBackdrop extends StatelessWidget {
  const _PremiumBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.nightBackgroundGradient,
        ),
      ),
    );
  }
}
