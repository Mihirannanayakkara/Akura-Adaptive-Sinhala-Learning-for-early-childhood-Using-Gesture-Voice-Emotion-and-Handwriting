import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A4Task03SelectStone extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A4Task03SelectStone({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectImageTask(
      prompt: "\"ගල\" දැක්වෙන රූපය තෝරන්න",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "🪨 මේක “ගල” රූපයයි. “ගල” = 🪨",
        audioAsset: "audio/stage1/activity04/help_task03_stone.mp3",
      ),
      options: const [
        AkImageOption(label: "ගස", emoji: "🌳", isCorrect: false),
        AkImageOption(label: "ගමන", emoji: "🚶", isCorrect: false),
        AkImageOption(label: "ගල", emoji: "🪨", isCorrect: true),
        AkImageOption(label: "ගවයා", emoji: "🐄", isCorrect: false),
      ],
    );
  }
}
