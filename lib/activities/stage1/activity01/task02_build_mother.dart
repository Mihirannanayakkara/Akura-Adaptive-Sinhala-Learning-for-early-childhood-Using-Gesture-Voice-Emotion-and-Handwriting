import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A1Task02BuildMother extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A1Task02BuildMother({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBuildWordDragTask(
  prompt: "\"අම්මා\" වචනය සාදන්න",
  pictureEmoji: "👩‍🍼",
  parts: const ["අ", "ම්", "මා"],
  callbacks: callbacks,
  enableSadAutoFillOne: true,
  angryHelp: const AkAngryHelpSpec(
    explanationText: "“අම්මා” = අ + ම් + මා",
    audioAsset: "audio/stage1/activity01/help_task02_build_amma.mp3",
  ),
);

  }
}
