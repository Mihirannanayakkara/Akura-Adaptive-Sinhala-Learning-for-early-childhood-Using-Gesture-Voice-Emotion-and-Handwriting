import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A4Task02BuildTree extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A4Task02BuildTree({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBuildWordDragTask(
      prompt: "\"ගස\" වචනය සාදන්න",
      pictureEmoji: "🌳",
      parts: const ["ග", "ස"],
      callbacks: callbacks,
      enableSadAutoFillOne: true,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "“ගස” = ග + ස. අකුරු දෙකම ඒ අනුපිළිවෙලට දාන්න!",
        audioAsset: "audio/stage1/activity04/help_task02_build_tree.mp3",
      ),
    );
  }
}
