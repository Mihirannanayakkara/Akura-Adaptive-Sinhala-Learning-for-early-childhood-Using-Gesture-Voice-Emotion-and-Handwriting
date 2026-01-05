import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/curvy_activity_map.dart';
import '../widgets/decorated_curvy_activity_map.dart'; // ✅ NEW
import 'activity_screen.dart';

// Stage 1 custom activities
import '../activities/stage1/activity01/activity01_screen.dart';
import '../activities/stage1/activity02/activity02_screen.dart';
import '../activities/stage1/activity03/activity03_screen.dart';
import '../activities/stage1/activity04/activity04_screen.dart';
import '../activities/stage1/activity05/activity05_screen.dart';
import '../activities/stage1/activity06/activity06_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatMMSS(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return "${m}m ${s.toString().padLeft(2, '0')}s";
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final stage = app.selectedStage;

    final statuses = List<ActivityStatus>.generate(10, (i) {
      final activity = i + 1;
      if (app.isCompleted(stage, activity)) return ActivityStatus.completed;
      if (app.isUnlocked(stage, activity)) return ActivityStatus.unlocked;
      return ActivityStatus.locked;
    });

    final nextHeartIn = app.timeUntilNextHeart();

    return Scaffold(
      backgroundColor: const Color(0xFFF5EEF8),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        "${app.hearts}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  // if (app.hearts < AppState.maxHearts)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 4),
                  //     child: Text(
                  //       "Next in ${_formatMMSS(nextHeartIn)}",
                  //       style: TextStyle(
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w600,
                  //         color: Colors.grey.shade700,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 52),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _StageHeader(stage: stage),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: DecoratedCurvyActivityMap(
                        count: 10,
                        status: statuses,
                        nodeSize: 78,
                        verticalSpacing: 120,
                        amplitudeFactor: 0.32,
                        waves: 1,

                        // ✅ stickers (Lottie json assets)
                        elephantAsset: 'assets/stickers/baby_elephant.json',
                        deerAsset: 'assets/stickers/baby_deer.json',

                        onTap: (index) {
                          final activity = index + 1;

                          if (!app.isUnlocked(stage, activity)) return;

                          if (!app.canStartActivity(stage, activity)) {
                            final wait = app.timeUntilNextHeart();
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Out of hearts"),
                                content: Text(
                                  "You can start the next activity in ${_formatMMSS(wait)}.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("OK"),
                                  )
                                ],
                              ),
                            );
                            return;
                          }

                          if (stage == 1 && activity == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Stage1Activity01Screen(),
                              ),
                            );
                            return;
                          }

                          if (stage == 1 && activity == 2) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Stage1Activity02Screen(),
                              ),
                            );
                            return;
                          }

                          if (stage == 1 && activity == 3) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Stage1Activity03Screen(),
                              ),
                            );
                            return;
                          }

                          if (stage == 1 && activity == 4) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Stage1Activity04Screen(),
                              ),
                            );
                            return;
                          }

                          if (stage == 1 && activity == 5) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Stage1Activity05Screen()),
                            );
                            return;
                          }

                          if (stage == 1 && activity == 6) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Stage1Activity06Screen()),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActivityScreen(
                                stage: stage,
                                activity: activity,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: "Awards"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class _StageHeader extends StatelessWidget {
  final int stage;
  const _StageHeader({required this.stage});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Select Stage",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  for (int s = 1; s <= 3; s++)
                    ListTile(
                      enabled: app.canOpenStage(s),
                      leading: Icon(
                        Icons.flag,
                        color: app.canOpenStage(s) ? Colors.green : Colors.grey,
                      ),
                      title: Text("Stage $s"),
                      subtitle: !app.canOpenStage(s)
                          ? const Text("Locked (based on child age)")
                          : null,
                      trailing:
                          s == app.selectedStage ? const Icon(Icons.check) : null,
                      onTap: app.canOpenStage(s)
                          ? () {
                              app.setSelectedStage(s);
                              Navigator.pop(context);
                            }
                          : null,
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.lightGreenAccent.shade400,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "Stage $stage",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Spacer(),
            Container(
              width: 1,
              height: 50,
              color: Colors.white.withOpacity(0.25),
            ),
            IconButton(
              icon: const Icon(Icons.list, color: Colors.white),
              onPressed: () {},
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
