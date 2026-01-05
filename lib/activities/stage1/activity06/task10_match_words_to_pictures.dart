import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A6Task10MatchWordsToPictures extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A6Task10MatchWordsToPictures({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkMatchWordsToPicturesTask(
      prompt: "රූපයට අදාල වචනය තෝරන්න",
      callbacks: callbacks,
      enableSadAutoMatchOne: true,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "ගළපමු! 🎋=උණගස, 🌅=උදය, 🦅=උකුස්සා, 🤒=උන. ඒවා හරියට දාන්න!",
        audioAsset: "audio/stage1/activity06/help_task10_match_all.mp3",
      ),
      pairs: const [
        AkMatchPair(word: "උණගස", emoji: "🎋"),
        AkMatchPair(word: "උදය", emoji: "🌅"),
        AkMatchPair(word: "උකුස්සා", emoji: "🦅"),
        AkMatchPair(word: "උන", emoji: "🤒"),
      ],
    );
  }
}
