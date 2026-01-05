import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A5Task05BuildTaste extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A5Task05BuildTaste({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBuildWordDragTask(
      prompt: "\"රස\" වචනය සාදන්න",
      pictureEmoji: "😋",
      parts: const ["ර", "ස"],
      callbacks: callbacks,
      enableSadAutoFillOne: true,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "“රස” = ර + ස. දෙකම එකට අනුපිළිවෙලට දාන්න!",
        audioAsset: "audio/stage1/activity05/help_task05_build_taste.mp3",
      ),
    );
  }
}
