import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A6Task02BuildMorning extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A6Task02BuildMorning({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBuildWordDragTask(
      prompt: "\"උදය\" වචනය සාදන්න",
      pictureEmoji: "🌅",
      parts: const ["උ", "ද", "ය"],
      callbacks: callbacks,
      enableSadAutoFillOne: true,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "“උදය” = උ + ද + ය. මේ අකුරු තුනම අනුපිළිවෙලට දාන්න!",
        audioAsset: "audio/stage1/activity06/help_task02_build_morning.mp3",
      ),
    );
  }
}
