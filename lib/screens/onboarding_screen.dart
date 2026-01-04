import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int age = 3;
  String gender = "other";

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Child Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text("Select child's age", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: age,
              items: [3, 4, 5, 6, 7]
                  .map((a) => DropdownMenuItem(value: a, child: Text("$a years old")))
                  .toList(),
              onChanged: (v) => setState(() => age = v ?? 3),
            ),
            const SizedBox(height: 16),
            const Text("Gender (optional)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: "boy", label: Text("Boy")),
                ButtonSegment(value: "girl", label: Text("Girl")),
                ButtonSegment(value: "other", label: Text("Other")),
              ],
              selected: {gender},
              onSelectionChanged: (s) => setState(() => gender = s.first),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                app.setProfile(age: age, gender: gender);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Text("Continue"),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
