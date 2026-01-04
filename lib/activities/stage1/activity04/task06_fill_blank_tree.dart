import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A4Task06FillBlankTree extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A4Task06FillBlankTree({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkFillBlankChoiceTask(
      prompt: "නිවැරදි වචනය සාදන්න",
      blankText: "_ස",
      options: const ["අ", "ග", "ඉ", "ට"],
      correct: "ග",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 12),
        explanationText: "“ගස” පටන් ගන්නෙ “ග” වලින්. ඒ නිසා _ස හි “ග” තෝරන්න!",
        audioAsset: "audio/stage1/activity04/help_task06_blank_tree.mp3",
      ),
    );
  }
}
