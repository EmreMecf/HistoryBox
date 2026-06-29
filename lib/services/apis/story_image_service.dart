// lib/services/apis/story_image_service.dart
//
// 🖼️ Masalın yazı halini şık (temalı) bir görsel karta dönüştürür → paylaşım.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/thema/app_colors.dart';

class StoryImageService {
  static const double _w = 1080;
  static const double _pad = 80;

  /// Masaldan paylaşılabilir bir PNG kart üretir, dosya yolunu döndürür.
  /// Yükseklik metne göre dinamik ayarlanır (tüm masal sığar).
  Future<String> renderStoryCard({
    required String title,
    required String content,
    required String category,
    bool addWatermark = true,
  }) async {
    final color =
        AppColors.categoryColors[category] ?? AppColors.brandIndigo;

    final titleTp = _layout(
      title,
      maxWidth: _w - 2 * _pad,
      style: const TextStyle(
        color: Color(0xFFFFD68A),
        fontSize: 62,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      align: TextAlign.center,
    );

    final bodyTp = _layout(
      content,
      maxWidth: _w - 2 * _pad,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 40,
        height: 1.62,
      ),
    );

    const headerSpace = 60.0;
    const footerSpace = 150.0;
    final h = _pad +
        titleTp.height +
        headerSpace +
        bodyTp.height +
        footerSpace +
        _pad;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, _w, h));

    // Gece + kategori renkli gradyan zemin
    final bgTop = Color.lerp(color, const Color(0xFF1A1145), 0.45)!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _w, h),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(_w, h),
          [bgTop, const Color(0xFF0B0824)],
        ),
    );
    // Üst halo
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _w, h),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(_w * 0.5, _pad + titleTp.height * 0.5),
          _w * 0.8,
          [color.withValues(alpha: 0.40), Colors.transparent],
        ),
    );
    // Yıldızlar (yüksekliğe göre)
    final rnd = math.Random(7);
    final starCount = (h / 18).clamp(40, 200).toInt();
    final star = Paint();
    for (var i = 0; i < starCount; i++) {
      star.color =
          (rnd.nextDouble() > 0.85 ? const Color(0xFFFFD68A) : Colors.white)
              .withValues(alpha: rnd.nextDouble() * 0.6 + 0.12);
      canvas.drawCircle(
        Offset(rnd.nextDouble() * _w, rnd.nextDouble() * h),
        rnd.nextDouble() * 2.0 + 0.5,
        star,
      );
    }

    // Başlık (ortalı)
    titleTp.paint(canvas, Offset((_w - titleTp.width) / 2, _pad));

    // İnce ayraç
    final lineY = _pad + titleTp.height + headerSpace * 0.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_w / 2 - 60, lineY, 120, 5),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFFFD68A),
    );

    // Gövde
    bodyTp.paint(canvas, Offset(_pad, _pad + titleTp.height + headerSpace));

    // Alt marka filigranı — yalnızca ücretsiz kullanıcılarda
    if (addWatermark) {
      final footerY = h - footerSpace * 0.6;
      final brand = _layout(
        '🌙 HistoryBox',
        maxWidth: _w,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 38,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        align: TextAlign.center,
      );
      brand.paint(canvas, Offset((_w - brand.width) / 2, footerY));
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(_w.round(), h.round());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final bytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/masal_kart_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  TextPainter _layout(
    String text, {
    required double maxWidth,
    required TextStyle style,
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth);
    return tp;
  }
}
