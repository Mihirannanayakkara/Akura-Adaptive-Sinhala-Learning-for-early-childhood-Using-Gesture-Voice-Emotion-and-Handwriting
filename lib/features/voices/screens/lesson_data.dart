// Dart
import 'package:flutter/material.dart';

class LessonItem {
  final String letter;
  final String word;
  final String englishMeaning;
  final String imagePath;
  final Color color;

  const LessonItem({
    required this.letter,
    required this.word,
    required this.englishMeaning,
    required this.imagePath,
    required this.color,
  });
}

final List<LessonItem> lessonData = [
  LessonItem(letter: "අ", word: "අම්මා", englishMeaning: "Mother", imagePath: 'assets/images/mother.png', color: Colors.pinkAccent),
  LessonItem(letter: "ආ", word: "ආකාසය", englishMeaning: "Sky", imagePath: 'assets/images/sky.png', color: Colors.lightBlue),
  LessonItem(letter: "ක", word: "කපුටා", englishMeaning: "Crow", imagePath: 'assets/images/crow.png', color: Colors.grey),
  LessonItem(letter: "ග", word: "ගෙදර", englishMeaning: "Home", imagePath: 'assets/images/home.png', color: Colors.green),
  LessonItem(letter: "ඉ", word: "ඉර", englishMeaning: "Sun", imagePath: 'assets/images/sun.png', color: Colors.orange),

  // Newly added
  LessonItem(letter: "ඇ", word: "ඇපල්", englishMeaning: "Apple", imagePath: 'assets/images/apple.png', color: Colors.redAccent),
  LessonItem(letter: "ඌ", word: "ඌරා", englishMeaning: "Pig", imagePath: 'assets/images/pig.png', color: Colors.pink),
  LessonItem(letter: "කු", word: "කුකුළා", englishMeaning: "Rooster", imagePath: 'assets/images/rooster.png', color: Colors.deepOrange),
  LessonItem(letter: "පූ", word: "පූසා", englishMeaning: "Cat", imagePath: 'assets/images/cat.png', color: Colors.indigo),
  LessonItem(letter: "ඔ", word: "ඔටුවා", englishMeaning: "Duck", imagePath: 'assets/images/duck.png', color: Colors.teal),
];
