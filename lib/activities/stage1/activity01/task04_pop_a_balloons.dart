import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A1Task04BalloonPopA extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A1Task04BalloonPopA({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBalloonPopTask(
      prompt: "\"අ\" යන්න දැක්වෙන බැලුන් පුපුරවන්න",
      targetLetter: "අ",
      targetCount: 3,
      targetProbability: 0.75, // ~ 1 in 4
      otherLetters: const ["ම", "ල", "ර", "ත", "ග", "ක", "ස", "ය"],
      callbacks: callbacks,
    );
  }
}
