import 'package:flutter/material.dart';

import '../../common/activity_runner.dart';
import '../../common/task_registry.dart';
import '../../common/task_scaffold.dart';

import 'intro_colors_screen.dart';
import 'task01_select_red.dart';
import 'task02_select_yellow.dart';
import 'task03_select_green.dart';
import 'task04_select_blue.dart';
import 'task05_catch_red_butterflies.dart';
import 'task06_match_words_to_colors.dart';

class Stage1Activity03Screen extends StatefulWidget {
  const Stage1Activity03Screen({super.key});

  @override
  State<Stage1Activity03Screen> createState() => _Stage1Activity03ScreenState();
}

class _Stage1Activity03ScreenState extends State<Stage1Activity03Screen> {
  bool _introDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_introDone) {
      return TaskScaffold(
        progress: 0.0,
        onExit: () => Navigator.of(context).maybePop(),
        child: Stage1Activity03Intro(
          onDone: () {
            if (!mounted) return;
            setState(() => _introDone = true);
          },
        ),
      );
    }

    final tasks = <TaskEntry>[
      TaskEntry(id: "s1a3_t1", builder: (ctx, cb) => S1A3Task01SelectRed(callbacks: cb)),
      TaskEntry(id: "s1a3_t2", builder: (ctx, cb) => S1A3Task02SelectYellow(callbacks: cb)),
      TaskEntry(id: "s1a3_t3", builder: (ctx, cb) => S1A3Task03SelectGreen(callbacks: cb)),
      TaskEntry(id: "s1a3_t4", builder: (ctx, cb) => S1A3Task04SelectBlue(callbacks: cb)),
      TaskEntry(id: "s1a3_t5", builder: (ctx, cb) => S1A3Task05CatchRedButterflies(callbacks: cb)),
      TaskEntry(id: "s1a3_t6", builder: (ctx, cb) => S1A3Task06MatchWordsToColors(callbacks: cb)),
    ];

    return ActivityRunner(
      stage: 1,
      activity: 3,
      initialTasks: tasks,
      onFinished: () => Navigator.of(context).maybePop(),
    );
  }
}
