import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'percent_ring.dart';
import 'video_sticker.dart';

class CelebrationScreen extends StatefulWidget {
  final int mistakes;
  final int heartsLeft;
  final int tasksRepeatedCount;

  final int correctAnswers;
  final int totalTasksDone;

  final VoidCallback onContinue;
  final VoidCallback onPracticeAgain;

  const CelebrationScreen({
    super.key,
    required this.mistakes,
    required this.heartsLeft,
    required this.tasksRepeatedCount,
    required this.correctAnswers,
    required this.totalTasksDone,
    required this.onContinue,
    required this.onPracticeAgain,
  });

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Confetti> _confetti;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    final r = math.Random();
    _confetti = List.generate(28, (i) {
      return _Confetti(
        x: r.nextDouble(),
        size: 6 + r.nextDouble() * 10,
        speed: 0.25 + r.nextDouble() * 0.6,
        drift: (r.nextDouble() - 0.5) * 0.25,
        phase: r.nextDouble(),
        color: _confettiColors[i % _confettiColors.length],
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.totalTasksDone <= 0 ? 1 : widget.totalTasksDone;
    final accuracy = widget.correctAnswers / total;
    final percentInt = (accuracy * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(t: _c.value, confetti: _confetti),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB9F6CA), Color(0xFF69F0AE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text("⭐", style: TextStyle(fontSize: 36)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Amazing!",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Activity completed 🎉",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.favorite,
                          iconColor: Colors.red,
                          title: "Hearts",
                          value: "${widget.heartsLeft}",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.warning_amber_rounded,
                          iconColor: Colors.orange,
                          title: "Mistakes",
                          value: "${widget.mistakes}",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Ring occupies middle space; buttons stay at bottom
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Transform.translate(
                        offset: const Offset(0, 50), // adjust ring+sticker+label
                        child: PercentRing(
                          value: accuracy,
                          percentLabel: "$percentInt%",
                          center: const VideoSticker(
                            assetPath: "assets/stickers/stabbed_heart.json",
                            size: 200,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom buttons (always pinned to bottom)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF25C15A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: widget.onContinue,
                      child: const Text(
                        "CONTINUE",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: Colors.black.withOpacity(0.12),
                          width: 2,
                        ),
                      ),
                      onPressed: widget.onPracticeAgain,
                      child: const Text(
                        "PRACTICE AGAIN",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

const _confettiColors = <Color>[
  Color(0xFFFFC107),
  Color(0xFF00C853),
  Color(0xFF40C4FF),
  Color(0xFFFF5252),
  Color(0xFF7C4DFF),
];

class _Confetti {
  final double x;
  final double size;
  final double speed;
  final double drift;
  final double phase;
  final Color color;

  _Confetti({
    required this.x,
    required this.size,
    required this.speed,
    required this.drift,
    required this.phase,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  final List<_Confetti> confetti;

  _ConfettiPainter({required this.t, required this.confetti});

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in confetti) {
      final paint = Paint()..color = c.color.withOpacity(0.85);

      final y = ((t + c.phase) * c.speed) % 1.0;
      final dx = (c.x + math.sin((t + c.phase) * math.pi * 2) * c.drift)
          .clamp(0.0, 1.0);

      final px = dx * size.width;
      final py = y * size.height;

      final rot = math.sin((t + c.phase) * math.pi * 2) * 0.8;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rot);

      final r = Rect.fromCenter(
        center: Offset.zero,
        width: c.size,
        height: c.size * 1.4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(c.size * 0.25)),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
