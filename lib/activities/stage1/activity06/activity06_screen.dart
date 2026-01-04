import 'package:flutter/material.dart';

import '../../common/activity_runner.dart';
import '../../common/task_registry.dart';
import '../../common/task_scaffold.dart';

import 'intro_u_screen.dart';

import 'task01_select_bamboo.dart';
import 'task02_build_morning.dart';
import 'task03_select_eagle.dart';
import 'task04_pop_u_balloons.dart';
import 'task05_build_fever.dart';
import 'task06_fill_blank_morning.dart';
import 'task07_select_words_with_u.dart';
import 'task08_select_fever.dart';
import 'task09_fill_blank_fever.dart';
import 'task10_match_words_to_pictures.dart';

class Stage1Activity06Screen extends StatefulWidget {
  const Stage1Activity06Screen({super.key});

  @override
  State<Stage1Activity06Screen> createState() => _Stage1Activity06ScreenState();
}

class _Stage1Activity06ScreenState extends State<Stage1Activity06Screen> {
  bool _introDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_introDone) {
      return TaskScaffold(
        progress: 0.0,
        onExit: () => Navigator.of(context).maybePop(),
        child: Stage1Activity06Intro(
          onDone: () {
            if (!mounted) return;
            setState(() => _introDone = true);
          },
        ),
      );
    }

    final tasks = <TaskEntry>[
      TaskEntry(
        id: "s1-a06-t01",
        builder: (ctx, cb) => S1A6Task01SelectBamboo(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a06-t02",
        builder: (ctx, cb) => S1A6Task02BuildMorning(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a06-t03",
        builder: (ctx, cb) => S1A6Task03SelectEagle(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a06-t04",
        builder: (ctx, cb) => S1A6Task04BalloonPopU(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a06-t05",
        builder: (ctx, cb) => S1A6Task05BuildFever(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a06-t06",
        builder: (ctx, cb) => S1A6Task06FillBlankMorning(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a06-t07",
        builder: (ctx, cb) => S1A6Task07SelectWordsWithU(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a06-t08",
        builder: (ctx, cb) => S1A6Task08SelectFever(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a06-t09",
        builder: (ctx, cb) => S1A6Task09FillBlankFever(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a06-t10",
        builder: (ctx, cb) => S1A6Task10MatchWordsToPictures(callbacks: cb),
      ),
    ];

    return ActivityRunner(
      stage: 1,
      activity: 6,
      initialTasks: tasks,
      onFinished: () => Navigator.of(context).maybePop(),

      // ✅ Intro replay hook for fearful streak (your ActivityRunner already supports this)
      introBuilder: (onDone) => Stage1Activity06Intro(onDone: onDone),
    );
  }
}
