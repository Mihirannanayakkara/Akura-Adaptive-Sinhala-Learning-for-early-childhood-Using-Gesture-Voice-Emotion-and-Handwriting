import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A5Task06FillBlankWaves extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A5Task06FillBlankWaves({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkFillBlankChoiceTask(
      prompt: "නිවැරදි වචනය සාදන්න",
      blankText: "_ළ",
      options: const ["අ", "ග", "ර", "ට"],
      correct: "ර",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 12),
        explanationText: "“රළ” පටන් ගන්නෙ “ර” වලින්. ඒ නිසා _ළ හි “ර” තෝරන්න!",
        audioAsset: "audio/stage1/activity05/help_task06_blank_waves.mp3",
      ),
    );
  }
}
