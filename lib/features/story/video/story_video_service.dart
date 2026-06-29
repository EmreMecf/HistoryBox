// lib/features/story/video/story_video_service.dart
//
// 🎬 Otomatik masal videosu (cihazda).
// Pipeline: metni sahnelere böl -> her sahneyi temalı kart olarak çiz (Canvas)
// -> ElevenLabs seslendirme -> ffmpeg ile görseller + ses = MP4.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/thema/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../services/apis/eleven_labs_tts_service.dart';
import '../../../services/apis/image_gen_service.dart';

typedef VideoProgress = void Function(String stage, double progress);

class StoryVideoService {
  final ElevenLabsTtsService _tts;
  final ImageGenService _imageGen;
  StoryVideoService(this._tts, this._imageGen);

  // Dikey (Shorts/Reels) format
  static const int _w = 720;
  static const int _h = 1280;

  // Sahneler arası yumuşak geçiş süresi
  static const int _transitionMs = 600;
  double get _transitionSec => _transitionMs / 1000.0;

  // Arka plan müziği (varsa) — seslendirmenin altında düşük seviye
  static const String _musicAsset = 'lib/assets/audio/lullaby.mp3';

  /// Masaldan otomatik video üretir, MP4 dosya yolunu döndürür.
  Future<String> generateVideo({
    required String title,
    required String content,
    required String category,
    bool addWatermark = true,
    bool useAiImages = false,
    String? narratorVoiceId,
    VideoProgress? onProgress,
  }) async {
    onProgress?.call('Sahneler hazırlanıyor', 0.05);
    final scenes = _splitScenes(content);

    if (!_tts.isConfigured) {
      throw Exception(
          'Video oluşturmak için ElevenLabs API anahtarı gerekli (.env).');
    }

    onProgress?.call('Seslendirme oluşturuluyor', 0.15);
    final audioPath = await _tts.synthesizeToFile(
      content,
      calm: true,
      voiceIdOverride: narratorVoiceId,
    );

    final audioDuration = await _audioDuration(audioPath);
    final totalMs = audioDuration.inMilliseconds > 0
        ? audioDuration.inMilliseconds
        : scenes.length * 4000;
    // Geçişler videoyu kısaltır; ses süresini korumak için hedefi artır
    final transTotalMs =
        scenes.length > 1 ? (scenes.length - 1) * _transitionMs : 0;
    final durationsMs = _allocateDurations(scenes, totalMs + transTotalMs);

    final tmp = await getTemporaryDirectory();
    final categoryColor =
        AppColors.categoryColors[category] ?? AppColors.brandIndigo;

    final framePaths = <String>[];
    for (var i = 0; i < scenes.length; i++) {
      final useAi = useAiImages && _imageGen.isConfigured;
      onProgress?.call(
        useAi
            ? 'AI illüstrasyon çiziliyor (${i + 1}/${scenes.length})'
            : 'Sahne çiziliyor (${i + 1}/${scenes.length})',
        0.2 + 0.5 * (i / scenes.length),
      );

      String? bgImagePath;
      if (useAi) {
        bgImagePath = await _imageGen.generateSceneImage(scenes[i], index: i);
      }

      final bytes = await _renderScene(
        title: title,
        sceneText: scenes[i],
        index: i,
        total: scenes.length,
        color: categoryColor,
        watermark: addWatermark,
        backgroundImagePath: bgImagePath,
      );
      final file = File('${tmp.path}/frame_$i.png');
      await file.writeAsBytes(bytes, flush: true);
      framePaths.add(file.path);
    }

    onProgress?.call('Müzik hazırlanıyor', 0.74);
    final musicPath = await _prepareMusic();

    onProgress?.call('Video birleştiriliyor (geçişler + müzik)', 0.80);

    final docs = await getApplicationDocumentsDirectory();
    final outPath =
        '${docs.path}/masal_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final cmd = _buildFfmpegCommand(
      framePaths: framePaths,
      durationsMs: durationsMs,
      audioPath: audioPath,
      musicPath: musicPath,
      outPath: outPath,
    );

    final session = await FFmpegKit.execute(cmd);
    final rc = await session.getReturnCode();
    if (!ReturnCode.isSuccess(rc)) {
      final logs = await session.getAllLogsAsString();
      AppLogger.error('ffmpeg başarısız: $logs', tag: 'StoryVideo');
      throw Exception('Video oluşturulamadı (ffmpeg).');
    }

