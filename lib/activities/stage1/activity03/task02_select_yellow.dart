import 'package:flutter/material.dart';

import '../../common/task_registry.dart';
import '../../common/color_task_templates.dart';

class S1A3Task02SelectYellow extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A3Task02SelectYellow({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectColorCircleTask(
      prompt: "\"කහ\" පාට තෝරන්න.",
      audioAsset: "audio/stage1/activity03/task02_yellow.mp3",
      callbacks: callbacks,
      options: const [
        AkColorCircleOption(label: "රතු", color: Colors.red, isCorrect: false),
        AkColorCircleOption(label: "කහ", color: Colors.yellow, isCorrect: true),
        AkColorCircleOption(label: "කොල", color: Colors.green, isCorrect: false),
        AkColorCircleOption(label: "නිල්", color: Colors.blue, isCorrect: false),
      ],
    );
  }
}
