import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A1Task05BuildElephant extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A1Task05BuildElephant({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBuildWordDragTask(
      prompt: "\"අලියා\" වචනය සාදන්න",
      pictureEmoji: "🐘",
      parts: const ["අ", "ලි", "යා"],
      callbacks: callbacks,
      enableSadAutoFillOne: true,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "“අලියා” = අ + ලි + යා",
        audioAsset: "audio/stage1/activity01/help_task05_build_aliya.mp3",
      ),
    );
  }
}
