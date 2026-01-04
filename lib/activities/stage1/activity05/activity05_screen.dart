import 'package:flutter/material.dart';

import '../../common/activity_runner.dart';
import '../../common/task_registry.dart';
import '../../common/task_scaffold.dart';

import 'intro_r_screen.dart';

import 'task01_select_waves.dart';
import 'task02_build_waves.dart';
import 'task03_select_taste.dart';
import 'task04_pop_r_balloons.dart';
import 'task05_build_taste.dart';
import 'task06_fill_blank_waves.dart';
import 'task07_select_words_with_r.dart';
import 'task08_select_circle.dart';
import 'task09_fill_blank_taste.dart';
import 'task10_match_words_to_pictures.dart';

class Stage1Activity05Screen extends StatefulWidget {
  const Stage1Activity05Screen({super.key});

  @override
  State<Stage1Activity05Screen> createState() => _Stage1Activity05ScreenState();
}

class _Stage1Activity05ScreenState extends State<Stage1Activity05Screen> {
  bool _introDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_introDone) {
      return TaskScaffold(
        progress: 0.0,
        onExit: () => Navigator.of(context).maybePop(),
        child: Stage1Activity05Intro(
          onDone: () {
            if (!mounted) return;
            setState(() => _introDone = true);
          },
        ),
      );
    }

    final tasks = <TaskEntry>[
      TaskEntry(
        id: "s1-a05-t01",
        builder: (ctx, cb) => S1A5Task01SelectWaves(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a05-t02",
        builder: (ctx, cb) => S1A5Task02BuildWaves(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a05-t03",
        builder: (ctx, cb) => S1A5Task03SelectTaste(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a05-t04",
        builder: (ctx, cb) => S1A5Task04BalloonPopR(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a05-t05",
        builder: (ctx, cb) => S1A5Task05BuildTaste(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a05-t06",
        builder: (ctx, cb) => S1A5Task06FillBlankWaves(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a05-t07",
        builder: (ctx, cb) => S1A5Task07SelectWordsWithR(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a05-t08",
        builder: (ctx, cb) => S1A5Task08SelectCircle(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a05-t09",
        builder: (ctx, cb) => S1A5Task09FillBlankTaste(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a05-t10",
        builder: (ctx, cb) => S1A5Task10MatchWordsToPictures(callbacks: cb),
      ),
    ];

    return ActivityRunner(
      stage: 1,
      activity: 5,
      initialTasks: tasks,
      onFinished: () => Navigator.of(context).maybePop(),

      // ✅ intro replay hook for “fearful streak”
      introBuilder: (onDone) => Stage1Activity05Intro(onDone: onDone),
    );
  }
}
