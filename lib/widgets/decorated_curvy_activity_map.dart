import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'curvy_activity_map.dart';
import 'sticker_lottie.dart';

class DecoratedCurvyActivityMap extends StatelessWidget {
  final int count;
  final List<ActivityStatus> status;
  final double nodeSize;
  final double verticalSpacing;
  final double amplitudeFactor;
  final double waves;
  final void Function(int index)? onTap;

  /// Lottie assets
  final String elephantAsset;
  final String deerAsset;

  const DecoratedCurvyActivityMap({
    super.key,
    required this.count,
    required this.status,
    this.onTap,
    this.nodeSize = 74,
    this.verticalSpacing = 105,
    this.amplitudeFactor = 0.28,
    this.waves = 0.85,
    required this.elephantAsset,
    required this.deerAsset,
  });

  @override
  Widget build(BuildContext context) {
    final height = (count - 1) * verticalSpacing + 140;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, height);

        // Sticker size responsive
        final stickerSize = (size.width * 1.80).clamp(90.0, 10000.0);

        // Match CurvyActivityMap’s curve exactly
        // Elephant: near upper area, pushed to LEFT (your first red circle)
        final elephantCenter = _decorPoint(
          size,
          t: 0.18,
          dx: -size.width * -0.20,
          dy: 300,
        );

        // Deer: mid-ish area where curve swings left, pushed to RIGHT (your second red circle)
        final deerCenter = _decorPoint(
          size,
          t: 0.55,
          dx: size.width * 0.95,
          dy: 440,
        );

        return SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Base map (unchanged logic)
              CurvyActivityMap(
                count: count,
                status: status,
                nodeSize: nodeSize,
                verticalSpacing: verticalSpacing,
                amplitudeFactor: amplitudeFactor,
                waves: waves,
                onTap: onTap,
              ),

              // Stickers on top but NOT clickable (won’t block node taps/scroll)
              Positioned(
                left: elephantCenter.dx - stickerSize / 2,
                top: elephantCenter.dy - stickerSize / 2,
                child: IgnorePointer(
                  child: StickerLottie(
                    assetPath: elephantAsset,
                    size: stickerSize,
                  ),
                ),
              ),

              Positioned(
                left: deerCenter.dx - stickerSize / 2,
                top: deerCenter.dy - stickerSize / 2,
                child: IgnorePointer(
                  child: StickerLottie(
                    assetPath: deerAsset,
                    size: stickerSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Offset _decorPoint(Size size, {required double t, required double dx, required double dy}) {
    final p = _pointOnCurve(t, size);
    return Offset(p.dx + dx, p.dy + dy);
  }

  // MUST match CurvyActivityMap._pointOnCurve exactly
  Offset _pointOnCurve(double t, Size size) {
    final topPad = 70.0;
    final bottomPad = 70.0;
    final y = topPad + t * (size.height - topPad - bottomPad);

    final centerX = size.width * 0.5;
    final amp = size.width * amplitudeFactor;

    final phase = math.pi * 0.07;
    final x = centerX + amp * math.sin(2 * math.pi * waves * t + phase);

    return Offset(x, y);
  }
}
