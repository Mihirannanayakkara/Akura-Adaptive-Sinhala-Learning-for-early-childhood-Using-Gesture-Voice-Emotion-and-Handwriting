import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A2Task06FillBlankTurtle extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A2Task06FillBlankTurtle({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkFillBlankChoiceTask(
      prompt: "නිවැරදි වචනය සාදන්න",
      blankText: "_බ්බා",
      options: const ["අ", "ග", "ඉ", "ට"],
      correct: "ඉ",
      callbacks: callbacks,
    );
  }
}
