import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/task.dart';

class ContentRepository {
  Future<List<Task>> loadTasks({required int stage, required int activity}) async {
    final tasks = <Task>[];
    for (int i = 1; i <= 10; i++) {
      final path =
          'assets/content/stage$stage/activity${activity.toString().padLeft(2, '0')}/task${i.toString().padLeft(2, '0')}.json';
      final raw = await rootBundle.loadString(path);
      tasks.add(Task.fromJson(jsonDecode(raw)));
    }
    return tasks;
  }
}
