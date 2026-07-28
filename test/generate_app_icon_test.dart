// Uygulama ikonu / splash gorsellerini kullanicinin verdigi logodan
// (assets/icon/source_logo.png) uretir. Calistirma:
//   flutter test test/generate_app_icon_test.dart
// Uretilenler:
//   assets/icon/app_icon.png            -> 1024, opak (iOS + legacy Android)
//   assets/icon/app_icon_foreground.png -> 1024, adaptive foreground
//   assets/icon/splash_logo.png         -> 1024, saydam kenarli (splash)
// Bu bir gorsel uretim aracidir; gercek bir test degildir.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

const String _src = 'assets/icon/source_logo.png';

Future<ui.Image> _decode(String path) async {
  final bytes = File(path).readAsBytesSync();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

/// Kaynak gorselden [src] bolgesini alip [canvas] uzerine [dst] icine cizer.
Future<void> _crop({
  required ui.Image img,
  required ui.Rect srcRect,
  required ui.Rect dstRect,
  required String outPath,
  required int size,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint()
    ..isAntiAlias = true
    ..filterQuality = ui.FilterQuality.high;
  canvas.drawImageRect(img, srcRect, dstRect, paint);
  final image = await recorder.endRecording().toImage(size, size);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(outPath);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(data!.buffer.asUint8List());
  // ignore: avoid_print
  print('yazildi: $outPath');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('kullanici logosundan ikon ve splash uret', () async {
    final img = await _decode(_src);
    final w = img.width.toDouble();
    final h = img.height.toDouble();
    // ignore: avoid_print
    print('kaynak: ${img.width}x${img.height}');

    // Logo goruntude yatayda merkezden hafif sagda, dikeyde ortada.
    // Oranlarla logoyu siki saran kare bir bolge sec (2816x1536 icin ayarli).
    final cropSize = 0.846 * h; // ~1300
    final cx0 = 0.284 * w; // ~800
    final cy0 = 0.083 * h; // ~128
    final srcSquare = ui.Rect.fromLTWH(cx0, cy0, cropSize, cropSize);

    const full = ui.Rect.fromLTWH(0, 0, 1024, 1024);
    // Splash: logo biraz kucuk, kenarlarda saydam bosluk.
    const pad = 120.0;
    final inset = ui.Rect.fromLTWH(pad, pad, 1024 - 2 * pad, 1024 - 2 * pad);

    await _crop(
      img: img,
      srcRect: srcSquare,
      dstRect: full,
      outPath: 'assets/icon/app_icon.png',
      size: 1024,
    );
    await _crop(
      img: img,
      srcRect: srcSquare,
      dstRect: full,
      outPath: 'assets/icon/app_icon_foreground.png',
      size: 1024,
    );
    await _crop(
      img: img,
      srcRect: srcSquare,
      dstRect: inset,
      outPath: 'assets/icon/splash_logo.png',
      size: 1024,
    );
  });
}
