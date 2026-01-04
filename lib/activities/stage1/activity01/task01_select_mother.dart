import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A1Task01SelectMother extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A1Task01SelectMother({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectImageTask(
  prompt: "\"අම්මා\" දැක්වෙන රූපය තෝරන්න",
  callbacks: callbacks,
  angryHelp: const AkAngryHelpSpec(
    explanationText: "👩‍🍼 මේ “අම්මා” රූපයයි",
    audioAsset: "audio/stage1/activity01/help_task01_amma.mp3",
  ),
  options: const [
    AkImageOption(label: "අම්මා", emoji: "👩‍🍼", isCorrect: true),
    AkImageOption(label: "අලියා", emoji: "🐘", isCorrect: false),
    AkImageOption(label: "අල", emoji: "🥔", isCorrect: false),
    AkImageOption(label: "අත", emoji: "✋", isCorrect: false),
  ],
);

  }
}
