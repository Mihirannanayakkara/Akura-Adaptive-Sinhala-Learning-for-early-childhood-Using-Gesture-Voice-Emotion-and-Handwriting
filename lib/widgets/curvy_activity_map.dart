import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ActivityStatus { locked, unlocked, completed }

class CurvyActivityMap extends StatelessWidget {
  final int count; // e.g. 10
  final double nodeSize; // e.g. 74
  final double verticalSpacing; // e.g. 105
  final double amplitudeFactor; // how wide the curve is (0.0 - 0.5)
  final double waves; // how many left-right swings
  final List<ActivityStatus> status;
  final void Function(int index)? onTap;

  const CurvyActivityMap({
    super.key,
    required this.count,
    required this.status,
    this.onTap,
    this.nodeSize = 74,
    this.verticalSpacing = 105,
    this.amplitudeFactor = 0.28,
    this.waves = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final height = (count - 1) * verticalSpacing + 140; // extra padding

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, height);

        // Precompute points for nodes
        final points = List.generate(count, (i) {
          final t = count == 1 ? 0.0 : i / (count - 1);
          return _pointOnCurve(t, size);
        });

        return SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            children: [
              // Draw the curvy guide path behind nodes (optional)
              CustomPaint(
                size: size,
                painter: _CurvyPathPainter(points: points),
              ),

              // Place the nodes
              for (int i = 0; i < count; i++)
                Positioned(
                  left: points[i].dx - nodeSize / 2,
                  top: points[i].dy - nodeSize / 2,
                  child: _ActivityNode(
                    size: nodeSize,
                    index: i,
                    status: status[i],
                    onTap: () {
                      if (status[i] == ActivityStatus.locked) return;
                      onTap?.call(i);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Offset _pointOnCurve(double t, Size size) {
    // y goes top -> bottom smoothly
    final topPad = 70.0;
    final bottomPad = 70.0;
    final y = topPad + t * (size.height - topPad - bottomPad);

    // x follows a smooth sine wave
    final centerX = size.width * 0.5;
    final amp = size.width * amplitudeFactor;

    // phase shift makes the first node slightly right/left depending on taste
    final phase = math.pi * 0.07;

    final x = centerX + amp * math.sin(2 * math.pi * waves * t + phase);

    return Offset(x, y);
  }
}

class _ActivityNode extends StatelessWidget {
  final double size;
  final int index;
  final ActivityStatus status;
  final VoidCallback onTap;

  const _ActivityNode({
    required this.size,
    required this.index,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool locked = status == ActivityStatus.locked;
    final bool completed = status == ActivityStatus.completed;

    final Color fill = completed
        ? const Color(0xFF1DB954)
        : (locked ? const Color(0xFFD9D9D9) : const Color(0xFF18B7FF));

    final IconData icon = locked
        ? Icons.lock
        : (completed ? Icons.star : Icons.star);

    final Color iconColor = locked ? Colors.grey.shade700 : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }
}

class _CurvyPathPainter extends CustomPainter {
  final List<Offset> points;

  _CurvyPathPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Draw a smooth-ish curve through the points (quadratic segments)
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvyPathPainter oldDelegate) =>
      oldDelegate.points != points;
}
