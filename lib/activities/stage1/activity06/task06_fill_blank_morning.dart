import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A6Task06FillBlankMorning extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A6Task06FillBlankMorning({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkFillBlankChoiceTask(
      prompt: "නිවැරදි වචනය සාදන්න",
      blankText: "_දය",
      options: const ["අ", "ග", "උ", "ට"],
      correct: "උ",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 12),
        explanationText: "“උදය” පටන් ගන්නෙ “උ” වලින්. ඒ නිසා _දය හි “උ” තෝරන්න!",
        audioAsset: "audio/stage1/activity06/help_task06_blank_morning.mp3",
      ),
    );
  }
}
