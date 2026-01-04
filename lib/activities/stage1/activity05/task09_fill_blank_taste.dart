import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A5Task09FillBlankTaste extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A5Task09FillBlankTaste({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    // ✅ corrected from your copy-paste: this activity uses "රස"
    return AkFillBlankChoiceTask(
      prompt: "නිවැරදි වචනය සාදන්න",
      blankText: "_ස",
      options: const ["අ", "ර", "ග", "ස"],
      correct: "ර",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 12),
        explanationText: "“රස” පටන් ගන්නෙ “ර” වලින්. ඒ නිසා _ස හි “ර” තෝරන්න!",
        audioAsset: "audio/stage1/activity05/help_task09_blank_taste.mp3",
      ),
    );
  }
}
