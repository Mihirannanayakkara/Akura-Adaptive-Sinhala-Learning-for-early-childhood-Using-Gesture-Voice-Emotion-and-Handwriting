import 'dart:math';
import 'package:flutter/material.dart';

class SkeletonPainter extends CustomPainter {
  final Path? path;
  final List<Offset> startGuide;
  final List<Offset> endGuide;

  SkeletonPainter(this.path, this.startGuide, this.endGuide);

  @override
  void paint(Canvas canvas, Size size) {
    final minDim = min(size.width, size.height);
    if (path != null) {
      final paintStroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = max(2.0, minDim * 0.012)
        ..color = const Color(0xFFA3A3A3).withValues(alpha: 0.6);
      canvas.drawPath(path!, paintStroke);
    }
    if (startGuide.isNotEmpty) {
      final startColor = const Color(0xFF22C55E);
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(3.0, minDim * 0.01)
        ..color = startColor.withValues(alpha: 0.9);
      final g = Path()..moveTo(startGuide.first.dx, startGuide.first.dy);
      for (int i = 1; i < startGuide.length; i++) {
        g.lineTo(startGuide[i].dx, startGuide[i].dy);
      }
      canvas.drawPath(g, stroke);
      final start = startGuide.first;
      final next = startGuide.length > 1 ? startGuide[1] : start + const Offset(1, 0);
      final dirVec = next - start;
      final dirLen = dirVec.distance;
      final dir = dirLen > 0.001 ? Offset(dirVec.dx / dirLen, dirVec.dy / dirLen) : const Offset(1, 0);
      final circlePaint = Paint()..color = startColor;
      canvas.drawCircle(start, stroke.strokeWidth * 1.9, circlePaint);
      final arrowLen = min(minDim * 0.06, start.dy - 8.0);
      final arrowTop = Offset(start.dx, start.dy - arrowLen);
      final arrowPaint = Paint()
        ..color = startColor.withValues(alpha: 0.4)
        ..strokeWidth = max(1.2, stroke.strokeWidth * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(arrowTop, start, arrowPaint);
      final arrowSize = max(3.0, minDim * 0.014);
      final arrowLeft = arrowTop + Offset(-arrowSize * 0.6, arrowSize);
      final arrowRight = arrowTop + Offset(arrowSize * 0.6, arrowSize);
      final arrowPath = Path()
        ..moveTo(arrowTop.dx, arrowTop.dy)
        ..lineTo(arrowLeft.dx, arrowLeft.dy)
        ..lineTo(arrowRight.dx, arrowRight.dy)
        ..close();
      canvas.drawPath(arrowPath, Paint()..color = startColor.withValues(alpha: 0.4));
      final flagHeight = minDim * 0.08;
      final flagWidth = flagHeight * 0.65;
      final poleTop = start - dir * flagHeight;
      final flagPaint = Paint()..color = startColor;
      final polePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = stroke.strokeWidth * 0.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(start, poleTop, polePaint);
      final flagPerp = Offset(-dir.dy, dir.dx);
      final flagTip = poleTop + dir * flagWidth + flagPerp * (flagWidth * 0.4);
      final flagPath = Path()
        ..moveTo(poleTop.dx, poleTop.dy)
        ..lineTo(flagTip.dx, flagTip.dy)
        ..lineTo((poleTop + dir * flagWidth).dx, (poleTop + dir * flagWidth).dy)
        ..close();
      canvas.drawPath(flagPath, flagPaint);
    }
    if (endGuide.isNotEmpty) {
      final endColor = const Color(0xFFDC2626);
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(3.0, minDim * 0.01)
        ..color = endColor.withValues(alpha: 0.9);
      final g = Path()..moveTo(endGuide.first.dx, endGuide.first.dy);
      for (int i = 1; i < endGuide.length; i++) {
        g.lineTo(endGuide[i].dx, endGuide[i].dy);
      }
      canvas.drawPath(g, stroke);
      final end = endGuide.last;
      final prev = endGuide.length > 1 ? endGuide[endGuide.length - 2] : end - const Offset(1, 0);
      final dirVec = end - prev;
      final dirLen = dirVec.distance;
      final dir = dirLen > 0.001 ? Offset(dirVec.dx / dirLen, dirVec.dy / dirLen) : const Offset(1, 0);
      final circlePaint = Paint()..color = endColor;
      canvas.drawCircle(end, stroke.strokeWidth * 1.9, circlePaint);
      final flagHeight = minDim * 0.08;
      final flagWidth = flagHeight * 0.65;
      final poleTop = end + dir * flagHeight;
      final flagPaint = Paint()..color = endColor;
      final polePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = stroke.strokeWidth * 0.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(end, poleTop, polePaint);
      final flagPerp = Offset(dir.dy, -dir.dx);
      final flagTip = poleTop + dir * flagWidth + flagPerp * (flagWidth * 0.4);
      final flagPath = Path()
        ..moveTo(poleTop.dx, poleTop.dy)
        ..lineTo(flagTip.dx, flagTip.dy)
        ..lineTo((poleTop + dir * flagWidth).dx, (poleTop + dir * flagWidth).dy)
        ..close();
      canvas.drawPath(flagPath, flagPaint);
    }
  }
  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) => oldDelegate.path != path || oldDelegate.startGuide != startGuide || oldDelegate.endGuide != endGuide;
}

class DrawPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> samples;
  final double thrScale;
  DrawPainter(this.strokes, this.samples, this.thrScale);

  @override
  void paint(Canvas canvas, Size size) {
    final minDim = min(size.width, size.height);
    final width = max(6.0, minDim * 0.02);
    final pOk = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width
      ..color = const Color(0xFF16A34A);
    final pBad = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width
      ..color = const Color(0xFFEF4444);
    final thr = minDim * 0.035 * thrScale;
    for (final s in strokes) {
      if (s.length < 2) continue;
      for (int i = 1; i < s.length; i++) {
        final p0 = s[i - 1];
        final p1 = s[i];
        final d = _nearestDist(p1);
        final paint = d <= thr ? pOk : pBad;
        canvas.drawLine(p0, p1, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant DrawPainter oldDelegate) => !identical(oldDelegate.strokes, strokes);
  double _nearestDist(Offset p) {
    double minD = double.infinity;
    for (final q in samples) {
      final dx = q.dx - p.dx;
      final dy = q.dy - p.dy;
      final d = dx * dx + dy * dy;
      if (d < minD) minD = d;
    }
    return sqrt(minD);
  }
}

class Confetti {
  Offset pos;
  Offset vel;
  double size;
  Color color;
  double life;
  Confetti(this.pos, this.vel, this.size, this.color, this.life);
}

class ConfettiPainter extends CustomPainter {
  final List<Confetti> items;
  ConfettiPainter(this.items);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final c in items) {
      paint.color = c.color.withValues(alpha: (c.life.clamp(0, 1)).toDouble());
      final r = Rect.fromCenter(center: c.pos, width: c.size, height: c.size);
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(c.size * 0.2)), paint);
    }
  }
  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
