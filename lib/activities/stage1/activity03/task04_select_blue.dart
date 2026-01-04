import 'package:flutter/material.dart';

import '../../common/task_registry.dart';
import '../../common/color_task_templates.dart';

class S1A3Task04SelectBlue extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A3Task04SelectBlue({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectColorCircleTask(
      prompt: "\"නිල්\" පාට තෝරන්න.",
      audioAsset: "audio/stage1/activity03/task04_blue.mp3",
      callbacks: callbacks,
      options: const [
        AkColorCircleOption(label: "රතු", color: Colors.red, isCorrect: false),
        AkColorCircleOption(label: "කහ", color: Colors.yellow, isCorrect: false),
        AkColorCircleOption(label: "කොල", color: Colors.green, isCorrect: false),
        AkColorCircleOption(label: "නිල්", color: Colors.blue, isCorrect: true),
      ],
    );
  }
}
