import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A2Task10MatchWords extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A2Task10MatchWords({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkMatchWordsToPicturesTask(
      prompt: "රූපයට අදාල වචනය තෝරන්න",
      callbacks: callbacks,
      pairs: const [
        AkMatchPair(word: "ඉබ්බා", emoji: "🐢"),
        AkMatchPair(word: "ඉර", emoji: "☀️"),
        AkMatchPair(word: "ඉදල", emoji: "🧹"),
        AkMatchPair(word: "ඉස්සා", emoji: "🦐"),
      ],
    );
  }
}
