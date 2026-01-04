import 'package:flutter/widgets.dart';
import 'package:emotion_app/services/emotion_adaptation.dart';
import 'package:emotion_app/services/adaptive_difficulty.dart';

class TaskCallbacks {
  final void Function() onMistake; // deduct heart each time
  final void Function({required bool shouldRepeat}) onComplete;

  /// ✅ NEW (optional): used only by tasks that support emotion-adaptation overlays.
  final EmotionAdaptationController? emotion;

  /// ✅ NEW (optional): current TaskEntry id (so overlay knows which task it belongs to)
  final String? taskId;

  final AdaptiveDifficultyController? difficulty;

  TaskCallbacks({
    required this.onMistake,
    required this.onComplete,
    this.emotion,
    this.taskId,
    this.difficulty,
  });
}

typedef TaskBuilder = Widget Function(BuildContext context, TaskCallbacks cb);

class TaskEntry {
  final String id;
  final TaskBuilder builder;
  final String? questionAudio;
  const TaskEntry({required this.id, required this.builder, this.questionAudio,});
}
