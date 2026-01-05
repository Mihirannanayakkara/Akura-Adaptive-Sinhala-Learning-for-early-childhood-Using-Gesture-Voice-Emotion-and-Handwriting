import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A2Task07SelectWordsWithI extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A2Task07SelectWordsWithI({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkMultiSelectWordsTask(
      prompt: "\"ඉ\" යන්න ඇතුලත් වචන තෝරන්න",
      words: const ["ඉබ්බා", "රට", "අම්මා", "අලියා", "ඉර"],
      correctWords: const {"ඉබ්බා", "ඉර"},
      callbacks: callbacks,
    );
  }
}
