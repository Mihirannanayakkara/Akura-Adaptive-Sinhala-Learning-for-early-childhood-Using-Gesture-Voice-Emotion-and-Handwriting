// lib/activities/common/activity_runner.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import 'celebration_screen.dart';
import 'task_registry.dart';
import 'task_scaffold.dart';
import 'package:emotion_app/widgets/emotion_watcher.dart';
import 'package:emotion_app/services/emotion_adaptation.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:emotion_app/services/adaptive_difficulty.dart'; // ✅ NEW

typedef ActivityIntroBuilder = Widget Function(VoidCallback onDone);

class ActivityRunner extends StatefulWidget {
  final int stage;
  final int activity;
  final List<TaskEntry> initialTasks;
  final VoidCallback onFinished;
  final ActivityIntroBuilder? introBuilder;

  // ✅ NEW: hard-mode template config (optional)
  final HardModeProfile? hardModeProfile;

  // ✅ NEW: gate settings (defaults match your requirement)
  final Duration happyHardModeWindow;
  final int happyHardModeCorrectCount;

  const ActivityRunner({
    super.key,
    required this.stage,
    required this.activity,
    required this.initialTasks,
    required this.onFinished,
    this.introBuilder,

    this.hardModeProfile,
    this.happyHardModeWindow = const Duration(seconds: 60),
    this.happyHardModeCorrectCount = 5,
  });

  @override
  State<ActivityRunner> createState() => _ActivityRunnerState();
}

class _ActivityRunnerState extends State<ActivityRunner> {
  late final List<TaskEntry> _initial;
  late List<TaskEntry> _queue;

  int _solvedCount = 0;
  int _mistakes = 0;
  final Set<String> _tasksThatHadMistakes = {};

  int _totalTasksDone = 0;
  int _correctAnswers = 0;

  bool _activityMarkedComplete = false;
  bool _showCelebration = false;

  static const double _cameraBubbleGutter = 72;

  final EmotionAdaptationController _emotion = EmotionAdaptationController();

  bool _replayingIntro = false;
  int _introReplayNonce = 0;

  int _taskViewNonce = 0;

  final AudioPlayer _qPlayer = AudioPlayer();
  String? _lastAutoPlayedKey;

  // ✅ NEW: difficulty controller
  AdaptiveDifficultyController? _difficulty;
  bool _hardModeAlreadyApplied = false;

  @override
  void initState() {
    super.initState();
    _initial = List<TaskEntry>.from(widget.initialTasks);

    if (widget.hardModeProfile != null) {
      _difficulty = AdaptiveDifficultyController(
        profile: widget.hardModeProfile!,
        correctWindow: widget.happyHardModeWindow,
        requiredCorrect: widget.happyHardModeCorrectCount,
      );
      _difficulty!.addListener(_onDifficultyChanged);
    }

    _resetRun();
  }

