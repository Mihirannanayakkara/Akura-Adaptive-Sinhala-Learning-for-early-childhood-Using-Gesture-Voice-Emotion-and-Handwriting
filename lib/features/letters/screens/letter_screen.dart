import 'package:flutter/material.dart';
import '../models/letter_spec.dart';
import '../widgets/letter_canvas.dart';

class LetterScreen extends StatefulWidget {
  final LetterSpec spec;
  final bool startPractice;
  const LetterScreen({super.key, required this.spec, this.startPractice = false});
  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  late final LetterCanvasController _controller;
  @override
  void initState() {
    super.initState();
    _controller = LetterCanvasController();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          '${widget.spec.title} - ${widget.startPractice ? 'Practice' : 'Learn'}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007AFF)),
        actions: [
          IconButton(
            onPressed: _controller.clear,
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFF007AFF),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Instruction card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.startPractice ? 'Practice Mode' : 'Learning Mode',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.startPractice
                          ? 'Trace the letter freely to practice'
                          : 'Follow the strokes in order',
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFF3C3C43).withValues(alpha: 0.6),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Canvas area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: LetterPage(
                    spec: widget.spec,
                    controller: _controller,
                    startPractice: widget.startPractice,
                    onPassedToPractice: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LetterScreen(
                            spec: widget.spec,
                            startPractice: true,
                          ),
                        ),
                      );
                    },
                    onNextLetter: () {
                      final sequence = [letterU, letterTa, letterPa, letterGa, letterKa];
                      final i = sequence.indexWhere((s) => s.title == widget.spec.title);
                      final next = i >= 0 ? sequence[(i + 1) % sequence.length] : sequence.first;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => LetterScreen(
                            spec: next,
                            startPractice: false,
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
      ),
    );
  }
}

