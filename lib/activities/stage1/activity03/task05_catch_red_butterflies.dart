import 'package:flutter/material.dart';

import '../../common/task_registry.dart';
import '../../common/color_task_templates.dart';

class S1A3Task05CatchRedButterflies extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A3Task05CatchRedButterflies({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkButterflyCatchTask(
      prompt: "\"රතු\" පාට සමනලයින් තෝරන්න.",
      audioAsset: "audio/stage1/activity03/task05_red_butterfly.mp3",
      targetColor: Colors.red,
      targetLabel: "රතු",
      targetCount: 3,
      targetProbability: 0.25, // 1:4
      otherColors: const [Colors.yellow, Colors.green, Colors.blue],
      callbacks: callbacks,
    );
  }
}
