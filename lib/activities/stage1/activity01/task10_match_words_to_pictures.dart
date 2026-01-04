import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A1Task10MatchWordsToPictures extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A1Task10MatchWordsToPictures({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkMatchWordsToPicturesTask(
      prompt: "රූපයට අදාල වචනය තෝරන්න",
      callbacks: callbacks,
      enableSadAutoMatchOne: true,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "👩‍🍼=අම්මා  🐘=අලියා  🥔=අල  ✋=අත",
        audioAsset: "audio/stage1/activity01/help_task10_match_all.mp3",
      ),
      pairs: const [
        AkMatchPair(word: "අම්මා", emoji: "👩‍🍼"),
        AkMatchPair(word: "අලියා", emoji: "🐘"),
        AkMatchPair(word: "අල", emoji: "🥔"),
        AkMatchPair(word: "අත", emoji: "✋"),
      ],
    );
  }
}
