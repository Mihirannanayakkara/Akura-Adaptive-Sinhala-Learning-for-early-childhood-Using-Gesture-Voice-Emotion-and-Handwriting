import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Stage1Activity03Intro extends StatefulWidget {
  final VoidCallback onDone;

  const Stage1Activity03Intro({super.key, required this.onDone});

  @override
  State<Stage1Activity03Intro> createState() => _Stage1Activity03IntroState();
}

class _Stage1Activity03IntroState extends State<Stage1Activity03Intro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final AudioPlayer _p = AudioPlayer();

  int _index = 0;
  bool _fadeOut = false;
  bool _running = false;

  final _steps = const [
    _IntroStep(color: Colors.red, audio: "audio/stage1/activity03/intro_red.mp3"),
    _IntroStep(color: Colors.yellow, audio: "audio/stage1/activity03/intro_yellow.mp3"),
    _IntroStep(color: Colors.green, audio: "audio/stage1/activity03/intro_green.mp3"),
    _IntroStep(color: Colors.blue, audio: "audio/stage1/activity03/intro_blue.mp3"),
  ];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    _c.dispose();
    _p.dispose();
    super.dispose();
  }

  Future<void> _play(String asset) async {
    try {
      await _p.stop();
      await _p.play(AssetSource(asset));
    } catch (_) {}
  }

  Future<void> _run() async {
    if (_running) return;
    _running = true;

    for (int i = 0; i < _steps.length; i++) {
      if (!mounted) return;

      setState(() {
        _index = i;
        _fadeOut = false;
      });

      await _play(_steps[i].audio);

      _c.reset();
      await _c.forward();

      await Future.delayed(const Duration(milliseconds: 11000));
      if (!mounted) return;

      setState(() => _fadeOut = true);
      await Future.delayed(const Duration(milliseconds: 180));
    }

    if (!mounted) return;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 12,
              child: TextButton(
                onPressed: widget.onDone,
                child: const Text(
                  "Skip",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: _fadeOut ? 0 : 1,
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _CircleDrawPainter(
                          color: step.color,
                          progress: _c.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroStep {
  final Color color;
  final String audio;
  const _IntroStep({required this.color, required this.audio});
}

class _CircleDrawPainter extends CustomPainter {
  final Color color;
  final double progress;

  _CircleDrawPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 18;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final start = -math.pi / 2;
    final sweep = 2 * math.pi * progress;

    canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _CircleDrawPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}
