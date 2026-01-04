import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A6Task09FillBlankFever extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A6Task09FillBlankFever({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkFillBlankChoiceTask(
      prompt: "නිවැරදි වචනය සාදන්න",
      blankText: "_න",
      options: const ["අ", "උ", "ග", "ස"],
      correct: "උ",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 12),
        explanationText: "“උන” පටන් ගන්නෙ “උ” වලින්. ඒ නිසා _න හි “උ” තෝරන්න!",
        audioAsset: "audio/stage1/activity06/help_task09_blank_fever.mp3",
      ),
    );
  }
}
