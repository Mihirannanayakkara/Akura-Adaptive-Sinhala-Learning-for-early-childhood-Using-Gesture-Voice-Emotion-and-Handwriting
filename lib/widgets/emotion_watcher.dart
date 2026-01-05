import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/emotion_detector.dart';
import '../services/notification_service.dart';

class EmotionWatcher extends StatefulWidget {
  final Widget child;

  final bool enabled;

  /// Only count detections >= this confidence
  final double minConfidence;

  /// We will only accept 1 sample per this duration (your "once per 5 seconds")
  final Duration cooldown;

  /// ✅ New rule: send notification only if same emotion repeats N times consecutively
  final int requiredConsecutive;

  final void Function(EmotionResult r)? onStreak;

  const EmotionWatcher({
    super.key,
    required this.child,
    this.enabled = true,
    this.minConfidence = 0.35,
    this.cooldown = const Duration(seconds: 5),
    this.requiredConsecutive = 4,
    this.onStreak,

  });

  @override
  State<EmotionWatcher> createState() => _EmotionWatcherState();
}

class _EmotionWatcherState extends State<EmotionWatcher> {
  StreamSubscription? _sub;

  // Latest result shown in bubble
  EmotionResult? _latest;

  // ✅ Sampling guard (1 accepted sample per 5s)
  DateTime _lastAcceptedSampleAt = DateTime.fromMillisecondsSinceEpoch(0);

  // ✅ Streak tracking
  String? _streakLabel;
  int _streakCount = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant EmotionWatcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _start();
      } else {
        _stop();
      }
    }
  }

  Future<void> _start() async {
    if (!widget.enabled) return;

    await NotificationService.instance.init();
    await EmotionDetector.instance.start();

    if (mounted) setState(() {});

    await _sub?.cancel();
    _sub = EmotionDetector.instance.results.listen((r) async {
      if (!mounted) return;

      setState(() => _latest = r);

      // ✅ accept at most 1 sample per cooldown window
      final now = DateTime.now();
      if (now.difference(_lastAcceptedSampleAt) < widget.cooldown) {
        return;
      }
      _lastAcceptedSampleAt = now;

      // ✅ low confidence breaks the streak (because not a reliable detection)
      if (r.confidence < widget.minConfidence) {
        _resetStreak();
        return;
      }

      // ✅ update streak
      if (_streakLabel == r.label) {
        _streakCount += 1;
      } else {
        _streakLabel = r.label;
        _streakCount = 1;
      }

      if (kDebugMode) {
        debugPrint(
          "Emotion sample: ${r.label} ${(r.confidence * 100).toStringAsFixed(0)}% "
          "streak=$_streakCount/${widget.requiredConsecutive}",
        );
      }

      // ✅ notify only when same label seen N consecutive accepted samples
      if (_streakCount >= widget.requiredConsecutive) {

        widget.onStreak?.call(r);
        
        await NotificationService.instance.showEmotion(
          emotion: r.label,
          confidence: r.confidence,
        );

        // ✅ reset so you don't spam every next sample
        _resetStreak();
      }
    });
  }

  void _resetStreak() {
    _streakLabel = null;
    _streakCount = 0;
  }

  Future<void> _stop() async {
    await _sub?.cancel();
    _sub = null;

    await EmotionDetector.instance.stop();

    if (mounted) {
      setState(() {
        _latest = null;
        _lastAcceptedSampleAt = DateTime.fromMillisecondsSinceEpoch(0);
        _resetStreak();
      });
    }
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cam = EmotionDetector.instance.cameraController;

    final top = MediaQuery.of(context).padding.top + 10;
    final right = 10.0;

    return Stack(
      children: [
        widget.child,

        if (widget.enabled)
          Positioned(
            top: top,
            right: right,
            child: IgnorePointer(
              ignoring: true,
              child: _CameraBubble(
                controller: cam,
                label: _latest?.label,
                confidence: _latest?.confidence,
              ),
            ),
          ),
      ],
    );
  }
}

class _CameraBubble extends StatelessWidget {
  final CameraController? controller;
  final String? label;
  final double? confidence;

  const _CameraBubble({
    required this.controller,
    this.label,
    this.confidence,
  });

  static const double _size = 56;
  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null || !c.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final aspect = c.value.aspectRatio;
    final containerAspect = 1.0;
    final scale = math.max(containerAspect / aspect, aspect / containerAspect);

    return Material(
      elevation: 6,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_radius),
      child: SizedBox(
        width: _size,
        height: _size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: Colors.black),

              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Transform.scale(
                  scale: scale,
                  child: Center(child: CameraPreview(c)),
                ),
              ),

              if (label != null && confidence != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                    color: Colors.black54,
                    child: Text(
                      "${label!} ${(confidence! * 100).toStringAsFixed(0)}%",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_radius),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
