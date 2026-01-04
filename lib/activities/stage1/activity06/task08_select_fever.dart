import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A6Task08SelectFever extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A6Task08SelectFever({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectImageTask(
      prompt: "\"උන\" දැක්වෙන රූපය තෝරන්න",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "🤒 මේක “උන” (Fever) රූපයයි. ඒ රූපය තෝරන්න!",
        audioAsset: "audio/stage1/activity06/help_task08_fever.mp3",
      ),
      options: const [
        AkImageOption(label: "උණගස", emoji: "🎋", isCorrect: false),
        AkImageOption(label: "උදය", emoji: "🌅", isCorrect: false),
        AkImageOption(label: "උකුස්සා", emoji: "🦅", isCorrect: false),
        AkImageOption(label: "උන", emoji: "🤒", isCorrect: true),
      ],
    );
  }
}
