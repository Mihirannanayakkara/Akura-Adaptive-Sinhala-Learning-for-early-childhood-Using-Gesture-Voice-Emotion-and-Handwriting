import 'package:flutter/foundation.dart';
import 'package:emotion_app/services/emotion_detector.dart';

@immutable
class TaskHardModeConfig {
  // Task 01/03/08 (emoji-only selection)
  final bool hideOptionLabels;

  // Task 02/05 (remove faint ghost text)
  final bool hideGhostText;

  // Task 06/09 (audio button max plays per attempt)
  final int? maxQuestionAudioPlays;

  // Task 04 (increase targetCount, add confusers)
  final int? balloonTargetCount;
  final List<String> balloonExtraConfusers;

  // Task 07 (start-with rule)
  final String? onlyWordsStartingWith;
  final String? overridePrompt;

  // Task 10 (decoy words in pool)
  final int? decoyWordCount;
  final List<String> decoyCandidates;

  const TaskHardModeConfig({
    this.hideOptionLabels = false,
    this.hideGhostText = false,
    this.maxQuestionAudioPlays,
    this.balloonTargetCount,
    this.balloonExtraConfusers = const [],
    this.onlyWordsStartingWith,
    this.overridePrompt,
    this.decoyWordCount,
    this.decoyCandidates = const [],
  });
}

@immutable
class HardModeProfile {
  final Map<String, TaskHardModeConfig> byTaskId;
  const HardModeProfile(this.byTaskId);

  TaskHardModeConfig? forTask(String taskId) => byTaskId[taskId];
}

/// Turns ON "hard mode" when BOTH are true (within same window):
/// 1) Happy streak event observed (EmotionWatcher already enforces 4 consecutive)
/// 2) >= requiredCorrect correct tasks completed within correctWindow (rolling)
class AdaptiveDifficultyController extends ChangeNotifier {
  final HardModeProfile profile;
  final Duration correctWindow;
  final int requiredCorrect;

  bool _hardModeEnabled = false;
  bool get hardModeEnabled => _hardModeEnabled;

  DateTime? _happyStreakAt;
  final List<DateTime> _correctAt = [];

  AdaptiveDifficultyController({
    required this.profile,
    this.correctWindow = const Duration(seconds: 60),
    this.requiredCorrect = 5,
  });

  /// Returns null if hard mode off OR task not configured.
  TaskHardModeConfig? configForTask(String? taskId) {
    if (!_hardModeEnabled || taskId == null) return null;
    return profile.forTask(taskId);
  }

  void onHappyStreak(EmotionResult r) {
    _happyStreakAt = r.at;
    _evaluate(now: r.at);
  }

  void recordCorrect({DateTime? at}) {
    final now = at ?? DateTime.now();
    _correctAt.add(now);
    _prune(now: now);
    _evaluate(now: now);
  }

  void _prune({required DateTime now}) {
    _correctAt.removeWhere((t) => now.difference(t) > correctWindow);
  }

  void _evaluate({required DateTime now}) {
    if (_hardModeEnabled) return;

    final happyOk =
        _happyStreakAt != null && now.difference(_happyStreakAt!) <= correctWindow;

    final correctOk = _correctAt.length >= requiredCorrect;

    if (happyOk && correctOk) {
      _hardModeEnabled = true;
      notifyListeners();
    }
  }

  void reset() {
    _hardModeEnabled = false;
    _happyStreakAt = null;
    _correctAt.clear();
    notifyListeners();
  }
}
