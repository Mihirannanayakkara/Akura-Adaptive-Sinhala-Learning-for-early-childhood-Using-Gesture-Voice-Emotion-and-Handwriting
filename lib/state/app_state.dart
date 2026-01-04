import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../models/progress.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage;

  ChildProfile? profile;

  int selectedStage = 1;

  final Map<int, StageProgress> progress = {
    1: StageProgress(),
    2: StageProgress(),
    3: StageProgress(),
  };

  static const int maxHearts = 10;
  int hearts = maxHearts;

  DateTime lastRefillTick = DateTime.now();

  Timer? _timer;

  AppState(this._storage);

  bool get hasProfile => profile != null;
  int get assignedStage => profile?.assignedStage ?? 1;

  Future<void> init() async {
    final saved = await _storage.loadState();
    if (saved != null) {
      _fromJson(saved);
    }
    _applyAutoRefill();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _applyAutoRefill();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setProfile({required int age, required String gender}) {
    profile = ChildProfile(age: age, gender: gender);

    // initial unlock rules
    progress[1]!.unlocked.add(1);
    if (assignedStage >= 2) progress[2]!.unlocked.add(1);
    if (assignedStage >= 3) progress[3]!.unlocked.add(1);

    selectedStage = 1;
    hearts = maxHearts;
    lastRefillTick = DateTime.now();

    _save();
    notifyListeners();
  }

  bool isUnlocked(int stage, int activity) => progress[stage]!.unlocked.contains(activity);
  bool isCompleted(int stage, int activity) => progress[stage]!.completed.contains(activity);

  bool canOpenStage(int stage) => stage <= assignedStage;

  bool canStartActivity(int stage, int activity) {
    if (!isUnlocked(stage, activity)) return false;
    if (hearts <= 0) return false;
    return true;
  }

  void completeActivity(int stage, int activity) {
    progress[stage]!.completed.add(activity);

    final next = activity + 1;
    if (next <= 10) {
      progress[stage]!.unlocked.add(next);
    }
    _save();
    notifyListeners();
  }

  void spendHeart() {
    if (hearts <= 0) return;

    final wasFull = hearts == maxHearts;
    hearts = (hearts - 1).clamp(0, maxHearts);

    // Start refill timer when we first drop below full
    if (wasFull && hearts < maxHearts) {
      lastRefillTick = DateTime.now();
    }

    _save();
    notifyListeners();
  }

  Duration timeUntilNextHeart() {
    if (hearts >= maxHearts) return Duration.zero;
    final elapsed = DateTime.now().difference(lastRefillTick);
    final mod = elapsed.inSeconds % (10 * 60);
    final remaining = (10 * 60) - mod;
    return Duration(seconds: remaining);
  }

  void setSelectedStage(int stage) {
    if (!canOpenStage(stage)) return;
    selectedStage = stage;
    notifyListeners();
  }

  void _applyAutoRefill() {
    if (hearts >= maxHearts) return;

    final now = DateTime.now();
    final elapsed = now.difference(lastRefillTick);
    final add = elapsed.inMinutes ~/ 10;

    if (add <= 0) return;

    hearts = (hearts + add).clamp(0, maxHearts);

    // move tick forward by the amount actually used
    lastRefillTick = lastRefillTick.add(Duration(minutes: add * 10));

    // if full, stop the “counting” effectively
    if (hearts >= maxHearts) {
      lastRefillTick = now;
    }

    _save();
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.saveState(_toJson());
  }

  Map<String, dynamic> _toJson() => {
        "profile": profile?.toJson(),
        "selectedStage": selectedStage,
        "hearts": hearts,
        "lastRefillTick": lastRefillTick.toIso8601String(),
        "progress": {
          "1": progress[1]!.toJson(),
          "2": progress[2]!.toJson(),
          "3": progress[3]!.toJson(),
        },
      };

  void _fromJson(Map<String, dynamic> json) {
    final p = json["profile"];
    profile = p == null ? null : ChildProfile.fromJson(Map<String, dynamic>.from(p));
    selectedStage = (json["selectedStage"] ?? 1) as int;
    hearts = (json["hearts"] ?? maxHearts) as int;
    lastRefillTick = DateTime.tryParse(json["lastRefillTick"] ?? '') ?? DateTime.now();

    final pr = Map<String, dynamic>.from(json["progress"] ?? {});
    if (pr.isNotEmpty) {
      progress[1] = StageProgress.fromJson(Map<String, dynamic>.from(pr["1"]));
      progress[2] = StageProgress.fromJson(Map<String, dynamic>.from(pr["2"]));
      progress[3] = StageProgress.fromJson(Map<String, dynamic>.from(pr["3"]));
    }
  }
}
