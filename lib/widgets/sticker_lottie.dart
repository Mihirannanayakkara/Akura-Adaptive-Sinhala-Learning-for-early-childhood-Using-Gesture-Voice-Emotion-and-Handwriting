import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StickerLottie extends StatelessWidget {
  final String assetPath;
  final double size;
  final bool repeat;

  const StickerLottie({
    super.key,
    required this.assetPath,
    required this.size,
    this.repeat = true,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          assetPath,
          repeat: repeat,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
