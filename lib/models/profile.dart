class ChildProfile {
  final int age; // 3..7
  final String gender; // "boy" | "girl" | "other"

  const ChildProfile({required this.age, required this.gender});

  int get assignedStage {
    if (age <= 3) return 1;
    if (age <= 5) return 2;
    return 3;
  }

  Map<String, dynamic> toJson() => {"age": age, "gender": gender};

  static ChildProfile fromJson(Map<String, dynamic> json) =>
      ChildProfile(age: json["age"], gender: json["gender"]);
}
