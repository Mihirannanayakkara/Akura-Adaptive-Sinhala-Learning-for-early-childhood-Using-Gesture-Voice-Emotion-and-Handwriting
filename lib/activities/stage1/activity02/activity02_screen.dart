import 'package:flutter/material.dart';

import '../../common/activity_runner.dart';
import '../../common/task_registry.dart';
import '../../common/task_scaffold.dart';

import 'intro_i_screen.dart';

import 'task01_select_turtle.dart';
import 'task02_build_turtle.dart';
import 'task03_select_sun.dart';
import 'task04_balloon_pop_i.dart';
import 'task05_build_sun.dart';
import 'task06_fill_blank_turtle.dart';
import 'task07_select_words_with_i.dart';
import 'task08_select_shrimp.dart';
import 'task09_fill_blank_shrimp.dart';
import 'task10_match_words.dart';

class Stage1Activity02Screen extends StatefulWidget {
  const Stage1Activity02Screen({super.key});

  @override
  State<Stage1Activity02Screen> createState() => _Stage1Activity02ScreenState();
}

class _Stage1Activity02ScreenState extends State<Stage1Activity02Screen> {
  bool _introDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_introDone) {
      return TaskScaffold(
        progress: 0.0,
        onExit: () => Navigator.of(context).maybePop(),
        child: Stage1Activity02Intro(
          onDone: () {
            if (!mounted) return;
            setState(() => _introDone = true);
          },
        ),
      );
    }

    final tasks = <TaskEntry>[
      TaskEntry(
        id: "s1-a02-t01",
        builder: (ctx, cb) => S1A2Task01SelectTurtle(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a02-t02",
        builder: (ctx, cb) => S1A2Task02BuildTurtle(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a02-t03",
        builder: (ctx, cb) => S1A2Task03SelectSun(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a02-t04",
        builder: (ctx, cb) => S1A2Task04BalloonPopI(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a02-t05",
        builder: (ctx, cb) => S1A2Task05BuildSun(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a02-t06",
        builder: (ctx, cb) => S1A2Task06FillBlankTurtle(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a02-t07",
        builder: (ctx, cb) => S1A2Task07SelectWordsWithI(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a02-t08",
        builder: (ctx, cb) => S1A2Task08SelectShrimp(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a02-t09",
        builder: (ctx, cb) => S1A2Task09FillBlankShrimp(callbacks: cb),
      ),
      TaskEntry(
        id: "s1-a02-t10",
        builder: (ctx, cb) => S1A2Task10MatchWords(callbacks: cb),
      ),
    ];

    return ActivityRunner(
      stage: 1,
      activity: 2,
      initialTasks: tasks,
      onFinished: () => Navigator.of(context).maybePop(),
    );
  }
}
