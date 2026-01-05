import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A4Task05BuildStone extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A4Task05BuildStone({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBuildWordDragTask(
      prompt: "\"ගල\" වචනය සාදන්න",
      pictureEmoji: "🪨",
      parts: const ["ග", "ල"],
      callbacks: callbacks,
      enableSadAutoFillOne: true,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "“ගල” = ග + ල. අකුරු දෙකම ඒ අනුපිළිවෙලට දාන්න!",
        audioAsset: "audio/stage1/activity04/help_task05_build_stone.mp3",
      ),
    );
  }
}
