import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VideoSticker extends StatefulWidget {
  final String assetPath;
  final double size; // square size

  const VideoSticker({
    super.key,
    required this.assetPath,
    this.size = 90,
  });

  @override
  State<VideoSticker> createState() => _VideoStickerState();
}

class _VideoStickerState extends State<VideoSticker> {
  late final Future<LottieComposition> _compositionFuture;

  @override
  void initState() {
    super.initState();
    // Load the Lottie JSON composition from assets
    _compositionFuture = AssetLottie(widget.assetPath).load();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return SizedBox(
      width: s,
      height: s,
      child: ClipOval(
        child: FutureBuilder<LottieComposition>(
          future: _compositionFuture,
          builder: (context, snapshot) {
            final composition = snapshot.data;

            if (composition != null) {
              // Bounds are Rectangle<int> in lottie; we size a child then cover-crop it like your mp4 code.
              final w = composition.bounds.width.toDouble();
              final h = composition.bounds.height.toDouble();

              return FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: w,
                  height: h,
                  child: Lottie(
                    composition: composition,
                    repeat: true,
                    animate: true,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                child: const Icon(Icons.error_outline, size: 26),
              );
            }

            return Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            );
          },
        ),
      ),
    );
  }
}
