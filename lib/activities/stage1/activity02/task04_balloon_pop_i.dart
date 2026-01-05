import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A2Task04BalloonPopI extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A2Task04BalloonPopI({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBalloonPopTask(
      prompt: "\"ඉ\" යන්න දැක්වෙන බැලුන් පුපුරවන්න",
      targetLetter: "ඉ",
      targetCount: 3,
      targetProbability: 0.25, // ~ 1 in 4
      otherLetters: const ["අ", "ම", "ර", "ක", "ල", "ස", "ත", "ය"],
      callbacks: callbacks,
    );
  }
}
