// lib/features/print/presentation/screens/print_book_screen.dart
//
// 📖 Masaldan fiziksel kitap baskısı sipariş ekranı.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/premium_header_card.dart';
import '../../../../services/injector.dart';
import '../../../../shared/services/print_order_service.dart';

class PrintBookScreen extends StatefulWidget {
  final String? storyId;
  final String title;
  final String content;
  final String category;

  const PrintBookScreen({
    super.key,
    this.storyId,
    required this.title,
    required this.content,
    required this.category,
  });

  @override
  State<PrintBookScreen> createState() => _PrintBookScreenState();
}

class _PrintBookScreenState extends State<PrintBookScreen> {
  final PrintOrderService _service = injector<PrintOrderService>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  int _quantity = 1;
  bool _submitting = false;
  bool _done = false;

  static const int _unitPrice = 149; // ₺ (placeholder)

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_nameController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldur')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await _service.createOrder(
        userId: uid,
        storyId: widget.storyId,
        title: widget.title,
        fullName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        quantity: _quantity,
      );
      if (mounted) setState(() => _done = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş oluşturulamadı: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor =
        AppColors.categoryColors[widget.category] ?? AppColors.brandIndigo;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedSoftBackground(
        colors: AppColors.premiumBackgroundGradient,
        backgroundColor: theme.colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              BackButtonHeader(title: 'Kitap Bastır', fallbackRoute: '/'),
              Expanded(
                child: _done
                    ? _buildDone(theme)
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const PremiumHeaderCard(
                            icon: Icons.menu_book_rounded,
                            title: 'Masalını Kitap Yap',
                            subtitle:
                                'Bu masalı basılı, ciltli bir kitap olarak kapına getirelim',
                          ),
                          const SizedBox(height: 16),
                          _buildBookPreview(categoryColor),
                          const SizedBox(height: 20),
                          _field(_nameController, 'Ad Soyad'),
                          const SizedBox(height: 12),
                          _field(_addressController, 'Adres', maxLines: 3),
                          const SizedBox(height: 12),
                          _field(_phoneController, 'Telefon',
                              keyboard: TextInputType.phone),
                          const SizedBox(height: 16),
                          _buildQuantity(theme),
                          const SizedBox(height: 16),
                          _buildSummary(theme),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _submitting ? null : _submit,
                              icon: _submitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.local_shipping_rounded),
                              label: Text(
                                  _submitting ? 'Gönderiliyor…' : 'Sipariş Ver'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Sipariş alındıktan sonra ödeme ve kargo için sizinle iletişime geçilir.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textMutedOnLight),
                            ),
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

  Widget _buildBookPreview(Color categoryColor) {
    return Center(
      child: Container(
        width: 160,
        height: 210,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [categoryColor, AppColors.brandIndigo],
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
            topLeft: Radius.circular(4),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: AppShadows.glow(AppColors.brandIndigo),
          border: Border(
            left: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 5),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📖', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantity(ThemeData theme) {
    return Row(
      children: [
        const Text('Adet:', style: TextStyle(fontWeight: FontWeight.w600)),
        const Spacer(),
        IconButton(
          onPressed: _quantity > 1
              ? () => setState(() => _quantity--)
              : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$_quantity', style: AppTextStyles.titleMedium),
        IconButton(
          onPressed: () => setState(() => _quantity++),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildSummary(ThemeData theme) {
    final total = _unitPrice * _quantity;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$_quantity kitap × ₺$_unitPrice',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: theme.colorScheme.onSurface)),
          Text('₺$total + kargo',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.brandIndigo)),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {int maxLines = 1, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildDone(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Siparişin alındı!',
                style: AppTextStyles.titleLarge
                    .copyWith(color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(
              'Ödeme ve kargo detayları için en kısa sürede seninle iletişime geçeceğiz.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textMutedOnLight),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Tamam'),
            ),
          ],
        ),
      ),
    );
  }
}
