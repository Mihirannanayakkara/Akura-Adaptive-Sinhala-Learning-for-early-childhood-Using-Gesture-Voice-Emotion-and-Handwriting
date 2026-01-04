import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A5Task02BuildWaves extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A5Task02BuildWaves({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBuildWordDragTask(
      prompt: "\"රළ\" වචනය සාදන්න",
      pictureEmoji: "🌊",
      parts: const ["ර", "ළ"],
      callbacks: callbacks,
      enableSadAutoFillOne: true,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "“රළ” = ර + ළ. මේ අකුරු දෙක අනුපිළිවෙලට දාන්න!",
        audioAsset: "audio/stage1/activity05/help_task02_build_waves.mp3",
      ),
    );
  }
}
