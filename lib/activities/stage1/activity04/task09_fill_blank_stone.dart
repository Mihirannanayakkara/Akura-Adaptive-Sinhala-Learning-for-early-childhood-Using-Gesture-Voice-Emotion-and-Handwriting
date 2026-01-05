import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A4Task09FillBlankStone extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A4Task09FillBlankStone({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkFillBlankChoiceTask(
      prompt: "නිවැරදි වචනය සාදන්න",
      blankText: "_ල",
      options: const ["අ", "ඉ", "ග", "ස"],
      correct: "ග",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 12),
        explanationText: "“ගල” පටන් ගන්නෙ “ග” වලින්. ඒ නිසා _ල හි “ග” තෝරන්න!",
        audioAsset: "audio/stage1/activity04/help_task09_blank_stone.mp3",
      ),
    );
  }
}
