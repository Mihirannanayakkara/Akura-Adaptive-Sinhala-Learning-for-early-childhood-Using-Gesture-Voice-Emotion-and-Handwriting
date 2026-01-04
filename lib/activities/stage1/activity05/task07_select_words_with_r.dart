import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A5Task07SelectWordsWithR extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A5Task07SelectWordsWithR({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkMultiSelectWordsTask(
      prompt: "\"ර\" යන්න ඇතුලත් වචන තෝරන්න",
      words: const ["ගස", "රට", "අම්මා", "රතු", "ඉර", "ගවයා"],
      correctWords: const {"රට", "රතු", "ඉර"},
      callbacks: callbacks,
      angryHelp: const AkAngryHelpSpec(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 12),
        explanationText: "“ර” තියෙන වචන 3ක්: රට, රතු, ඉර. ඒ තුනම තෝරන්න!",
        audioAsset: "audio/stage1/activity05/help_task07_words_with_r.mp3",
      ),
    );
  }
}
