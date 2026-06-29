// lib/features/parental/presentation/screens/parental_controls_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/premium_header_card.dart';
import '../../../../services/injector.dart';
import '../../../../shared/services/parental_controls_service.dart';

class ParentalControlsScreen extends StatefulWidget {
  const ParentalControlsScreen({super.key});

  @override
  State<ParentalControlsScreen> createState() => _ParentalControlsScreenState();
}

class _ParentalControlsScreenState extends State<ParentalControlsScreen> {
  final ParentalControlsService _service = injector<ParentalControlsService>();
  final TextEditingController _pinController = TextEditingController();

  bool _loading = true;
  bool _hasPin = false;
  bool _communityEnabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hasPin = await _service.hasPin();
    final community = await _service.isCommunityEnabled();
    if (!mounted) return;
    setState(() {
      _hasPin = hasPin;
      _communityEnabled = community;
      _loading = false;
    });
  }

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN en az 4 haneli olmalı')),
      );
      return;
    }
    await _service.setPin(pin);
    _pinController.clear();
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN kaydedildi ✓')),
      );
    }
  }

  Future<void> _removePin() async {
    await _service.clearPin();
    await _load();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedSoftBackground(
        colors: AppColors.premiumBackgroundGradient,
        backgroundColor: theme.colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              BackButtonHeader(
                title: 'Ebeveyn Kontrolleri',
                fallbackRoute: '/settings',
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const PremiumHeaderCard(
                            icon: Icons.shield_rounded,
                            title: 'Güvenli Deneyim',
                            subtitle:
                                'PIN belirle ve topluluk erişimini yönet',
                          ),
                          const SizedBox(height: 16),
                          _card(
                            context,
                            child: SwitchListTile(
                              title: const Text('Topluluğu göster'),
                              subtitle: const Text(
                                  'Kapalıyken topluluk akışı PIN ile korunur'),
                              value: _communityEnabled,
                              onChanged: (v) async {
                                setState(() => _communityEnabled = v);
                                await _service.setCommunityEnabled(v);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          _card(
                            context,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _hasPin
                                        ? 'Ebeveyn PIN’i tanımlı'
                                        : 'Ebeveyn PIN’i oluştur',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _pinController,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    maxLength: 6,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      hintText: _hasPin
                                          ? 'Yeni PIN (4-6 hane)'
                                          : 'PIN (4-6 hane)',
                                      counterText: '',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _savePin,
                                          child: Text(
                                              _hasPin ? 'PIN’i Değiştir' : 'Kaydet'),
                                        ),
                                      ),
                                      if (_hasPin) ...[
                                        const SizedBox(width: 12),
                                        OutlinedButton(
                                          onPressed: _removePin,
                                          child: const Text('Kaldır'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
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

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }
}
