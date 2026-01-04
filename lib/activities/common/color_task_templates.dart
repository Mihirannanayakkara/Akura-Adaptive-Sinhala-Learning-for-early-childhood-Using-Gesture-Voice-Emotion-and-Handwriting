import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'task_registry.dart';
import 'task_templates.dart'; // for AkFeedbackBar

class AkColorCircleOption {
  final String label; // e.g., "රතු"
  final Color color;
  final bool isCorrect;

  const AkColorCircleOption({
    required this.label,
    required this.color,
    required this.isCorrect,
  });
}

class AkColorMatchPair {
  final String word; // e.g., "රතු"
  final Color color;

  const AkColorMatchPair({required this.word, required this.color});
}

class AkAudioButton extends StatefulWidget {
  final String assetPath; // relative to assets/ (e.g. audio/...)
  final IconData icon;

  const AkAudioButton({
    super.key,
    required this.assetPath,
    this.icon = Icons.mic,
  });

  @override
  State<AkAudioButton> createState() => _AkAudioButtonState();
}

class _AkAudioButtonState extends State<AkAudioButton> {
  final AudioPlayer _p = AudioPlayer();

  @override
  void dispose() {
    _p.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    try {
      await _p.stop();
      await _p.play(AssetSource(widget.assetPath));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Audio file not found yet 🎧")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _play,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF1FB6FF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Icon(widget.icon, color: Colors.white, size: 34),
      ),
    );
  }
}

class AkSelectColorCircleTask extends StatefulWidget {
  final String prompt;
  final String audioAsset;
  final List<AkColorCircleOption> options;
  final TaskCallbacks callbacks;

  const AkSelectColorCircleTask({
    super.key,
    required this.prompt,
    required this.audioAsset,
    required this.options,
    required this.callbacks,
  });

  @override
  State<AkSelectColorCircleTask> createState() => _AkSelectColorCircleTaskState();
}

class _AkSelectColorCircleTaskState extends State<AkSelectColorCircleTask> {
  late final List<AkColorCircleOption> _opts;

  int? selectedIndex;
  bool checked = false;
  bool ok = false;

  @override
  void initState() {
    super.initState();
    _opts = List.of(widget.options);
    _opts.shuffle(math.Random());
  }

  void _check() {
    if (checked) return;
    if (selectedIndex == null) return;

    final picked = _opts[selectedIndex!];
    final correct = picked.isCorrect;

    setState(() {
      checked = true;
      ok = correct;
    });

    if (!correct) widget.callbacks.onMistake();
  }

  @override
  Widget build(BuildContext context) {
    final correctLabel = _opts.firstWhere((o) => o.isCorrect).label;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.prompt,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Center(
                child: AkAudioButton(assetPath: widget.audioAsset, icon: Icons.mic),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 1.0,
                  children: List.generate(_opts.length, (i) {
                    final opt = _opts[i];
                    final isSelected = selectedIndex == i;

                    Color border = Colors.black.withOpacity(0.10);
                    Color fill = Colors.white;

                    if (isSelected) {
                      border = Colors.black.withOpacity(0.35);
                    }

                    if (checked) {
                      if (opt.isCorrect) border = const Color(0xFF25C15A);
                      if (isSelected && !opt.isCorrect) border = const Color(0xFFD32F2F);
                    }

                    return InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: checked
                          ? null
                          : () {
                              setState(() => selectedIndex = i);
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: fill,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: border, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: opt.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF25C15A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: (!checked && selectedIndex != null) ? _check : null,
                  child: const Text(
                    "CHECK",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
        AkFeedbackBar(
          visible: checked,
          correct: ok,
          title: ok ? "Amazing!" : "Oops!",
          subtitle: ok ? null : "Correct: $correctLabel",
          onContinue: () {
            widget.callbacks.onComplete(shouldRepeat: !ok);
          },
        ),
      ],
    );
  }
}

class AkButterflyCatchTask extends StatefulWidget {
  final String prompt;
  final String audioAsset;
  final Color targetColor;
  final String targetLabel;
  final int targetCount;
  final double targetProbability;
  final List<Color> otherColors;
  final TaskCallbacks callbacks;

  const AkButterflyCatchTask({
    super.key,
    required this.prompt,
    required this.audioAsset,
    required this.targetColor,
    required this.targetLabel,
    required this.targetCount,
    required this.targetProbability,
    required this.otherColors,
    required this.callbacks,
  });

  @override
  State<AkButterflyCatchTask> createState() => _AkButterflyCatchTaskState();
}

class _AkButterflyCatchTaskState extends State<AkButterflyCatchTask>
    with TickerProviderStateMixin {
  final _rng = math.Random();
  final List<_Butterfly> _items = [];
  Timer? _spawnTimer;

  int _hit = 0;
  bool _done = false;
  bool _hadMistake = false;

  @override
  void initState() {
    super.initState();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 520), (_) {
      if (!mounted || _done) return;
      _spawn();
    });
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    for (final b in _items) {
      b.controller.dispose();
    }
    super.dispose();
  }

  void _spawn() {
    final isTarget = _rng.nextDouble() < widget.targetProbability;
    final color = isTarget
        ? widget.targetColor
        : widget.otherColors[_rng.nextInt(widget.otherColors.length)];

    final x = _rng.nextDouble().clamp(0.08, 0.92);

    final c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2600 + _rng.nextInt(1200)),
    );

