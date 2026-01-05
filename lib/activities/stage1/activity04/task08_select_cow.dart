import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A4Task08SelectCow extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A4Task08SelectCow({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectImageTask(
      prompt: "\"ගවයා\" දැක්වෙන රූපය තෝරන්න",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "🐄 මේක “ගවයා” රූපයයි. “ගවයා” = 🐄",
        audioAsset: "audio/stage1/activity04/help_task08_cow.mp3",
      ),
      options: const [
        AkImageOption(label: "ගස", emoji: "🌳", isCorrect: false),
        AkImageOption(label: "ගමන", emoji: "🚶", isCorrect: false),
        AkImageOption(label: "ගල", emoji: "🪨", isCorrect: false),
        AkImageOption(label: "ගවයා", emoji: "🐄", isCorrect: true),
      ],
    );
  }
}
