class StageProgress {
  final Set<int> unlocked;  // activity numbers 1..10
  final Set<int> completed; // activity numbers 1..10

  StageProgress({Set<int>? unlocked, Set<int>? completed})
      : unlocked = unlocked ?? <int>{},
        completed = completed ?? <int>{};

  Map<String, dynamic> toJson() => {
        "unlocked": unlocked.toList()..sort(),
        "completed": completed.toList()..sort(),
      };

  static StageProgress fromJson(Map<String, dynamic> json) => StageProgress(
        unlocked: (json["unlocked"] as List).map((e) => e as int).toSet(),
        completed: (json["completed"] as List).map((e) => e as int).toSet(),
      );
}