    final id = _rng.nextInt(1 << 31);
    final item = _Butterfly(id: id, x: x, color: color, controller: c);

    setState(() {
      _items.add(item);
    });

    c.addStatusListener((st) {
      if (st == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          _items.removeWhere((b) => b.id == id);
        });
        c.dispose();
      }
    });

    c.forward();
  }

  void _tap(_Butterfly b) {
    if (_done) return;

    final correct = b.color.value == widget.targetColor.value;
    if (!correct) {
      _hadMistake = true;
      widget.callbacks.onMistake();
    } else {
      _hit += 1;
    }

    setState(() {
      _items.removeWhere((x) => x.id == b.id);
    });
    b.controller.dispose();

    if (_hit >= widget.targetCount) {
      setState(() => _done = true);
      _spawnTimer?.cancel();
      _spawnTimer = null;
      for (final bb in _items) {
        bb.controller.stop();
        bb.controller.dispose();
      }
      _items.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cs) {
        final h = cs.maxHeight;
        final w = cs.maxWidth;

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.prompt,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      AkAudioButton(assetPath: widget.audioAsset, icon: Icons.mic),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          "Catch ${widget.targetCount} “${widget.targetLabel}” butterflies  ($_hit/${widget.targetCount})",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black.withOpacity(0.55),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Stack(
                      children: _items.map((b) {
                        return AnimatedBuilder(
                          animation: b.controller,
                          builder: (context, _) {
                            final t = b.controller.value;
                            final y = (h - 220) - t * (h - 60);
                            final x = b.x * w;

                            return Positioned(
                              left: x - 42,
                              top: y,
                              child: GestureDetector(
                                onTap: () => _tap(b),
                                child: _ButterflyView(color: b.color),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            AkFeedbackBar(
              visible: _done,
              correct: !_hadMistake,
              title: !_hadMistake ? "Amazing!" : "Good try!",
              subtitle: _hadMistake ? "You’ll see this again later." : null,
              onContinue: () {
                widget.callbacks.onComplete(shouldRepeat: _hadMistake);
              },
            ),
          ],
        );
      },
    );
  }
}

class _Butterfly {
  final int id;
  final double x;
  final Color color;
  final AnimationController controller;

  _Butterfly({
    required this.id,
    required this.x,
    required this.color,
    required this.controller,
  });
}

class _ButterflyView extends StatelessWidget {
  final Color color;

  const _ButterflyView({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: color.withOpacity(0.20),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.9), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Center(
        child: Text(
          "🦋",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: color),
        ),
      ),
    );
  }
}

class AkMatchWordsToColorsTask extends StatefulWidget {
  final String prompt;
  final String audioAsset;
  final List<AkColorMatchPair> pairs;
  final TaskCallbacks callbacks;

  const AkMatchWordsToColorsTask({
    super.key,
    required this.prompt,
    required this.audioAsset,
    required this.pairs,
    required this.callbacks,
  });

  @override
  State<AkMatchWordsToColorsTask> createState() => _AkMatchWordsToColorsTaskState();
}

class _AkMatchWordsToColorsTaskState extends State<AkMatchWordsToColorsTask> {
  late final List<AkColorMatchPair> targets;
  late final List<AkColorMatchPair> pool;

  final Map<int, String> placedWordForColor = {}; // color.value -> word
  bool hadMistake = false;
  bool done = false;

  @override
  void initState() {
    super.initState();
    targets = List.of(widget.pairs)..shuffle(math.Random());
    pool = List.of(widget.pairs)..shuffle(math.Random());
  }

  bool get allMatched => placedWordForColor.length == targets.length;

  void _place({required AkColorMatchPair target, required AkColorMatchPair dragged}) {
    if (done) return;

    if (dragged.word == target.word) {
      setState(() {
        placedWordForColor[target.color.value] = dragged.word;
        pool.removeWhere((p) => p.word == dragged.word);
        if (allMatched) done = true;
      });
    } else {
      hadMistake = true;
      widget.callbacks.onMistake();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not that one 🙂")),
      );
    }
  }

  Color _wordColor(Color c) {
    if (c == Colors.yellow) return const Color.fromARGB(255, 255, 235, 80);
    return c;
  }

  Color _textOn(Color bg) {
    if (bg == Colors.yellow) return Colors.black;
    if (bg.computeLuminance() > 0.65) return Colors.black;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.prompt,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              AkAudioButton(assetPath: widget.audioAsset, icon: Icons.mic),
              const SizedBox(height: 14),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text("Words",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.black.withOpacity(0.55),
                              )),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: pool.map((p) {
                                return Draggable<AkColorMatchPair>(
                                  data: p,
                                  feedback: _WordChip(
                                    text: p.word,
                                    color: _wordColor(p.color),
                                    elevated: true,
                                  ),
                                  childWhenDragging: _WordChip(
                                    text: p.word,
                                    color: _wordColor(p.color),
                                    dim: true,
                                  ),
                                  child: _WordChip(
                                    text: p.word,
                                    color: _wordColor(p.color),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        children: [
                          Text("Colors",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.black.withOpacity(0.55),
                              )),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.separated(
                              itemCount: targets.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final t = targets[i];
                                final placed = placedWordForColor[t.color.value];

                                return DragTarget<AkColorMatchPair>(
                                  onWillAccept: (_) => !done,
                                  onAccept: (dragged) => _place(target: t, dragged: dragged),
                                  builder: (context, candidate, rejected) {
                                    final highlight = candidate.isNotEmpty;

                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: highlight
                                              ? const Color(0xFF25C15A)
                                              : Colors.black.withOpacity(0.10),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 8),
                                          )
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: t.color,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.black.withOpacity(0.10),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              placed ?? "Drop word here",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                                color: placed != null
                                                    ? _wordColor(t.color)
                                                    : Colors.black.withOpacity(0.35),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AkFeedbackBar(
          visible: done,
          correct: !hadMistake,
          title: !hadMistake ? "Amazing!" : "Good try!",
          subtitle: hadMistake ? "You’ll see this again later." : null,
          onContinue: () {
            widget.callbacks.onComplete(shouldRepeat: hadMistake);
          },
        ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  final String text;
  final Color color;
  final bool dim;
  final bool elevated;

  const _WordChip({
    required this.text,
    required this.color,
    this.dim = false,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevated ? 8 : 0,
      borderRadius: BorderRadius.circular(16),
      color: dim ? Colors.grey.shade200 : Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.12), width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: dim ? Colors.black.withOpacity(0.25) : color,
          ),
        ),
      ),
    );
  }
}
