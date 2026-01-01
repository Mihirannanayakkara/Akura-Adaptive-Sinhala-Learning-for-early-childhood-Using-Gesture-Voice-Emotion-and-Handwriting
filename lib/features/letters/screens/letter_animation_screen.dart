import 'package:flutter/material.dart';
import '../models/letter_spec.dart';
import '../widgets/letter_animation.dart';
import 'letter_screen.dart';

class LetterAnimationScreen extends StatelessWidget {
  final LetterSpec spec;

  const LetterAnimationScreen({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<LetterAnimationState> animationKey =
        GlobalKey<LetterAnimationState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          '${spec.title} – Watch',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007AFF)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            /// 🔹 Instruction + Restart
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Watch how to write the letter.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Restart animation',
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFF007AFF),
                    ),
                    onPressed: () {
                      animationKey.currentState?.restart();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 Animation Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SizedBox(
                    child: LetterAnimation(
                      key: animationKey,
                      jsonAsset: spec.jsonAsset!,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 Start Practice Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => LetterScreen(spec: spec),
                      ),
                    );
                  },
                  child: const Text(
                    'Start Practice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
