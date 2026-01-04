import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A1Task07SelectWordsWithA extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A1Task07SelectWordsWithA({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkMultiSelectWordsTask(
      prompt: "\"අ\" යන්න ඇතුලත් වචන තෝරන්න",
      words: const ["මල", "රට", "අම්මා", "අලියා", "අල"],
      correctWords: const {"අම්මා", "අලියා", "අල"},
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 12),
        explanationText: "“අ” තියෙන වචන 3ක් තියෙනවා: අම්මා, අලියා, අල",
        audioAsset: "audio/stage1/activity01/help_task07_words_with_a.mp3",
      ),

    );
  }
}
