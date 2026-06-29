import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../thema/app_colors.dart';

/// Premium hareketli arka plan.
/// - Aydınlık temada: yumuşak lavanta "aurora" akışı.
/// - Gece temasında: gece yarısı gradyanı + ışıldayan yıldız alanı.
///
/// Verilen [colors]/[backgroundColor] aydınlık temada kullanılır; gece
/// temasında otomatik olarak premium gece paleti devreye girer.
class AnimatedSoftBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Color backgroundColor;
  final Duration duration;
  final double opacity;

  const AnimatedSoftBackground({
    super.key,
    required this.child,
    required this.colors,
    required this.backgroundColor,
    this.duration = const Duration(seconds: 20),
    this.opacity = 0.28,
  });

  @override
  State<AnimatedSoftBackground> createState() => _AnimatedSoftBackgroundState();
}

class _AnimatedSoftBackgroundState extends State<AnimatedSoftBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    // Sabit (deterministik) yıldız alanı
    final rnd = math.Random(7);
    _stars = List.generate(60, (i) {
      return _Star(
        dx: rnd.nextDouble(),
        dy: rnd.nextDouble() * 0.7,
        radius: rnd.nextDouble() * 1.3 + 0.4,
        phase: rnd.nextDouble(),
        gold: rnd.nextDouble() > 0.78,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = isDark ? AppColors.nightBackgroundGradient : widget.colors;
    final background =
        isDark ? AppColors.backgroundDark : widget.backgroundColor;
    final auroraOpacity = isDark ? 0.55 : widget.opacity;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        final colorA = colors.isNotEmpty ? colors.first : Colors.blueAccent;
        final colorB = colors.length > 1 ? colors[1] : Colors.pinkAccent;
        final colorC = colors.length > 2 ? colors[2] : Colors.orangeAccent;
        final alignment = Alignment(
          math.sin(t * math.pi * 2) * 0.65,
          math.cos(t * math.pi * 2) * 0.65,
        );
        final alignment2 = Alignment(
          math.cos(t * math.pi * 2) * -0.55,
          math.sin(t * math.pi * 2) * 0.55,
        );
        return Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: background),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: Opacity(
                  opacity: auroraOpacity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: alignment,
                        end: -alignment2,
                        colors: [colorA, colorB, colorC, colorA],
                        stops: const [0.0, 0.45, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isDark)
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _StarfieldPainter(_stars, t),
                  ),
                ),
              ),
            child ?? const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}

class _Star {
  final double dx;
  final double dy;
  final double radius;
  final double phase;
  final bool gold;

  const _Star({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.phase,
    required this.gold,
  });
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;

  _StarfieldPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in stars) {
      // Yumuşak yanıp sönme
      final twinkle =
          0.35 + 0.65 * (0.5 + 0.5 * math.sin((t + star.phase) * math.pi * 2));
      paint.color = (star.gold ? const Color(0xFFFFD68A) : Colors.white)
          .withValues(alpha: twinkle * 0.9);
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) =>
      oldDelegate.t != t;
}
