import 'package:flutter/material.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:emotion_app/activities/common/task_templates.dart';

class S1A4Task10MatchWordsToPictures extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A4Task10MatchWordsToPictures({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkMatchWordsToPicturesTask(
      prompt: "රූපයට අදාල වචනය තෝරන්න",
      callbacks: callbacks,
      enableSadAutoMatchOne: true,
      angryHelp: const AkAngryHelpSpec(
        explanationText: "ගළපමු! 🌳=ගස, 🚶=ගමන, 🪨=ගල, 🐄=ගවයා. ඒවා හරියට දාන්න!",
        audioAsset: "audio/stage1/activity04/help_task10_match_all.mp3",
      ),
      pairs: const [
        AkMatchPair(word: "ගස", emoji: "🌳"),
        AkMatchPair(word: "ගමන", emoji: "🚶"),
        AkMatchPair(word: "ගල", emoji: "🪨"),
        AkMatchPair(word: "ගවයා", emoji: "🐄"),
      ],
    );
  }
}
