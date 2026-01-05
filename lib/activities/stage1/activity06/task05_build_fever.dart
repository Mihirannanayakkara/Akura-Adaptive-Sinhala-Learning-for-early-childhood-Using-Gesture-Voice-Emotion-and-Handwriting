import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A6Task05BuildFever extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A6Task05BuildFever({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBuildWordDragTask(
      prompt: "\"උන\" වචනය සාදන්න",
      pictureEmoji: "🤒",
      parts: const ["උ", "න"],
      callbacks: callbacks,
      enableSadAutoFillOne: true,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "“උන” = උ + න. මේ අකුරු දෙක අනුපිළිවෙලට දාන්න!",
        audioAsset: "audio/stage1/activity06/help_task05_build_fever.mp3",
      ),
    );
  }
}
