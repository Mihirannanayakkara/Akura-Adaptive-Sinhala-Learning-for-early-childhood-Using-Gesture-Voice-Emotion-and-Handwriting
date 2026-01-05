import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A2Task09FillBlankShrimp extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A2Task09FillBlankShrimp({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkFillBlankChoiceTask(
      prompt: "නිවැරදි වචනය සාදන්න",
      blankText: "_ස්සා",
      options: const ["අ", "ඉ", "උ", "ස"],
      correct: "ඉ",
      callbacks: callbacks,
    );
  }
}
