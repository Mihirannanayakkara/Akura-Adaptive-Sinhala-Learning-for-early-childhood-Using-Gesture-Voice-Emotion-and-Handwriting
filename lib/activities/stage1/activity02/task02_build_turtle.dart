import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A2Task02BuildTurtle extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A2Task02BuildTurtle({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBuildWordDragTask(
      prompt: "\"ඉබ්බා\" වචනය සාදන්න",
      pictureEmoji: "🐢",
      parts: const ["ඉ", "බ්", "බා"],
      callbacks: callbacks,
    );
  }
}
