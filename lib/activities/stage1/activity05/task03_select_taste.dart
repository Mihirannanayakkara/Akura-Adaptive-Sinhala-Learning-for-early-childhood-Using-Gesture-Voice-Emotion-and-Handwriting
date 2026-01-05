import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A5Task03SelectTaste extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A5Task03SelectTaste({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectImageTask(
      prompt: "\"රස\" දැක්වෙන රූපය තෝරන්න",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "😋 මේක “රස” කියන්නේ රස බලන එක. ඒ රූපය තෝරන්න!",
        audioAsset: "audio/stage1/activity05/help_task03_taste.mp3",
      ),
      options: const [
        AkImageOption(label: "රළ", emoji: "🌊", isCorrect: false),
        AkImageOption(label: "රස", emoji: "😋", isCorrect: true),
        AkImageOption(label: "රවුම", emoji: "⭕", isCorrect: false),
        AkImageOption(label: "රතු", emoji: "🔴", isCorrect: false),
      ],
    );
  }
}
