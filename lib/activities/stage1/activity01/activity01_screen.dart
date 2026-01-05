import 'package:flutter/material.dart';

import '../../common/activity_runner.dart';
import '../../common/task_registry.dart';
import '../../common/task_scaffold.dart';

import 'intro_a_screen.dart';

import 'task01_select_mother.dart';
import 'task02_build_mother.dart';
import 'task03_select_elephant.dart';
import 'task04_pop_a_balloons.dart';
import 'task05_build_elephant.dart';
import 'task06_fill_blank_mother.dart';
import 'task07_select_words_with_a.dart';
import 'task08_select_hand.dart';
import 'task09_fill_blank_hand.dart';
import 'task10_match_words_to_pictures.dart';
import '../../../services/adaptive_difficulty.dart';

class Stage1Activity01Screen extends StatefulWidget {
  const Stage1Activity01Screen({super.key});

  @override
  State<Stage1Activity01Screen> createState() => _Stage1Activity01ScreenState();
}

class _Stage1Activity01ScreenState extends State<Stage1Activity01Screen> {
  bool _introDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_introDone) {
      return TaskScaffold(
        progress: 0.0,
        onExit: () => Navigator.of(context).maybePop(),
        child: Stage1Activity01Intro(
          onDone: () {
            if (!mounted) return;
            setState(() => _introDone = true);
          },
        ),
      );
    }

    final tasks = <TaskEntry>[
      TaskEntry(
        id: "s1-a01-t01",
        questionAudio: "audio/stage1/activity01/q_task01.mp3",
        builder: (ctx, cb) => S1A1Task01SelectMother(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a01-t02",
        questionAudio: "audio/stage1/activity01/q_task02.mp3",
        builder: (ctx, cb) => S1A1Task02BuildMother(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a01-t03",
        questionAudio: "audio/stage1/activity01/q_task03.mp3",
        builder: (ctx, cb) => S1A1Task03SelectElephant(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a01-t04",
        questionAudio: "audio/stage1/activity01/q_task04.mp3",
        builder: (ctx, cb) => S1A1Task04BalloonPopA(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a01-t05",
        questionAudio: "audio/stage1/activity01/q_task05.mp3",
        builder: (ctx, cb) => S1A1Task05BuildElephant(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a01-t06",
        questionAudio: "audio/stage1/activity01/q_task06.mp3",
        builder: (ctx, cb) => S1A1Task06FillBlankMother(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a01-t07",
        questionAudio: "audio/stage1/activity01/q_task07.mp3",
        builder: (ctx, cb) => S1A1Task07SelectWordsWithA(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a01-t08",
        questionAudio: "audio/stage1/activity01/q_task08.mp3",
        builder: (ctx, cb) => S1A1Task08SelectHand(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a01-t09",
        questionAudio: "audio/stage1/activity01/q_task09.mp3",
        builder: (ctx, cb) => S1A1Task09FillBlankHand(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a01-t10",
        questionAudio: "audio/stage1/activity01/q_task10.mp3",
        builder: (ctx, cb) => S1A1Task10MatchWordsToPictures(callbacks: cb),
      ),
    ];

    final hardProfile = HardModeProfile({
      // 01/03/08: emoji-only selection
      "s1-a01-t01": const TaskHardModeConfig(hideOptionLabels: true),
      "s1-a01-t03": const TaskHardModeConfig(hideOptionLabels: true),
      "s1-a01-t08": const TaskHardModeConfig(hideOptionLabels: true),

      // 02/05: remove ghost text
      "s1-a01-t02": const TaskHardModeConfig(hideGhostText: true),
      "s1-a01-t05": const TaskHardModeConfig(hideGhostText: true),

      // 06/09: one-use audio per attempt
      "s1-a01-t06": const TaskHardModeConfig(maxQuestionAudioPlays: 1),
      "s1-a01-t09": const TaskHardModeConfig(maxQuestionAudioPlays: 1),

      // 04: targetCount 5 + confuser “ආ”
      "s1-a01-t04": const TaskHardModeConfig(
        balloonTargetCount: 5,
        balloonExtraConfusers: ["ආ"],
      ),

      // 07: only words starting with “අ”
      "s1-a01-t07": const TaskHardModeConfig(
        onlyWordsStartingWith: "අ",
        overridePrompt: "\"අ\" යන්නෙන් ආරම්භ වන වචන තෝරන්න",
      ),

      // 10: decoys
      "s1-a01-t10": const TaskHardModeConfig(
        decoyWordCount: 3,
        decoyCandidates: ["අඹ", "අගුරු", "ආලෝකය", "රට", "මල", "ගස"],
      ),
    });


    return ActivityRunner(
      stage: 1,
      activity: 1,
      initialTasks: tasks,
      onFinished: () => Navigator.of(context).maybePop(),

      // ✅ NEW: Template hook for replaying intro when “fearful” streak happens
      introBuilder: (onDone) => Stage1Activity01Intro(onDone: onDone),

      hardModeProfile: hardProfile,
      happyHardModeWindow: const Duration(seconds: 60),
      happyHardModeCorrectCount: 5,
    );
  }
}
