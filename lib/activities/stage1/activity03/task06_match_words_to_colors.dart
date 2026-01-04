import 'package:flutter/material.dart';

import '../../common/task_registry.dart';
import '../../common/color_task_templates.dart';

class S1A3Task06MatchWordsToColors extends StatelessWidget {
  final TaskCallbacks callbacks;
  const S1A3Task06MatchWordsToColors({super.key, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    return AkMatchWordsToColorsTask(
      prompt: "පාටට අදාල වචනය තෝරන්න",
      audioAsset: "audio/stage1/activity03/task06_match_colors.mp3",
      callbacks: callbacks,
      pairs: const [
        AkColorMatchPair(word: "රතු", color: Colors.red),
        AkColorMatchPair(word: "කහ", color: Colors.yellow),
        AkColorMatchPair(word: "කොල", color: Colors.green),
        AkColorMatchPair(word: "නිල්", color: Colors.blue),
      ],
    );
  }
}
