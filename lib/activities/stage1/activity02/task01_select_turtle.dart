import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A2Task01SelectTurtle extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A2Task01SelectTurtle({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkSelectImageTask(
      prompt: "\"ඉබ්බා\" දැක්වෙන රූපය තෝරන්න",
      callbacks: callbacks,
      options: const [
        AkImageOption(label: "ඉබ්බා", emoji: "🐢", isCorrect: true),
        AkImageOption(label: "ඉර", emoji: "☀️", isCorrect: false),
        AkImageOption(label: "ඉදල", emoji: "🧹", isCorrect: false),
        AkImageOption(label: "ඉස්සා", emoji: "🦐", isCorrect: false),
      ],
    );
  }
}
