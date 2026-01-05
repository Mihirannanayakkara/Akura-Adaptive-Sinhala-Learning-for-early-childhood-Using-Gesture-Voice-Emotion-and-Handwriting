import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A6Task01SelectBamboo extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A6Task01SelectBamboo({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectImageTask(
      prompt: "\"උණගස\" දැක්වෙන රූපය තෝරන්න",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "🎋 මේක “උණගස” (Bamboo) රූපයයි. ඒක තෝරන්න!",
        audioAsset: "audio/stage1/activity06/help_task01_bamboo.mp3",
      ),
      options: const [
        AkImageOption(label: "උණගස", emoji: "🎋", isCorrect: true),
        AkImageOption(label: "උදය", emoji: "🌅", isCorrect: false),
        AkImageOption(label: "උකුස්සා", emoji: "🦅", isCorrect: false),
        AkImageOption(label: "උන", emoji: "🤒", isCorrect: false),
      ],
    );
  }
}
