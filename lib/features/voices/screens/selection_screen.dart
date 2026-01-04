import 'package:flutter/material.dart';
import 'lesson_data.dart';
import 'practice_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Choose a Letter", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: lessonData.length,
            itemBuilder: (context, index) {
              final item = lessonData[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      pageBuilder: (_, __, ___) => PracticeScreen(lessonItem: item),
                    ),
                  );
                },
                child: Hero(
                  tag: item.letter, // Unique tag for animation
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: item.color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: item.color.withOpacity(0.2), shape: BoxShape.circle),
                            child: Text(
                              item.letter,
                              style: TextStyle(fontSize: 60, fontFamily: 'Iskoola Pota', fontWeight: FontWeight.bold, color: item.color),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.word,
                            style: const TextStyle(fontSize: 18, fontFamily: 'Iskoola Pota', fontWeight: FontWeight.w600, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}