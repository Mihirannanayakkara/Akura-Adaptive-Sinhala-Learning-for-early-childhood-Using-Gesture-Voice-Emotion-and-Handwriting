import 'dart:math' as math;
import 'package:flutter/material.dart';

class PercentRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final double strokeWidth;
  final Widget center;
  final String percentLabel;

  const PercentRing({
    super.key,
    required this.value,
    required this.center,
    required this.percentLabel,
    this.size = 250,
    this.strokeWidth = 20,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: clamped),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(size, size),
                    painter: _RingPainter(
                      progress: v,
                      strokeWidth: strokeWidth,
                      bgColor: Colors.black.withOpacity(0.08),
                      fgColor: const Color.fromARGB(255, 241, 229, 61),
                    ),
                  ),
                  Container(
                    width: size - strokeWidth * 2.1,
                    height: size - strokeWidth * 2.1,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Center(child: center),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              percentLabel,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color.fromARGB(255, 177, 166, 19),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color bgColor;
  final Color fgColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (math.min(size.width, size.height) / 2) - strokeWidth / 2;

    final bg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = fgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(c, r, bg);

    final start = -math.pi / 2;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.bgColor != bgColor ||
        oldDelegate.fgColor != fgColor;
  }
}
