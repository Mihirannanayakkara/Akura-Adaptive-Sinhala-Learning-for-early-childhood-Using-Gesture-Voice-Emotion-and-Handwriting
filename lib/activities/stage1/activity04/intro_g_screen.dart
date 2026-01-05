import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Stage1Activity04Intro extends StatefulWidget {
  final VoidCallback onDone;

  const Stage1Activity04Intro({super.key, required this.onDone});

  @override
  State<Stage1Activity04Intro> createState() => _Stage1Activity04IntroState();
}

enum _IntroMode { letter, singleCard, allCards }

class _IntroStep {
  final _IntroMode mode;

  final String? word;
  final String? emoji;

  // Placeholder audio path (add MP3 later)
  final String audio;

  const _IntroStep({
    required this.mode,
    required this.audio,
    this.word,
    this.emoji,
  });
}

class _Stage1Activity04IntroState extends State<Stage1Activity04Intro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  final AudioPlayer _p = AudioPlayer();

  int _index = 0;
  bool _fadeOut = false;
  bool _running = false;

  static const _words = <(String word, String emoji)>[
    ("ගස", "🌳"),
    ("ගමන", "🚶"),
    ("ගල", "🪨"),
    ("ගවයා", "🐄"),
  ];

  final _steps = const <_IntroStep>[
    _IntroStep(
      mode: _IntroMode.letter,
      audio: "audio/stage1/activity04/intro_letter_ga.mp3",
    ),
    _IntroStep(
      mode: _IntroMode.singleCard,
      word: "ගස",
      emoji: "🌳",
      audio: "audio/stage1/activity04/intro_tree_gasa.mp3",
    ),
    _IntroStep(
      mode: _IntroMode.singleCard,
      word: "ගමන",
      emoji: "🚶",
      audio: "audio/stage1/activity04/intro_river_ganga.mp3",
    ),
    _IntroStep(
      mode: _IntroMode.singleCard,
      word: "ගල",
      emoji: "🪨",
      audio: "audio/stage1/activity04/intro_stone_gala.mp3",
    ),
    _IntroStep(
      mode: _IntroMode.singleCard,
      word: "ගවයා",
      emoji: "🐄",
      audio: "audio/stage1/activity04/intro_cow_gawaya.mp3",
    ),
    _IntroStep(
      mode: _IntroMode.allCards,
      audio: "audio/stage1/activity04/intro_all.mp3",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    _c.dispose();
    _p.dispose();
    super.dispose();
  }

  Future<void> _play(String asset) async {
    try {
      await _p.stop();
      await _p.play(AssetSource(asset));
    } catch (_) {}
  }

  Future<void> _run() async {
    if (_running) return;
    _running = true;

    for (int i = 0; i < _steps.length; i++) {
      if (!mounted) return;

      setState(() {
        _index = i;
        _fadeOut = false;
      });

      await _play(_steps[i].audio);

      _c.reset();
      await _c.forward();

      final step = _steps[i];
      final hold = switch (step.mode) {
        _IntroMode.letter => const Duration(milliseconds: 2200),
        _IntroMode.singleCard => const Duration(milliseconds: 2600),
        _IntroMode.allCards => const Duration(milliseconds: 2200),
      };

      await Future.delayed(hold);
      if (!mounted) return;

      if (i != _steps.length - 1) {
        setState(() => _fadeOut = true);
        await Future.delayed(const Duration(milliseconds: 180));
      }
    }

    if (!mounted) return;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];

    return Container(
      color: const Color(0xFFF7F8FA),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 6,
              right: 10,
              child: TextButton(
                onPressed: widget.onDone,
                child: const Text(
                  "Skip",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: _fadeOut ? 0 : 1,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _fade.value,
                      child: Transform.scale(
                        scale: 0.85 + 0.15 * _scale.value,
                        child: _buildStep(step),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(_IntroStep step) {
    switch (step.mode) {
      case _IntroMode.letter:
        return const _LetterCard(letter: "ග");
      case _IntroMode.singleCard:
        return _WordCard(word: step.word!, emoji: step.emoji!);
      case _IntroMode.allCards:
        return const _AllCardsGrid(items: _words, letter: "ග");
    }
  }
}

class _LetterCard extends StatelessWidget {
  final String letter;
  const _LetterCard({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 160,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final String word;
  final String emoji;

  const _WordCard({required this.word, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 86)),
          const SizedBox(height: 10),
          Text(
            word,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllCardsGrid extends StatelessWidget {
  final List<(String word, String emoji)> items;
  final String letter;

  const _AllCardsGrid({required this.items, required this.letter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.black.withOpacity(0.08), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 170,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            physics: const NeverScrollableScrollPhysics(),
            children: items.map((it) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withOpacity(0.08), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(it.$2, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 6),
                    Text(
                      it.$1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