  void _onDifficultyChanged() {
    if (!mounted) return;

    // When hard mode flips ON, force-remount current task so initState-based logic re-runs.
    if (_difficulty?.hardModeEnabled == true && !_hardModeAlreadyApplied) {
      _hardModeAlreadyApplied = true;
      setState(() {
        _taskViewNonce += 1;
      });
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _difficulty?.removeListener(_onDifficultyChanged);
    _difficulty?.dispose();

    _qPlayer.dispose();
    super.dispose();
  }

  Future<void> _playQuestionAudio(String asset) async {
    try {
      await _qPlayer.stop();
      await _qPlayer.play(AssetSource(asset));
    } catch (_) {}
  }

  void _resetRun() {
    _queue = List<TaskEntry>.from(_initial);
    _solvedCount = 0;
    _mistakes = 0;
    _tasksThatHadMistakes.clear();

    _totalTasksDone = 0;
    _correctAnswers = 0;

    _showCelebration = false;
    _activityMarkedComplete = false;

    _replayingIntro = false;
    _introReplayNonce = 0;

    _taskViewNonce = 0;
    _lastAutoPlayedKey = null;

    _emotion.reset();

    // ✅ NEW
    _hardModeAlreadyApplied = false;
    _difficulty?.reset();
  }

  void _startIntroReplay() {
    if (widget.introBuilder == null) return;
    if (_replayingIntro) return;

    _qPlayer.stop();

    setState(() {
      _replayingIntro = true;
      _introReplayNonce += 1;
    });
  }

  void _endIntroReplay() {
    if (!mounted) return;
    setState(() => _replayingIntro = false);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();

    if (_showCelebration) {
      return CelebrationScreen(
        mistakes: _mistakes,
        heartsLeft: app.hearts,
        tasksRepeatedCount: _tasksThatHadMistakes.length,
        correctAnswers: _correctAnswers,
        totalTasksDone: _totalTasksDone,
        onContinue: widget.onFinished,
        onPracticeAgain: () {
          setState(() {
            _resetRun();
          });
        },
      );
    }

    if (_queue.isEmpty) {
      if (!_activityMarkedComplete) {
        _activityMarkedComplete = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          app.completeActivity(widget.stage, widget.activity);

          setState(() {
            _showCelebration = true;
          });
        });
      }

      return EmotionWatcher(
        enabled: false,
        child: TaskScaffold(
          progress: 1.0,
          topRightGutter: 0,
          onExit: () => Navigator.of(context).maybePop(),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final current = _queue.first;

    final autoPlayKey = "task_${current.id}_$_taskViewNonce";

    if (!_replayingIntro &&
        current.questionAudio != null &&
        _lastAutoPlayedKey != autoPlayKey) {
      _lastAutoPlayedKey = autoPlayKey;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_replayingIntro) return;
        _playQuestionAudio(current.questionAudio!);
      });
    }

    final total = _solvedCount + _queue.length;
    final progress = total == 0 ? 0.0 : (_solvedCount / total).clamp(0.0, 1.0);

    final callbacks = TaskCallbacks(
      onMistake: () {
        _mistakes += 1;
        _tasksThatHadMistakes.add(current.id);
        app.spendHeart();
      },
      onComplete: ({required bool shouldRepeat}) {
        if (!mounted) return;

        setState(() {
          _totalTasksDone += 1;

          if (!shouldRepeat) {
            _correctAnswers += 1;

            // ✅ NEW: feed correct completion to difficulty controller
            _difficulty?.recordCorrect();
          }

          final finished = _queue.removeAt(0);
          _solvedCount += 1;

          if (shouldRepeat) {
            _tasksThatHadMistakes.add(finished.id);
            _queue.add(finished);
          }

          _taskViewNonce += 1;
        });
      },
      emotion: _emotion,
      taskId: current.id,
      difficulty: _difficulty, // ✅ NEW
    );

    return EmotionWatcher(
      enabled: true,
      minConfidence: 0.35,
      cooldown: const Duration(seconds: 5),
      requiredConsecutive: 4,
      onStreak: (r) {
        if (_replayingIntro) return;

        final label = r.label.toLowerCase().trim();

        if (label == "angry" && r.confidence > 0.35) {
          _emotion.triggerAngryHelp(taskId: current.id, emotion: r);
        }

        if (label == "sad" ) {
          _emotion.triggerSadReduceOptions(taskId: current.id, emotion: r);
        }

        if ((label == "fearful" || label == "neutral") && r.confidence > 0.35) {
          final didTrigger = _emotion.triggerFearfulReplayIntro(
            taskId: current.id,
            emotion: r,
          );
          if (didTrigger) {
            _startIntroReplay();
          }
        }

        // ✅ NEW: Happy streak -> arm hard mode gate
        if (label == "happy" && r.confidence > 0.35) {
          _difficulty?.onHappyStreak(r);
        }
      },
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: _replayingIntro,
            child: TaskScaffold(
              progress: progress,
              topRightGutter: _cameraBubbleGutter,
              onExit: () => Navigator.of(context).maybePop(),
              child: KeyedSubtree(
                key: ValueKey("task_${current.id}_$_taskViewNonce"),
                child: current.builder(context, callbacks),
              ),
            ),
          ),
          if (_replayingIntro && widget.introBuilder != null)
            Positioned.fill(
              child: Material(
                color: const Color(0xFFF7F8FA),
                child: KeyedSubtree(
                  key: ValueKey("intro_replay_$_introReplayNonce"),
                  child: widget.introBuilder!(_endIntroReplay),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
