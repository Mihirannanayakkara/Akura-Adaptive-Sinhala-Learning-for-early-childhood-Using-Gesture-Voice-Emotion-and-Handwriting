class Task {
  final String id;
  final String prompt;
  final List<String> options;
  final int answerIndex;

  const Task({
    required this.id,
    required this.prompt,
    required this.options,
    required this.answerIndex,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        prompt: json["prompt"],
        options: List<String>.from(json["options"]),
        answerIndex: json["answerIndex"],
      );
}
