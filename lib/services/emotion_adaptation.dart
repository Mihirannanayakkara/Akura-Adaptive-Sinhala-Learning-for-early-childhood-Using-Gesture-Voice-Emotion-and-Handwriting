import 'package:flutter/foundation.dart';
import 'package:emotion_app/services/emotion_detector.dart';

enum EmotionAdaptationType {
  angryHelp,
  sadReduceOptions,

  // ✅ NEW: fearful streak -> replay activity intro
  fearfulReplayIntro,
}

class EmotionAdaptationEvent {
  final EmotionAdaptationType type;
  final String taskId;
  final EmotionResult emotion;

  const EmotionAdaptationEvent({
    required this.type,
    required this.taskId,
    required this.emotion,
  });
}

/// Small event bus for “emotion-triggered adaptations”.
/// - Emits last event (tasks/runner listen and decide if they care)
/// - Ensures “once per task per adaptation type per run”
class EmotionAdaptationController extends ChangeNotifier {
  EmotionAdaptationEvent? _last;
  EmotionAdaptationEvent? get lastEvent => _last;

  final Map<EmotionAdaptationType, Set<String>> _triggeredByType = {
    EmotionAdaptationType.angryHelp: <String>{},
    EmotionAdaptationType.sadReduceOptions: <String>{},

    // ✅ NEW
    EmotionAdaptationType.fearfulReplayIntro: <String>{},
  };

  bool hasTriggered({
    required EmotionAdaptationType type,
    required String taskId,
  }) {
    return _triggeredByType[type]!.contains(taskId);
  }

  // Backwards-compatible helper (true if ANY adaptation was triggered for this task)
  bool hasTriggeredForTask(String taskId) {
    return _triggeredByType.values.any((s) => s.contains(taskId));
  }

  bool triggerAngryHelp({
    required String taskId,
    required EmotionResult emotion,
  }) {
    final set = _triggeredByType[EmotionAdaptationType.angryHelp]!;
    if (set.contains(taskId)) return false;

    set.add(taskId);
    _last = EmotionAdaptationEvent(
      type: EmotionAdaptationType.angryHelp,
      taskId: taskId,
      emotion: emotion,
    );
    notifyListeners();
    return true;
  }

  /// “sad” adaptation → reduce wrong answers (DO NOT reveal correct)
  bool triggerSadReduceOptions({
    required String taskId,
    required EmotionResult emotion,
  }) {
    final set = _triggeredByType[EmotionAdaptationType.sadReduceOptions]!;
    if (set.contains(taskId)) return false;

    set.add(taskId);
    _last = EmotionAdaptationEvent(
      type: EmotionAdaptationType.sadReduceOptions,
      taskId: taskId,
      emotion: emotion,
    );
    notifyListeners();
    return true;
  }

  /// ✅ NEW: “fearful” adaptation → request replay of the activity intro
  bool triggerFearfulReplayIntro({
    required String taskId,
    required EmotionResult emotion,
  }) {
    final set = _triggeredByType[EmotionAdaptationType.fearfulReplayIntro]!;
    if (set.contains(taskId)) return false;

    set.add(taskId);
    _last = EmotionAdaptationEvent(
      type: EmotionAdaptationType.fearfulReplayIntro,
      taskId: taskId,
      emotion: emotion,
    );
    notifyListeners();
    return true;
  }

  void reset() {
    for (final s in _triggeredByType.values) {
      s.clear();
    }
    _last = null;
    notifyListeners();
  }
}
