// lib/features/voice/presentation/screens/voice_clone_screen.dart
//
// 🗣️ Ebeveyn sesini kaydet → ElevenLabs ile klonla → masallarda kullan.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/premium_header_card.dart';
import '../../../../services/apis/eleven_labs_voice_service.dart';
import '../../../../services/injector.dart';
import '../../../../shared/services/voice_profile_service.dart';
import '../../../../viewmodel/profile_view_model.dart';

class VoiceCloneScreen extends StatefulWidget {
  const VoiceCloneScreen({super.key});

  @override
  State<VoiceCloneScreen> createState() => _VoiceCloneScreenState();
}

class _VoiceCloneScreenState extends State<VoiceCloneScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final ElevenLabsVoiceService _voiceService =
      injector<ElevenLabsVoiceService>();
  final VoiceProfileService _profile = injector<VoiceProfileService>();
  final TextEditingController _nameController =
      TextEditingController(text: 'Annem/Babam');

  bool _loading = true;
  bool _isRecording = false;
  bool _uploading = false;
  int _seconds = 0;
  Timer? _timer;
  String? _recordedPath;

  String? _savedVoiceName;
  bool _useCloned = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await _profile.clonedVoiceName();
    final use = await _profile.useCloned();
    if (!mounted) return;
    setState(() {
      _savedVoiceName = name;
      _useCloned = use;
      _loading = false;
    });
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      _snack('Mikrofon izni gerekli');
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice_sample.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    setState(() {
      _isRecording = true;
      _seconds = 0;
      _recordedPath = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _recordedPath = path;
    });
  }

  Future<void> _upload() async {
    if (_recordedPath == null) return;
    if (!_voiceService.isConfigured) {
      _snack('ElevenLabs API anahtarı gerekli (.env)');
      return;
    }
    setState(() => _uploading = true);
    final voiceId = await _voiceService.cloneVoice(
      name: _nameController.text.trim().isEmpty
          ? 'Ebeveyn'
          : _nameController.text.trim(),
      filePath: _recordedPath!,
    );
    if (voiceId != null) {
      await _profile.saveClonedVoice(voiceId, _nameController.text.trim());
      await _load();
      _snack('Ses klonlandı 🎉 Artık masallar bu sesle okunabilir');
    } else {
      _snack('Ses klonlanamadı (ElevenLabs ücretli plan gerektirir)');
    }
    if (mounted) setState(() => _uploading = false);
  }

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPremium = context.watch<ProfileViewModel>().isPremium;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedSoftBackground(
        colors: AppColors.premiumBackgroundGradient,
        backgroundColor: theme.colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              BackButtonHeader(title: 'Sesini Klonla', fallbackRoute: '/profile'),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (!isPremium
                        ? _buildUpsell(theme)
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              const PremiumHeaderCard(
                                icon: Icons.record_voice_over_rounded,
                                title: 'Masalları Senin Sesinle',
                                subtitle:
                                    '30-60 sn konuş, masallar senin sesinle okunsun',
                              ),
                              const SizedBox(height: 20),
                              if (_savedVoiceName != null) _buildSavedVoice(),
                              const SizedBox(height: 16),
                              _buildRecorder(theme),
                            ],
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpsell(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🗣️💎', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('Ses klonlama bir Premium özelliğidir',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium
                    .copyWith(color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(
              'Premium ile kendi sesini klonla; masallar senin sesinle okunsun.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textMutedOnLight),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/premium'),
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Premium’a Geç'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedVoice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Kayıtlı ses: ${_savedVoiceName!.isEmpty ? "Ebeveyn" : _savedVoiceName}',
                style: AppTextStyles.labelLarge),
          ),
          Switch(
            value: _useCloned,
            onChanged: (v) async {
              setState(() => _useCloned = v);
              await _profile.setUseCloned(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecorder(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Ses adı'),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isRecording
                      ? [AppColors.error, AppColors.accentPink]
                      : AppColors.primaryGradient,
                ),
                boxShadow: AppShadows.glow(
                    _isRecording ? AppColors.error : AppColors.brandIndigo),
              ),
              child: Icon(
                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _isRecording
                ? 'Kaydediliyor… ${_seconds}s'
                : (_recordedPath != null
                    ? 'Kayıt hazır ✓'
                    : 'Başlamak için dokun'),
            style: AppTextStyles.bodyMedium
                .copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'İpucu: Sakin bir ortamda, normal tonda bir masal paragrafı oku.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textMutedOnLight),
          ),
          if (_recordedPath != null && !_isRecording) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _uploading ? null : _upload,
                icon: _uploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(_uploading ? 'Klonlanıyor…' : 'Sesi Klonla'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
