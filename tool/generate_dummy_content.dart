import 'dart:convert';
import 'dart:io';

void main() async {
  final root = Directory('assets/content');
  if (!root.existsSync()) root.createSync(recursive: true);

  for (int stage = 1; stage <= 3; stage++) {
    for (int activity = 1; activity <= 10; activity++) {
      final actDir = Directory(
        'assets/content/stage$stage/activity${activity.toString().padLeft(2, '0')}',
      );
      actDir.createSync(recursive: true);

      for (int task = 1; task <= 10; task++) {
        final file = File(
          '${actDir.path}/task${task.toString().padLeft(2, '0')}.json',
        );

        final taskObj = _makeDummyTask(stage, activity, task);
        file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(taskObj));
      }
    }
  }

  stdout.writeln('✅ Dummy content generated under assets/content/');
}

Map<String, dynamic> _makeDummyTask(int stage, int activity, int task) {
  // Simple 3-option MCQ schema you can replace later without breaking the app.
  // You can add fields like image/audio later (e.g., "imageAsset", "audioAsset").
  if (stage == 1) {
    final letters = ['අ', 'ආ', 'ඉ', 'ඊ', 'උ', 'ඌ', 'එ', 'ඒ', 'ඔ', 'ඕ'];
    final correct = letters[(task - 1) % letters.length];
    final options = _rotate3([correct, 'අ', 'ඉ', 'උ', 'එ', 'ඔ'], task);
    final answerIndex = options.indexOf(correct);

    return {
      "id": "s$stage-a$activity-t$task",
      "prompt": "Tap the letter: $correct",
      "options": options,
      "answerIndex": answerIndex,
    };
  }

  if (stage == 2) {
    final items = [
      ["mother", "අම්මා"],
      ["father", "තාත්තා"],
      ["home", "ගෙදර"],
      ["book", "පොත"],
      ["water", "වතුර"],
    ];
    final pair = items[(task - 1) % items.length];
    final correct = pair[1];
    final options = _rotate3([correct, "අම්මා", "තාත්තා", "පොත", "වතුර", "ගෙදර"], task);
    final answerIndex = options.indexOf(correct);

    return {
      "id": "s$stage-a$activity-t$task",
      "prompt": "Select the Sinhala word for: ${pair[0]}",
      "options": options,
      "answerIndex": answerIndex,
    };
  }

  // stage 3
  final sentences = [
    {
      "prompt": "Choose the correct word: මම ____ යනවා.",
      "correct": "ගෙදර",
      "options": ["ගෙදර", "පොත", "වතුර"]
    },
    {
      "prompt": "Choose the correct word: මේක ____ එකක්.",
      "correct": "පොත",
      "options": ["වතුර", "පොත", "ගෙදර"]
    },
    {
      "prompt": "Choose the correct word: මට ____ ඕනේ.",
      "correct": "වතුර",
      "options": ["වතුර", "තාත්තා", "ගෙදර"]
    },
  ];
  final item = sentences[(task - 1) % sentences.length];

  return {
    "id": "s$stage-a$activity-t$task",
    "prompt": item["prompt"],
    "options": item["options"],
    "answerIndex": (item["options"] as List).indexOf(item["correct"]),
  };
}

List<String> _rotate3(List<String> pool, int seed) {
  // pick 3 options deterministically but “mixed”
  final start = seed % (pool.length - 2);
  final out = pool.sublist(start, start + 3).toList();
  // ensure unique
  return out.toSet().toList().take(3).toList();
}
