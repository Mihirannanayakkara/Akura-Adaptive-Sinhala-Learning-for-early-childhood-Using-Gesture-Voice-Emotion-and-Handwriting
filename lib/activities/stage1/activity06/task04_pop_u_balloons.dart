import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A6Task04BalloonPopU extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A6Task04BalloonPopU({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkBalloonPopTask(
      prompt: "\"උ\" යන්න දැක්වෙන බැලුන් පුපුරවන්න",
      targetLetter: "උ",
      targetCount: 3,
      targetProbability: 0.25, // ~ 1 in 4
      otherLetters: const ["අ", "ග", "න", "ද", "ය", "ර", "ත", "ස", "ල", "ම"],
      callbacks: callbacks,
    );
  }
}
