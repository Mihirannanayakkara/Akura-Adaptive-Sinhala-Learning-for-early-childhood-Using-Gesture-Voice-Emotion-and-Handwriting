import 'package:flutter/material.dart';

import '../../common/task_registry.dart';
import '../../common/color_task_templates.dart';

class S1A3Task03SelectGreen extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A3Task03SelectGreen({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectColorCircleTask(
      prompt: "\"කොල\" පාට තෝරන්න.",
      audioAsset: "audio/stage1/activity03/task03_green.mp3",
      callbacks: callbacks,
      options: const [
        AkColorCircleOption(label: "රතු", color: Colors.red, isCorrect: false),
        AkColorCircleOption(label: "කහ", color: Colors.yellow, isCorrect: false),
        AkColorCircleOption(label: "කොල", color: Colors.green, isCorrect: true),
        AkColorCircleOption(label: "නිල්", color: Colors.blue, isCorrect: false),
      ],
    );
  }
}
