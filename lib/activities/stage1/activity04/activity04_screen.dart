import 'package:flutter/material.dart';

import '../../common/activity_runner.dart';
import '../../common/task_registry.dart';
import '../../common/task_scaffold.dart';

import 'intro_g_screen.dart';

import 'task01_select_tree.dart';
import 'task02_build_tree.dart';
import 'task03_select_stone.dart';
import 'task04_pop_ga_balloons.dart';
import 'task05_build_stone.dart';
import 'task06_fill_blank_tree.dart';
import 'task07_select_words_with_ga.dart';
import 'task08_select_cow.dart';
import 'task09_fill_blank_stone.dart';
import 'task10_match_words_to_pictures.dart';

class Stage1Activity04Screen extends StatefulWidget {
  const Stage1Activity04Screen({super.key});

  @override
  State<Stage1Activity04Screen> createState() => _Stage1Activity04ScreenState();
}

class _Stage1Activity04ScreenState extends State<Stage1Activity04Screen> {
  bool _introDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_introDone) {
      return TaskScaffold(
        progress: 0.0,
        onExit: () => Navigator.of(context).maybePop(),
        child: Stage1Activity04Intro(
          onDone: () {
            if (!mounted) return;
            setState(() => _introDone = true);
          },
        ),
      );
    }

    final tasks = <TaskEntry>[
      TaskEntry(
        id: "s1-a04-t01",
        builder: (ctx, cb) => S1A4Task01SelectTree(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a04-t02",
        builder: (ctx, cb) => S1A4Task02BuildTree(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a04-t03",
        builder: (ctx, cb) => S1A4Task03SelectStone(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a04-t04",
        builder: (ctx, cb) => S1A4Task04BalloonPopGa(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a04-t05",
        builder: (ctx, cb) => S1A4Task05BuildStone(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a04-t06",
        builder: (ctx, cb) => S1A4Task06FillBlankTree(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a04-t07",
        builder: (ctx, cb) => S1A4Task07SelectWordsWithGa(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a04-t08",
        builder: (ctx, cb) => S1A4Task08SelectCow(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a04-t09",
        builder: (ctx, cb) => S1A4Task09FillBlankStone(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a04-t10",
        builder: (ctx, cb) => S1A4Task10MatchWordsToPictures(callbacks: cb),
      ),
    ];

    return ActivityRunner(
      stage: 1,
      activity: 4,
      initialTasks: tasks,
      onFinished: () => Navigator.of(context).maybePop(),

      // ✅ replay intro when fearful/neutral streak happens
      introBuilder: (onDone) => Stage1Activity04Intro(onDone: onDone),
    );
  }
}
