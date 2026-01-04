import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A5Task08SelectCircle extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A5Task08SelectCircle({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectImageTask(
      prompt: "\"රවුම\" දැක්වෙන රූපය තෝරන්න",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "⭕ මේක “රවුම” (වට රූපයක්) රූපයයි. ඒක තෝරන්න!",
        audioAsset: "audio/stage1/activity05/help_task08_circle.mp3",
      ),
      options: const [
        AkImageOption(label: "රළ", emoji: "🌊", isCorrect: false),
        AkImageOption(label: "රස", emoji: "😋", isCorrect: false),
        AkImageOption(label: "රවුම", emoji: "⭕", isCorrect: true),
        AkImageOption(label: "රතු", emoji: "🔴", isCorrect: false),
      ],
    );
  }
}
