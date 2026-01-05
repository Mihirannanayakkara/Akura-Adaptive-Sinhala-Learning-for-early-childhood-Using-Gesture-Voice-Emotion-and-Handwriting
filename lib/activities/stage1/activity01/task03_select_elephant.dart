import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A1Task03SelectElephant extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A1Task03SelectElephant({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectImageTask(
  prompt: "\"අලියා\" දැක්වෙන රූපය තෝරන්න",
  callbacks: callbacks,
  angryHelp: const AkAngryHelpSpec(
    explanationText: "🐘 මේ “අලියා” රූපයයි",
    audioAsset: "audio/stage1/activity01/help_task03_aliya.mp3",
  ),
  options: const [
    AkImageOption(label: "අම්මා", emoji: "👩‍🍼", isCorrect: false),
    AkImageOption(label: "අලියා", emoji: "🐘", isCorrect: true),
    AkImageOption(label: "අල", emoji: "🥔", isCorrect: false),
    AkImageOption(label: "අත", emoji: "✋", isCorrect: false),
  ],
);

  }
}
