import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A2Task05BuildSun extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A2Task05BuildSun({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBuildWordDragTask(
      prompt: "\"ඉර\" වචනය සාදන්න",
      pictureEmoji: "☀️",
      parts: const ["ඉ", "ර"],
      callbacks: callbacks,
    );
  }
}
