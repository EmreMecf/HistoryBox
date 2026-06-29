// lib/shared/widgets/story_narration_bar.dart
//
// 🌙 Sesli masal anlatımı.
// Birincil: ElevenLabs stüdyo kalitesi (Türkçe'yi doğru telaffuz eden
// eleven_multilingual_v2). API anahtarı yoksa/hata olursa cihaz sesine
// (flutter_tts) düşer. Uyku modu: sakin, yavaş, yumuşak ton.
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../core/core.dart';
import '../../services/injector.dart';
import '../../services/apis/eleven_labs_tts_service.dart';
import '../services/voice_profile_service.dart';

enum _NState { idle, loading, playing, paused }

class StoryNarrationBar extends StatefulWidget {
  /// Seslendirilecek hikaye metni.
  final String text;

  /// İsteğe bağlı başlık (metnin başına okunur).
  final String? title;

  const StoryNarrationBar({
    super.key,
    required this.text,
    this.title,
  });

  @override
  State<StoryNarrationBar> createState() => _StoryNarrationBarState();
}

class _StoryNarrationBarState extends State<StoryNarrationBar> {
  final ElevenLabsTtsService _eleven = injector<ElevenLabsTtsService>();
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts(); // yedek (fallback)

  StreamSubscription<PlayerState>? _playerSub;
  _NState _state = _NState.idle;
  bool _calm = true; // uyku modu (varsayılan açık)
  bool _usingEleven = false;
  bool _ttsReady = false;

  bool get _studio => _eleven.isConfigured;

  @override
  void initState() {
    super.initState();

    _playerSub = _player.playerStateStream.listen((s) {
      if (!mounted) return;
      if (s.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
        setState(() => _state = _NState.idle);
      }
    });

    _initTtsFallback();
  }

  Future<void> _initTtsFallback() async {
    try {
      await _tts.awaitSpeakCompletion(true);
      if (!kIsWeb && Platform.isIOS) {
        try {
          await _tts.setSharedInstance(true);
          await _tts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            ],
            IosTextToSpeechAudioMode.voicePrompt,
          );
        } catch (_) {}
      }
      await _tts.setLanguage('tr-TR');
      _tts.setCompletionHandler(() {
        if (mounted && !_usingEleven) setState(() => _state = _NState.idle);
      });
      _tts.setCancelHandler(() {
        if (mounted && !_usingEleven) setState(() => _state = _NState.idle);
      });
      _ttsReady = true;
    } catch (e) {
      AppLogger.error('TTS fallback init failed', tag: 'Narration', error: e);
    }
  }

  String get _content {
    final t = widget.title?.trim();
    return (t != null && t.isNotEmpty) ? '$t.\n\n${widget.text}' : widget.text;
  }

  Future<void> _onPrimary() async {
    switch (_state) {
      case _NState.playing:
        await _pause();
        break;
      case _NState.paused:
        await _resume();
        break;
      case _NState.idle:
        await _start();
        break;
      case _NState.loading:
        break;
    }
  }

  Future<void> _start() async {
    final text = _content.trim();
    if (text.isEmpty) return;

    if (_studio) {
      _usingEleven = true;
      setState(() => _state = _NState.loading);
      try {
        final voiceId =
            await injector<VoiceProfileService>().activeVoiceId();
        final path = await _eleven.synthesizeToFile(
          text,
          calm: _calm,
          voiceIdOverride: voiceId,
        );
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.file(path),
            tag: MediaItem(
              id: 'narration',
              title: widget.title ?? 'Masal',
              artist: 'HistoryBox',
            ),
          ),
        );
        await _player.setSpeed(_calm ? 0.9 : 1.0);
        if (!mounted) return;
        setState(() => _state = _NState.playing);
        await _player.play();
        return;
      } catch (e) {
        AppLogger.error('ElevenLabs başarısız, cihaz sesine geçiliyor',
            tag: 'Narration', error: e);
        // Cihaz sesine düş
      }
    }

    _usingEleven = false;
    await _startDeviceTts(text);
  }

  Future<void> _startDeviceTts(String text) async {
    if (!_ttsReady) {
      await _initTtsFallback();
    }
    await _tts.setSpeechRate(_calm ? 0.40 : 0.52);
    await _tts.setPitch(_calm ? 0.90 : 1.0);
    await _tts.setVolume(1.0);
    if (!mounted) return;
    setState(() => _state = _NState.playing);
    await _tts.speak(text);
  }

  Future<void> _pause() async {
    if (_usingEleven) {
      await _player.pause();
      if (mounted) setState(() => _state = _NState.paused);
    } else {
      await _tts.stop();
      if (mounted) setState(() => _state = _NState.idle);
    }
  }

  Future<void> _resume() async {
    if (_usingEleven) {
      if (mounted) setState(() => _state = _NState.playing);
      await _player.play();
    } else {
      await _start();
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    await _tts.stop();
    if (mounted) setState(() => _state = _NState.idle);
  }

  Future<void> _toggleCalm() async {
    setState(() => _calm = !_calm);
    // Anlık his için ElevenLabs çalarken hızı canlı ayarla
    if (_usingEleven && _state == _NState.playing) {
      await _player.setSpeed(_calm ? 0.9 : 1.0);
    } else if (!_usingEleven && _state == _NState.playing) {
      // Cihaz sesi yeni tonla baştan başlasın
      await _tts.stop();
      await _startDeviceTts(_content.trim());
    }
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _player.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _state == _NState.playing;
    final isLoading = _state == _NState.loading;
    final isActive = isPlaying || _state == _NState.paused;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.premiumGradient,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: AppShadows.glow(AppColors.brandIndigo),
      ),
      child: Row(
        children: [
          // Oynat / Duraklat (yükleniyorsa spinner)
          GestureDetector(
            onTap: isLoading ? null : _onPrimary,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.brandIndigo),
                      ),
                    )
                  : Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.brandIndigo,
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          // Metin + dalga animasyonu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('🌙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isLoading
                            ? 'Ses hazırlanıyor…'
                            : (isPlaying
                                ? 'Masal anlatılıyor…'
                                : 'Masalı dinle'),
                        style: AppTextStyles.labelLarge
                            .copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (isPlaying)
                  _SoundWaves(color: Colors.white.withValues(alpha: 0.9))
                else
                  Text(
                    '${_studio ? 'Stüdyo sesi' : 'Cihaz sesi'} • '
                    '${_calm ? 'uyku modu' : 'normal ton'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          // Durdur (çalarken/duraklatınca)
          if (isActive)
            GestureDetector(
              onTap: _stop,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.stop_circle_outlined,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 28,
                ),
              ),
            ),
          // Uyku (sakin) modu anahtarı
          GestureDetector(
            onTap: _toggleCalm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: _calm ? 0.28 : 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _calm ? Icons.bedtime_rounded : Icons.bedtime_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Uyku',
                    style:
                        AppTextStyles.labelSmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Anlatım sırasında yumuşak ses dalgası animasyonu.
class _SoundWaves extends StatefulWidget {
  final Color color;
  const _SoundWaves({required this.color});

  @override
  State<_SoundWaves> createState() => _SoundWavesState();
}

class _SoundWavesState extends State<_SoundWaves>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            children: List.generate(7, (i) {
              final phase = (_c.value + i / 7) % 1.0;
              final h = 4 + 10 * (0.5 + 0.5 * math.sin(phase * 2 * math.pi));
              return Container(
                width: 3,
                height: h,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
