import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A1Task08SelectHand extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A1Task08SelectHand({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectImageTask(
      prompt: "\"අත\" දැක්වෙන රූපය තෝරන්න",
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "✋ මේ “අත” රූපයයි",
        audioAsset: "audio/stage1/activity01/help_task08_atha.mp3",
      ),
      options: const [
        AkImageOption(label: "අම්මා", emoji: "👩‍🍼", isCorrect: false),
        AkImageOption(label: "අලියා", emoji: "🐘", isCorrect: false),
        AkImageOption(label: "අල", emoji: "🥔", isCorrect: false),
        AkImageOption(label: "අත", emoji: "✋", isCorrect: true),
      ],
    );
  }
}
