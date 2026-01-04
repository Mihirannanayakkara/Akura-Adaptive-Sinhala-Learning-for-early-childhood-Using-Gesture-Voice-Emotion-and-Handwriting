import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A5Task01SelectWaves extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A5Task01SelectWaves({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectImageTask(
      prompt: "\"රළ\" දැක්වෙන රූපය තෝරන්න",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "🌊 මේක “රළ” (වැව/මුහුදු රළ) රූපයයි. ඒක තෝරන්න!",
        audioAsset: "audio/stage1/activity05/help_task01_waves.mp3",
      ),
      options: const [
        AkImageOption(label: "රළ", emoji: "🌊", isCorrect: true),
        AkImageOption(label: "රස", emoji: "😋", isCorrect: false),
        AkImageOption(label: "රවුම", emoji: "⭕", isCorrect: false),
        AkImageOption(label: "රතු", emoji: "🔴", isCorrect: false),
      ],
    );
  }
}
