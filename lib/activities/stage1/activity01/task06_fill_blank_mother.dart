import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A1Task06FillBlankMother extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A1Task06FillBlankMother({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkFillBlankChoiceTask(
      prompt: "නිවැරදි වචනය සාදන්න",
      blankText: "_ම්මා",
      options: const ["අ", "ග", "උ", "ට"],
      correct: "අ",
      callbacks: callbacks,
      questionAudio: "audio/stage1/activity01/q_task06_blank_amma.mp3",
      angryHelp: const AkAngryHelpSpec(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 12),
        explanationText: "“අම්මා” = අ + ම් + මා",
        audioAsset: "audio/stage1/activity01/help_task06_blank_amma.mp3",
      ),

    );
  }
}
