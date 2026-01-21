import 'dart:math' as math;

import 'package:flutter/material.dart';

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
    this.opacity = 0.22,
  });

  @override
  State<AnimatedSoftBackground> createState() => _AnimatedSoftBackgroundState();
}

class _AnimatedSoftBackgroundState extends State<AnimatedSoftBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        final colorA = widget.colors.isNotEmpty
            ? widget.colors.first
            : Colors.blueAccent;
        final colorB = widget.colors.length > 1
            ? widget.colors[1]
            : Colors.pinkAccent;
        final colorC = widget.colors.length > 2
            ? widget.colors[2]
            : Colors.orangeAccent;
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
              child: ColoredBox(color: widget.backgroundColor),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: Opacity(
                  opacity: widget.opacity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: alignment,
                        end: -alignment2,
                        colors: [
                          colorA,
                          colorB,
                          colorC,
                          colorA,
                        ],
                        stops: const [0.0, 0.45, 0.75, 1.0],
                      ),
                    ),
                  ),
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
