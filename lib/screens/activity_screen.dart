import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/content_repository.dart';
import '../state/app_state.dart';

class ActivityScreen extends StatefulWidget {
  final int stage;
  final int activity;

  const ActivityScreen({super.key, required this.stage, required this.activity});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final repo = ContentRepository();
  late Future<List<Task>> future;
  int index = 0;

  @override
  void initState() {
    super.initState();
    future = repo.loadTasks(stage: widget.stage, activity: widget.activity);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Stage ${widget.stage} • Activity ${widget.activity}"),
        actions: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red),
              const SizedBox(width: 6),
              Text("${app.hearts}", style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 14),
            ],
          )
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snap.data!;
          final t = tasks[index];
          final progress = (index + 1) / tasks.length;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 18),
                Text(
                  t.prompt,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(t.options.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: FilledButton(
                            onPressed: () => _answer(context, app, tasks, i),
                            child: Text(t.options[i], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Text(
                  "Task ${index + 1} / ${tasks.length}",
                  style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  void _answer(BuildContext context, AppState app, List<Task> tasks, int picked) async {
    final t = tasks[index];
    final correct = picked == t.answerIndex;

    if (!correct) {
      app.spendHeart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Oops! -1 heart"), duration: Duration(milliseconds: 600)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nice!"), duration: Duration(milliseconds: 450)),
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (index == tasks.length - 1) {
      app.completeActivity(widget.stage, widget.activity);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Activity complete!"),
          content: const Text("Great job. Next activity is unlocked (if available)."),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Back to Home"),
            )
          ],
        ),
      );
      return;
    }

    setState(() => index++);
  }
}
