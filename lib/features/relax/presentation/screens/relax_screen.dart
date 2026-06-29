// lib/features/relax/presentation/screens/relax_screen.dart
//
// 🌙 Ninni & Meditasyon — sakin sesler kütüphanesi.
// Ninniler: lib/assets/audio/lullabies/ içindeki mp3'ler.
// Meditasyonlar: ElevenLabs ile anlık seslendirilen rehberli metinler.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/premium_header_card.dart';
import '../../../../services/apis/eleven_labs_tts_service.dart';
import '../../../../services/injector.dart';

class RelaxScreen extends StatefulWidget {
  const RelaxScreen({super.key});

  @override
  State<RelaxScreen> createState() => _RelaxScreenState();
}

class _RelaxScreenState extends State<RelaxScreen> {
  final AudioPlayer _player = AudioPlayer();
  final ElevenLabsTtsService _tts = injector<ElevenLabsTtsService>();

  String? _currentId;
  String? _loadingId;
  bool _playing = false;

  // Uyku zamanlayıcısı
  Timer? _sleepTimer;
  int? _sleepMinutes;

  // (id, başlık, asset)
  static const _lullabies = [
    ('lull1', 'Yıldız Ninnisi', 'lib/assets/audio/lullabies/lullaby_1.mp3'),
    ('lull2', 'Ay Işığı', 'lib/assets/audio/lullabies/lullaby_2.mp3'),
    ('lull3', 'Bulut Yolculuğu', 'lib/assets/audio/lullabies/lullaby_3.mp3'),
    ('lull4', 'Yumuşak Yağmur', 'lib/assets/audio/lullabies/lullaby_4.mp3'),
    ('lull5', 'Okyanus Dalgaları', 'lib/assets/audio/lullabies/lullaby_5.mp3'),
  ];

  // (id, başlık, rehberli metin)
  static const _meditations = [
    (
      'med1',
      'Uyku Nefesi',
      'Şimdi gözlerini usulca kapat. Derin bir nefes al… ve yavaşça ver. '
          'Vücudun yumuşacık bir bulutun üstünde. Her nefeste biraz daha '
          'rahatlıyorsun. Omuzların gevşiyor, gözkapakların ağırlaşıyor. '
          'Çok güvendesin, çok huzurlusun. İyi geceler.'
    ),
    (
      'med2',
      'Sakin Orman',
      'Yumuşak yosunların üzerinde yürüyorsun. Kuşlar usulca şarkı söylüyor, '
          'yapraklar fısıldıyor. Sıcacık bir güneş ışığı yüzüne değiyor. '
          'Her adımda daha sakin, daha mutlusun. Burada her şey yolunda.'
    ),
    (
      'med3',
      'Yıldızlara Yolculuk',
      'Yumuşak bir buluta uzandın ve gökyüzüne doğru süzülüyorsun. '
          'Etrafında ışıl ışıl yıldızlar. Ay sana gülümsüyor. '
          'Sıcacık ve güvendesin. Gözlerini kapat ve tatlı rüyalara dal.'
    ),
    (
      'med4',
      'Sevgi Dolu Kalp',
      'Elini usulca kalbinin üzerine koy. Orada sıcacık, parlak bir ışık var. '
          'Her nefeste bu ışık büyüyor; seni, seveni ve tüm dünyayı sarıyor. '
          'Sen değerlisin, sen sevilensin. Bu güzel duyguyla uykuya dal.'
    ),
    (
      'med5',
      'Minik Bulut',
      'Gökyüzünde minik, tüy kadar hafif bir bulutsun. Rüzgâr seni nazikçe '
          'taşıyor. Aşağıda uyuyan ağaçlar, sessiz evler. Hiç acelen yok. '
          'Süzül, salın ve yavaşça gözlerini kapat. İyi geceler küçük bulut.'
    ),
  ];

  // Doğa sesleri (id, başlık, asset) — döngüde çalar
  static const _nature = [
    ('nat1', 'Yağmur', 'lib/assets/audio/nature/nature_rain.mp3'),
    ('nat2', 'Orman', 'lib/assets/audio/nature/nature_forest.mp3'),
    ('nat3', 'Okyanus', 'lib/assets/audio/nature/nature_ocean.mp3'),
    ('nat4', 'Şömine', 'lib/assets/audio/nature/nature_fire.mp3'),
  ];

  Map<String, bool> _assetExists = {};

  @override
  void initState() {
    super.initState();
    _checkAssets();
    _player.playerStateStream.listen((s) {
      if (!mounted) return;
      if (s.processingState == ProcessingState.completed) {
        setState(() {
          _playing = false;
          _currentId = null;
        });
      } else {
        setState(() => _playing = s.playing);
      }
    });
  }

  Future<void> _checkAssets() async {
    final map = <String, bool>{};
    for (final l in [..._lullabies, ..._nature]) {
      try {
        await rootBundle.load(l.$3);
        map[l.$1] = true;
      } catch (_) {
        map[l.$1] = false;
      }
    }
    if (mounted) setState(() => _assetExists = map);
  }

