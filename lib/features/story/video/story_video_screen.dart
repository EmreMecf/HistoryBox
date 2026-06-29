// lib/features/story/video/story_video_screen.dart
//
// 🎬 Masal videosu oluşturma + önizleme + paylaşma ekranı.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../core/core.dart';
import '../../../services/injector.dart';
import '../../../shared/services/voice_profile_service.dart';
import '../../../viewmodel/profile_view_model.dart';
import '../../premium/presentation/screens/premium_screen.dart';
import 'story_video_service.dart';

class StoryVideoScreen extends StatefulWidget {
  final String title;
  final String content;
  final String category;

  const StoryVideoScreen({
    super.key,
    required this.title,
    required this.content,
    required this.category,
  });

  @override
  State<StoryVideoScreen> createState() => _StoryVideoScreenState();
}

class _StoryVideoScreenState extends State<StoryVideoScreen> {
  final StoryVideoService _service = injector<StoryVideoService>();

  String _stage = 'Başlatılıyor…';
  double _progress = 0;
  String? _error;
  String? _videoPath;
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() {
      _error = null;
      _progress = 0;
      _videoPath = null;
    });
    try {
      final isPremium = context.read<ProfileViewModel>().isPremium;
      final voiceId = await injector<VoiceProfileService>().activeVoiceId();
      final path = await _service.generateVideo(
        title: widget.title,
        content: widget.content,
        category: widget.category,
        addWatermark: !isPremium,
        useAiImages: isPremium, // premium: AI illüstrasyon sahneleri
        narratorVoiceId: voiceId,
        onProgress: (stage, progress) {
          if (!mounted) return;
          setState(() {
            _stage = stage;
            _progress = progress;
          });
        },
      );

      final controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      controller.setLooping(true);
      controller.play();

      if (!mounted) return;
      setState(() {
        _videoPath = path;
        _controller = controller;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _share() async {
    if (_videoPath == null) return;
    await Share.shareXFiles(
      [XFile(_videoPath!)],
      text: '${widget.title} 🌙 — HistoryBox ile oluşturuldu',
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedSoftBackground(
        colors: AppColors.premiumBackgroundGradient,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              BackButtonHeader(
                title: 'Masal Videosu',
                fallbackRoute: '/',
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: _error != null
                      ? _buildError()
                      : (_videoPath != null
                          ? _buildResult()
                          : _buildProgress()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: CircularProgressIndicator(
                    value: _progress == 0 ? null : _progress,
                    strokeWidth: 6,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.brandIndigo),
                    backgroundColor: AppColors.borderLight,
                  ),
                ),
                const Text('🎬', style: TextStyle(fontSize: 34)),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          Text(
            _stage,
            style: AppTextStyles.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            '%${(_progress * 100).round()}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.brandIndigo,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Masalın videoya dönüştürülüyor, bu birkaç dakika sürebilir 🌙',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMutedOnLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final controller = _controller!;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio == 0
                    ? 9 / 16
                    : controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(controller),
                    _PlayPauseOverlay(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingL),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Yeniden'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Paylaş / Kaydet'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        if (!context.watch<ProfileViewModel>().isPremium) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              ),
              icon: const Text('💎', style: TextStyle(fontSize: 14)),
              label: const Text('Premium ile filigransız indir'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😴', style: TextStyle(fontSize: 56)),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            'Video oluşturulamadı',
            style: AppTextStyles.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMutedOnLight,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          ElevatedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}

class _PlayPauseOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  const _PlayPauseOverlay({required this.controller});

  @override
  State<_PlayPauseOverlay> createState() => _PlayPauseOverlayState();
}

class _PlayPauseOverlayState extends State<_PlayPauseOverlay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.controller.value.isPlaying
              ? widget.controller.pause()
              : widget.controller.play();
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: widget.controller.value.isPlaying
            ? const SizedBox.shrink()
            : Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 72),
                ),
              ),
      ),
    );
  }
}
