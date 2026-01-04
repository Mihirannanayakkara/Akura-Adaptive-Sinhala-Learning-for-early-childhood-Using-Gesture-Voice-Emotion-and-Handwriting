import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A4Task04BalloonPopGa extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A4Task04BalloonPopGa({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBalloonPopTask(
      prompt: "\"ග\" යන්න දැක්වෙන බැලුන් පුපුරවන්න",
      targetLetter: "ග",
      targetCount: 3,
      targetProbability: 0.25, // 1 in 4
      otherLetters: const ["අ", "ස", "ල", "ම", "ර", "ත", "ක", "ය", "න", "ප", "හ", "ව"],
      callbacks: callbacks,
    );
  }
}