  /// Asset (ninni/doğa sesi) — döngüde, arka planda çalar.
  Future<void> _toggleAsset(String id, String title, String asset) async {
    if (_currentId == id && _playing) {
      await _player.pause();
      return;
    }
    try {
      await _player.setAudioSource(
        AudioSource.asset(
          asset,
          tag: MediaItem(id: id, title: title, artist: 'HistoryBox'),
        ),
      );
      await _player.setLoopMode(LoopMode.one);
      setState(() => _currentId = id);
      await _player.play();
    } catch (_) {
      _snack('Bu ses dosyası henüz eklenmemiş');
    }
  }

  Future<void> _toggleMeditation(String id, String title, String text) async {
    if (_currentId == id && _playing) {
      await _player.pause();
      return;
    }
    if (!_tts.isConfigured) {
      _snack('Meditasyon için ElevenLabs API anahtarı gerekli (.env)');
      return;
    }
    setState(() => _loadingId = id);
    try {
      final path = await _tts.synthesizeToFile(text, calm: true);
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.file(path),
          tag: MediaItem(id: id, title: title, artist: 'HistoryBox · Meditasyon'),
        ),
      );
      await _player.setLoopMode(LoopMode.off);
      if (!mounted) return;
      setState(() {
        _currentId = id;
        _loadingId = null;
      });
      await _player.play();
    } catch (_) {
      if (mounted) setState(() => _loadingId = null);
      _snack('Meditasyon hazırlanamadı');
    }
  }

  void _snack(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  void _setSleepTimer(int? minutes) {
    _sleepTimer?.cancel();
    if (minutes == null) {
      setState(() => _sleepMinutes = null);
      return;
    }
    setState(() => _sleepMinutes = minutes);
    _sleepTimer = Timer(Duration(minutes: minutes), () async {
      await _player.stop();
      if (mounted) {
        setState(() {
          _playing = false;
          _currentId = null;
          _sleepMinutes = null;
        });
        _snack('Uyku zamanlayıcısı: ses durduruldu 🌙');
      }
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _player.dispose();
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
                  title: 'Ninni & Meditasyon', fallbackRoute: '/profile'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const PremiumHeaderCard(
                      icon: Icons.spa_rounded,
                      title: 'Sakin Uyku Sesleri',
                      subtitle: 'Ninniler ve rehberli meditasyonlarla huzurlu uyku',
                    ),
                    const SizedBox(height: 16),
                    _buildSleepTimer(theme),
                    const SizedBox(height: 20),
                    _sectionTitle(theme, '🎵 Ninniler'),
                    const SizedBox(height: 8),
                    ..._lullabies.map((l) => _tile(
                          theme,
                          id: l.$1,
                          title: l.$2,
                          subtitle: (_assetExists[l.$1] ?? true)
                              ? 'Sürekli çalar (döngü)'
                              : 'Yakında — dosya eklenmedi',
                          enabled: _assetExists[l.$1] ?? true,
                          onTap: () => _toggleAsset(l.$1, l.$2, l.$3),
                        )),
                    const SizedBox(height: 20),
                    _sectionTitle(theme, '🌿 Doğa Sesleri'),
                    const SizedBox(height: 8),
                    ..._nature.map((n) => _tile(
                          theme,
                          id: n.$1,
                          title: n.$2,
                          subtitle: (_assetExists[n.$1] ?? true)
                              ? 'Sürekli çalar (döngü)'
                              : 'Yakında — dosya eklenmedi',
                          enabled: _assetExists[n.$1] ?? true,
                          onTap: () => _toggleAsset(n.$1, n.$2, n.$3),
                        )),
                    const SizedBox(height: 20),
                    _sectionTitle(theme, '🧘 Meditasyonlar'),
                    const SizedBox(height: 8),
                    ..._meditations.map((m) => _tile(
                          theme,
                          id: m.$1,
                          title: m.$2,
                          subtitle: 'Rehberli, sakin sesle',
                          enabled: true,
                          onTap: () => _toggleMeditation(m.$1, m.$2, m.$3),
                        )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepTimer(ThemeData theme) {
    const options = <int?>[null, 15, 30, 60];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bedtime_outlined,
                  color: AppColors.brandIndigo, size: 18),
              const SizedBox(width: 8),
              Text('Uyku zamanlayıcısı',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: theme.colorScheme.onSurface)),
              const Spacer(),
              if (_sleepMinutes != null)
                Text('$_sleepMinutes dk sonra durur',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: options.map((m) {
              final selected = _sleepMinutes == m;
              final label = m == null ? 'Kapalı' : '$m dk';
              return GestureDetector(
                onTap: () => _setSleepTimer(m),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.brandIndigo
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                    border: Border.all(
                      color:
                          selected ? AppColors.brandIndigo : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color:
                          selected ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String text) {
    return Text(text,
        style: AppTextStyles.titleMedium
            .copyWith(color: theme.colorScheme.onSurface));
  }

  Widget _tile(
    ThemeData theme, {
    required String id,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final isCurrent = _currentId == id;
    final isLoading = _loadingId == id;
    final isPlaying = isCurrent && _playing;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isCurrent ? AppColors.brandIndigo : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: enabled ? onTap : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      const LinearGradient(colors: AppColors.primaryGradient),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.labelLarge
                          .copyWith(color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMutedOnLight)),
                ],
              ),
            ),
            if (isPlaying)
              const Icon(Icons.graphic_eq_rounded,
                  color: AppColors.brandIndigo),
          ],
        ),
      ),
    );
  }
}