    onProgress?.call('Hazır', 1.0);
    AppLogger.success('Video hazır: $outPath', tag: 'StoryVideo');
    return outPath;
  }

  // ===================== Yardımcılar =====================

  /// Görselleri xfade geçişlerle zincirleyen ve seslendirme + (varsa) müziği
  /// miksleyen ffmpeg komutunu oluşturur.
  String _buildFfmpegCommand({
    required List<String> framePaths,
    required List<int> durationsMs,
    required String audioPath,
    required String? musicPath,
    required String outPath,
  }) {
    final n = framePaths.length;
    final t = _transitionSec;

    // Girdiler: her sahne görseli (loop), seslendirme, (varsa) müzik
    final inputs = StringBuffer();
    for (var i = 0; i < n; i++) {
      final d = (durationsMs[i] / 1000).toStringAsFixed(3);
      inputs.write("-loop 1 -t $d -i '${framePaths[i]}' ");
    }
    inputs.write("-i '$audioPath' "); // index n = seslendirme
    final hasMusic = musicPath != null;
    if (hasMusic) {
      inputs.write("-stream_loop -1 -i '$musicPath' "); // index n+1 = müzik
    }

    final fc = StringBuffer();
    // Her görseli normalize et
    for (var i = 0; i < n; i++) {
      fc.write('[$i:v]scale=$_w:$_h,setsar=1,fps=25,format=yuv420p[v$i];');
    }

    // Video: xfade geçiş zinciri
    if (n == 1) {
      fc.write('[v0]format=yuv420p[vout];');
    } else {
      var acc = durationsMs[0] / 1000.0; // birikmiş çıktı süresi
      var prev = 'v0';
      for (var k = 1; k < n; k++) {
        final dk = durationsMs[k] / 1000.0;
        final offset = acc - t;
        final out = (k == n - 1) ? 'vout' : 'x$k';
        fc.write('[$prev][v$k]xfade=transition=fade:'
            'duration=${t.toStringAsFixed(2)}:'
            'offset=${offset.toStringAsFixed(3)}[$out];');
        acc = acc + dk - t;
        prev = out;
      }
    }

    // Ses: seslendirme + (varsa) düşük seviyeli müzik
    final narIdx = n;
    if (hasMusic) {
      final musIdx = n + 1;
      fc.write('[$musIdx:a]volume=0.16[bg];');
      fc.write('[$narIdx:a][bg]amix=inputs=2:duration=first:'
          'dropout_transition=2[aout];');
    } else {
      fc.write('[$narIdx:a]anull[aout];');
    }

    var filter = fc.toString();
    if (filter.endsWith(';')) {
      filter = filter.substring(0, filter.length - 1);
    }

    return "-y $inputs-filter_complex \"$filter\" "
        "-map \"[vout]\" -map \"[aout]\" "
        "-c:v mpeg4 -q:v 5 -r 25 -c:a aac -b:a 160k -shortest '$outPath'";
  }

  /// Arka plan müziği asset'i varsa geçici dosyaya kopyalar, yoksa null.
  Future<String?> _prepareMusic() async {
    try {
      final data = await rootBundle.load(_musicAsset);
      final tmp = await getTemporaryDirectory();
      final file = File('${tmp.path}/bg_music.mp3');
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      return file.path;
    } catch (_) {
      return null; // müzik dosyası yoksa müziksiz devam
    }
  }

  List<String> _splitScenes(String content) {
    final clean =
        content.replaceAll('\r', ' ').replaceAll(RegExp(r'[ \t]+'), ' ').trim();
    if (clean.isEmpty) return ['...'];

    final sentences = clean
        .split(RegExp(r'(?<=[.!?…])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (sentences.isEmpty) return [clean];

    const target = 6;
    final perScene = (sentences.length / target).ceil().clamp(1, sentences.length);
    final scenes = <String>[];
    for (var i = 0; i < sentences.length; i += perScene) {
      final end = math.min(i + perScene, sentences.length);
      scenes.add(sentences.sublist(i, end).join(' '));
    }
    return scenes;
  }

  List<int> _allocateDurations(List<String> scenes, int totalMs) {
    final lens = scenes.map((s) => s.length).toList();
    final sum = lens.fold<int>(0, (a, b) => a + b);
    if (sum == 0) {
      return List.filled(scenes.length, (totalMs / scenes.length).round());
    }
    return lens.map((l) {
      final d = (l / sum * totalMs).round();
      return d < 1500 ? 1500 : d;
    }).toList();
  }

  Future<Duration> _audioDuration(String path) async {
    final player = AudioPlayer();
    try {
      final d = await player.setAudioSource(
        AudioSource.uri(
          Uri.file(path),
          tag: MediaItem(id: 'duration_probe', title: 'Masal'),
        ),
      );
      return d ?? Duration.zero;
    } catch (_) {
      return Duration.zero;
    } finally {
      await player.dispose();
    }
  }

  Future<Uint8List> _renderScene({
    required String title,
    required String sceneText,
    required int index,
    required int total,
    required Color color,
    required bool watermark,
    String? backgroundImagePath,
  }) async {
    final w = _w.toDouble();
    final h = _h.toDouble();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

    if (backgroundImagePath != null) {
      // AI illüstrasyon arka planı + okunabilirlik için karartma
      await _drawCoverImage(canvas, backgroundImagePath, w, h);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, h * 0.35),
            Offset(0, h),
            [Colors.transparent, const Color(0xCC0B0824)],
          ),
      );
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()..color = Colors.black.withValues(alpha: 0.22),
      );
    } else {
      // Temalı (ücretsiz) arka plan: gece + kategori renkli gradyan
      final bgTop = Color.lerp(color, const Color(0xFF1A1145), 0.45)!;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(0, 0),
            Offset(w, h),
            [bgTop, const Color(0xFF0B0824)],
          ),
      );
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(w * 0.5, h * 0.30),
            w * 0.75,
            [color.withValues(alpha: 0.45), Colors.transparent],
          ),
      );
      final rnd = math.Random(index * 97 + 13);
      final starPaint = Paint();
      for (var i = 0; i < 80; i++) {
        starPaint.color =
            (rnd.nextDouble() > 0.85 ? const Color(0xFFFFD68A) : Colors.white)
                .withValues(alpha: rnd.nextDouble() * 0.7 + 0.15);
        canvas.drawCircle(
          Offset(rnd.nextDouble() * w, rnd.nextDouble() * h * 0.62),
          rnd.nextDouble() * 1.7 + 0.4,
          starPaint,
        );
      }
    }

    // Başlık (üst)
    _paintText(
      canvas,
      title.toUpperCase(),
      top: 90,
      maxWidth: w - 140,
      color: const Color(0xFFFFD68A),
      fontSize: 30,
      weight: FontWeight.w700,
      maxLines: 2,
      letterSpacing: 1.5,
    );

    // Sahne metni (ortada) — uzunluğa göre font ölçeği
    final fontSize = sceneText.length > 220
        ? 34.0
        : sceneText.length > 120
            ? 40.0
            : 46.0;
    final tp = _layout(
      sceneText,
      maxWidth: w - 130,
      color: Colors.white,
      fontSize: fontSize,
      weight: FontWeight.w600,
      maxLines: 12,
    );
    tp.paint(canvas, Offset((w - tp.width) / 2, (h - tp.height) / 2));

    // Alt: sahne göstergesi (noktalar) + filigran
    final dotY = h - 110;
    const dotGap = 22.0;
    final dotsWidth = (total - 1) * dotGap;
    for (var i = 0; i < total; i++) {
      final active = i == index;
      canvas.drawCircle(
        Offset(w / 2 - dotsWidth / 2 + i * dotGap, dotY),
        active ? 6 : 4,
        Paint()
          ..color = active ? color : Colors.white.withValues(alpha: 0.35),
      );
    }
    // Filigran — yalnızca ücretsiz kullanıcılarda
    if (watermark) {
      _paintText(
        canvas,
        'HistoryBox',
        top: h - 70,
        maxWidth: w,
        color: Colors.white.withValues(alpha: 0.55),
        fontSize: 24,
        weight: FontWeight.w600,
        maxLines: 1,
        letterSpacing: 2,
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(_w, _h);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData!.buffer.asUint8List();
  }

  Future<void> _drawCoverImage(
      Canvas canvas, String path, double w, double h) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final iw = image.width.toDouble();
      final ih = image.height.toDouble();
      final scale = math.max(w / iw, h / ih);
      final sw = w / scale;
      final sh = h / scale;
      final sx = (iw - sw) / 2;
      final sy = (ih - sh) / 2;
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(sx, sy, sw, sh),
        Rect.fromLTWH(0, 0, w, h),
        Paint()..filterQuality = FilterQuality.high,
      );
      image.dispose();
    } catch (_) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()..color = const Color(0xFF0B0824),
      );
    }
  }

  TextPainter _layout(
    String text, {
    required double maxWidth,
    required Color color,
    required double fontSize,
    required FontWeight weight,
    required int maxLines,
    double letterSpacing = 0,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          height: 1.4,
          letterSpacing: letterSpacing,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '…',
    );
    tp.layout(maxWidth: maxWidth);
    return tp;
  }

  void _paintText(
    Canvas canvas,
    String text, {
    required double top,
    required double maxWidth,
    required Color color,
    required double fontSize,
    required FontWeight weight,
    required int maxLines,
    double letterSpacing = 0,
  }) {
    final tp = _layout(
      text,
      maxWidth: maxWidth,
      color: color,
      fontSize: fontSize,
      weight: weight,
      maxLines: maxLines,
      letterSpacing: letterSpacing,
    );
    tp.paint(canvas, Offset((_w - tp.width) / 2, top));
  }
}
