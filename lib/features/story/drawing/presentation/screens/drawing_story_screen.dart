// lib/features/story/drawing/presentation/screens/drawing_story_screen.dart
//
// 🎨 Çocuğun çiziminden masal oluşturma.
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../../../../../core/widgets/premium_header_card.dart';
import '../../../../../services/injector.dart';
import '../../../../../services/models/network/result.dart';
import '../../../../../shared/services/ai_story_service.dart';
import '../../../../../shared/services/child_profile_service.dart';
import '../../../../../shared/services/story_service.dart';
import '../../../../../viewmodel/token_view_model.dart';
import '../../../../../viewmodel/profile_view_model.dart';
import '../../../create/presentation/widgets/story_preview_card.dart';

class DrawingStoryScreen extends StatefulWidget {
  const DrawingStoryScreen({super.key});

  @override
  State<DrawingStoryScreen> createState() => _DrawingStoryScreenState();
}

class _DrawingStoryScreenState extends State<DrawingStoryScreen> {
  final ImagePicker _picker = ImagePicker();
  final AiStoryService _ai = injector<AiStoryService>();
  final StoryService _storyService = injector<StoryService>();

  File? _image;
  String? _base64;
  String _ageGroup = '6-8 Yaş';
  bool _loading = false;
  String? _title;
  String? _content;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    final x = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 70,
    );
    if (x == null) return;
    final bytes = await File(x.path).readAsBytes();
    setState(() {
      _image = File(x.path);
      _base64 = base64Encode(bytes);
      _title = null;
      _content = null;
      _error = null;
    });
  }

  Future<void> _generate() async {
    if (_base64 == null) return;
    final tokenVM = context.read<TokenViewModel>();
    final isPremium = context.read<ProfileViewModel>().isPremium;
    if (!isPremium && !tokenVM.hasTokens) {
      _snack('Token bitti. Masal oluşturamazsın.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final profile = await injector<ChildProfileService>().load();
    final result = await _ai.generateStoryFromImage(
      base64Image: _base64!,
      ageGroup: _ageGroup,
      childName: profile.childName,
      language: profile.language,
    );

    if (!mounted) return;
    if (result is Success<Map<String, String>, Exception>) {
      final data = result.value!;
      setState(() {
        _title = data['title'];
        _content = data['content'];
      });
      if (!isPremium) await tokenVM.useToken();
    } else if (result is Failure<Map<String, String>, Exception>) {
      setState(() => _error = result.exception.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _title == null || _content == null) return;
    final result = await _storyService.createStory(
      title: _title!,
      content: _content!,
      category: 'Masal',
      ageGroup: _ageGroup,
      userId: uid,
    );
    if (!mounted) return;
    if (result is Success<String, Exception>) {
      _snack('Masal kaydedildi! 🎉');
    } else {
      _snack('Kaydedilemedi');
    }
  }

  void _snack(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
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
              BackButtonHeader(title: 'Çizimden Masal', fallbackRoute: '/'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const PremiumHeaderCard(
                      icon: Icons.brush_rounded,
                      title: 'Çizimini Masala Dönüştür',
                      subtitle: 'Bir çizim seç, yapay zeka ondan masal yazsın',
                    ),
                    const SizedBox(height: 16),
                    _buildImageArea(theme),
                    const SizedBox(height: 16),
                    if (_title == null) _buildControls(theme),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(color: AppColors.error)),
                    ],
                    if (_title != null) ...[
                      const SizedBox(height: 8),
                      StoryPreviewCard(
                        title: _title!,
                        content: _content!,
                        category: 'Masal',
                        ageGroup: _ageGroup,
                        onSave: _save,
                        onRegenerate: _generate,
                        onEdit: () {},
                        isLoading: _loading,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageArea(ThemeData theme) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: _image != null
          ? Image.file(_image!, fit: BoxFit.cover)
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🖍️', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 8),
                  Text('Henüz çizim seçilmedi',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMutedOnLight)),
                ],
              ),
            ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Galeri'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_rounded),
                label: const Text('Kamera'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.child_care_rounded,
                color: AppColors.brandIndigo, size: 20),
            const SizedBox(width: 8),
            const Text('Yaş grubu:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                value: _ageGroup,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: AppConstants.ageGroups
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _ageGroup = v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_base64 == null || _loading) ? null : _generate,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(_loading ? 'Masal yazılıyor…' : 'Masalı Oluştur'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
