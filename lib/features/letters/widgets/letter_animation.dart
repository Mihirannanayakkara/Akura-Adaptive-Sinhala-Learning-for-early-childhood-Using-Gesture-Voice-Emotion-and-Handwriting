import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LetterAnimation extends StatefulWidget {
  final String? jsonAsset;

  const LetterAnimation({super.key, this.jsonAsset});

  @override
  State<LetterAnimation> createState() => LetterAnimationState();
}

class LetterAnimationState extends State<LetterAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Path? _basePath;

  void restart() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), 
    );

    if (widget.jsonAsset != null) {
      _loadJson();
    }
  }

  Future<void> _loadJson() async {
    try {
      final jsonString = await rootBundle.loadString(widget.jsonAsset!);
      final data = json.decode(jsonString);
      final stroke = data['strokes'][0] as List;

      final path = Path();
      for (int i = 0; i < stroke.length; i++) {
        final p = stroke[i];
        final o = Offset(
          (p['x'] as num).toDouble(),
          (p['y'] as num).toDouble(),
        );
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }

      setState(() => _basePath = path);
      _controller.forward().whenComplete(() {
        HapticFeedback.mediumImpact();
      });
    } catch (e) {
      debugPrint("Error loading letter JSON: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_basePath == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _StrokePainter(
            basePath: _basePath!,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _StrokePainter extends CustomPainter {
  final Path basePath;
  final double progress;

  _StrokePainter({
    required this.basePath,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = basePath.getBounds();


    double scaleX = (size.width * 0.75) / bounds.width;
    double scaleY = (size.height * 0.75) / bounds.height;
    double s = min(scaleX, scaleY);

    final tx = (size.width - bounds.width * s) / 2 - bounds.left * s;
    final ty = (size.height - bounds.height * s) / 2 - bounds.top * s;

    canvas.save();
    canvas.translate(tx, ty);
    canvas.scale(s);

    
    final skeletonPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(basePath, skeletonPaint);

    
    final guidePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(basePath, guidePaint);

    
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.blue, Colors.lightBlueAccent, Colors.cyan],
      ).createShader(bounds)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final metrics = basePath.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final m = metrics.first;
      final currentLength = m.length * progress;
      final animatedPath = m.extractPath(0, currentLength);
      
      
      canvas.drawPath(animatedPath, progressPaint);

      
      final tangent = m.getTangentForOffset(currentLength);
      if (tangent != null) {
        final pos = tangent.position;
        
       
        final glowPaint = Paint()
          ..color = Colors.orange.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(pos, 15, glowPaint);

        
        final headPaint = Paint()
          ..color = Colors.orangeAccent
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 8, headPaint);
        
        
        canvas.drawCircle(pos, 3, Paint()..color = Colors.white);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}