import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A6Task07SelectWordsWithU extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A6Task07SelectWordsWithU({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkMultiSelectWordsTask(
      prompt: "\"උ\" යන්න ඇතුලත් වචන තෝරන්න",
      words: const ["උකුස්සා", "රට", "උදැල්ල", "ගල", "ඉර", "උන"],
      correctWords: const {"උකුස්සා", "උදැල්ල", "උන"},
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 12),
        explanationText: "“උ” තියෙන වචන 3ක්: උකුස්සා, උදැල්ල, උන. ඒ තුනම තෝරන්න!",
        audioAsset: "audio/stage1/activity06/help_task07_words_with_u.mp3",
      ),
    );
  }
}
