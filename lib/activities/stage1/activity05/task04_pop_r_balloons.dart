import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A5Task04BalloonPopR extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A5Task04BalloonPopR({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBalloonPopTask(
      prompt: "\"ර\" යන්න දැක්වෙන බැලුන් පුපුරවන්න",
      targetLetter: "ර",
      targetCount: 3,
      targetProbability: 0.25, // ~ 1 in 4
      otherLetters: const ["අ", "ග", "ස", "ත", "ල", "ම", "ක", "ය", "ප", "න"],
      callbacks: callbacks,
    );
  }
}
