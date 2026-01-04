import 'package:flutter/material.dart';

class TaskScaffold extends StatelessWidget {
  final double progress; // 0..1
  final VoidCallback onExit;
  final Widget child;

  /// ✅ Reserve width on the right side of the header row
  /// so overlays (like the camera bubble) don't cover the progress bar.
  final double topRightGutter;

  const TaskScaffold({
    super.key,
    required this.progress,
    required this.onExit,
    required this.child,
    this.topRightGutter = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onExit,
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.black.withOpacity(0.08),
                      ),
                    ),
                  ),

                  // ✅ keeps the right side free for the camera bubble
                  SizedBox(width: 12 + topRightGutter),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
