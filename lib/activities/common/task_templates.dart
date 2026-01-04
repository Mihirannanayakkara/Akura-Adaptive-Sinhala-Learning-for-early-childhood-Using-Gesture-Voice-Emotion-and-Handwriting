import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:emotion_app/activities/common/task_registry.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:emotion_app/services/emotion_adaptation.dart';

enum AkHelpDock { bottomLeft, topLeft }

// -------------------------------
// SAD option reduction helpers
// -------------------------------

List<T> akReduceOptionsForSad<T>({
  required List<T> items,
  required bool Function(T) isCorrect,
  math.Random? rng,
}) {
  final r = rng ?? math.Random();

  if (items.length <= 2) return List<T>.of(items);

  final correct = <T>[];
  final wrong = <T>[];

  for (final it in items) {
    if (isCorrect(it)) {
      correct.add(it);
    } else {
      wrong.add(it);
    }
  }

  // If we can't reduce meaningfully, keep as-is
  if (correct.isEmpty) return List<T>.of(items);
  if (wrong.length <= 1) return List<T>.of(items);

  // Keep ALL correct answers, and only ONE wrong answer
  final pickedWrong = wrong[r.nextInt(wrong.length)];
  final reduced = <T>[...correct, pickedWrong];

  // Shuffle so the correct answer isn't “obviously the left one”
  reduced.shuffle(r);
  return reduced;
}

List<String> akReduceWordsForSad({
  required List<String> words,
  required Set<String> correctWords,
  math.Random? rng,
}) {
  return akReduceOptionsForSad<String>(
    items: words,
    isCorrect: (w) => correctWords.contains(w),
    rng: rng,
  );
}


class AkAngryHelpSpec {
  final String explanationText;

  /// Optional audio placeholder (you'll add later)
  final String? audioAsset;

  /// Robot sticker (PNG)
  final String robotAsset;

  /// Robot size
  final double robotBoxSize;

  /// How long robot "explains" BEFORE revealing
  final Duration explainDuration;

  /// How long to keep overlay AFTER reveal
  final Duration afterRevealDuration;

  // ✅ NEW: placement controls (per-task)
  /// Where the overlay should sit on screen (e.g., Alignment.centerLeft)
  final Alignment alignment;

  /// Extra padding from edges (or to push away from UI)
  final EdgeInsets margin;

  /// Optional pixel nudge after alignment+margin
  final Offset offset;

  const AkAngryHelpSpec({
    required this.explanationText,
    this.audioAsset,
    this.robotAsset = 'assets/characters/cute_robot.png',
    this.robotBoxSize = 140,
    this.explainDuration = const Duration(seconds: 15),
    this.afterRevealDuration = const Duration(seconds: 5),

    // Default keeps your current behavior-ish (bottom-left, lifted up)
    this.alignment = Alignment.bottomLeft,
    this.margin = const EdgeInsets.only(left: 12, bottom: 140),
    this.offset = Offset.zero,
  });

  Duration get totalVisible => explainDuration + afterRevealDuration;
}




class AkAngryHelpOverlay extends StatefulWidget {
  final TaskCallbacks callbacks;
  final AkAngryHelpSpec spec;

  /// This is provided by the task (it reveals/highlights the correct answer)
  final VoidCallback onRevealAnswer;

  /// Prevent NEW triggers if task already done/answered.
  /// IMPORTANT: overlay must still remain visible if it already started.
  final bool disabled;

  const AkAngryHelpOverlay({
    super.key,
    required this.callbacks,
    required this.spec,
    required this.onRevealAnswer,
    this.disabled = false,
  });

  @override
  State<AkAngryHelpOverlay> createState() => _AkAngryHelpOverlayState();
}

class _AkAngryHelpOverlayState extends State<AkAngryHelpOverlay> {
  final AudioPlayer _p = AudioPlayer();

  Timer? _revealTimer;
  Timer? _closeTimer;

  bool _visible = false;
  bool _didReveal = false;

  EmotionAdaptationController? get _ctrl => widget.callbacks.emotion;
  String? get _taskId => widget.callbacks.taskId;

  @override
  void initState() {
    super.initState();
    _ctrl?.addListener(_onEvent);
  }

  @override
  void didUpdateWidget(covariant AkAngryHelpOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.callbacks.emotion != widget.callbacks.emotion) {
      oldWidget.callbacks.emotion?.removeListener(_onEvent);
      widget.callbacks.emotion?.addListener(_onEvent);
    }
  }

  void _onEvent() {
    if (!mounted) return;

    // ✅ If task is already finished, do NOT start a new overlay.
    if (widget.disabled) return;

    final ev = _ctrl?.lastEvent;
    final id = _taskId;
    if (ev == null || id == null) return;

    if (ev.type == EmotionAdaptationType.angryHelp && ev.taskId == id) {
      if (_visible) return;

      setState(() {
        _visible = true;
        _didReveal = false;
      });

      // cancel old timers (safety)
      _revealTimer?.cancel();
      _closeTimer?.cancel();

      // ✅ Explain for 15s, then reveal
      _revealTimer = Timer(widget.spec.explainDuration, () {
        if (!mounted) return;
        _reveal();
      });

      // ✅ Total visible time = 20s (15 + 5), then close
      _closeTimer = Timer(widget.spec.totalVisible, () {
        if (!mounted) return;
        _close();
      });
    }
  }

  Future<void> _playAudio() async {
    final asset = widget.spec.audioAsset;
    if (asset == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Audio coming soon 🎧")),
      );
      return;
    }

    try {
      await _p.stop();
      await _p.play(AssetSource(asset));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't play audio (missing asset?)")),
      );
    }
  }

  void _reveal() {
    if (_didReveal) return;
    _didReveal = true;

    // ✅ Reveal correct answer (task handles green highlight)
    widget.onRevealAnswer();

    if (mounted) setState(() {});
  }

  void _close() {
    _revealTimer?.cancel();
    _revealTimer = null;

    _closeTimer?.cancel();
    _closeTimer = null;

    if (mounted) setState(() => _visible = false);
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _closeTimer?.cancel();
    _ctrl?.removeListener(_onEvent);
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CRITICAL: do NOT hide just because task became answered/done.
    if (!_visible) return const SizedBox.shrink();

    final maxW = MediaQuery.of(context).size.width;
    final robotSize = widget.spec.robotBoxSize;
    final bubbleW = math.min(320.0, maxW - (robotSize + 44));

    final text = _didReveal
        ? "✅ Here’s the correct answer!"
        : widget.spec.explanationText;


return Positioned.fill(
  child: SafeArea(
    child: Align(
      alignment: widget.spec.alignment,
      child: Padding(
        padding: widget.spec.margin,
        child: Transform.translate(
          offset: widget.spec.offset,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW - 24),
            child: Material(
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Robot
                  Container(
                    width: robotSize,
                    height: robotSize,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.10), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Image.asset(widget.spec.robotAsset, fit: BoxFit.contain),
                  ),

                  const SizedBox(width: 10),

                  // Speech bubble
                  Container(
                    width: bubbleW,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withOpacity(0.10), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            text,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: _playAudio,
                          icon: const Icon(Icons.volume_up),
                          tooltip: "Play explanation",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);


  }
}

class AkImageOption {
  final String label;
  final String emoji;
  final bool isCorrect;
  const AkImageOption({
    required this.label,
    required this.emoji,
    required this.isCorrect,
  });
}

class AkMatchPair {
  final String word;
  final String emoji;
  const AkMatchPair({required this.word, required this.emoji});
}

class AkFeedbackBar extends StatelessWidget {
  final bool visible;
  final bool correct;
  final String title;
  final String? subtitle;
  final VoidCallback onContinue;

  const AkFeedbackBar({
    super.key,
    required this.visible,
    required this.correct,
    required this.title,
    required this.onContinue,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final bg = correct ? const Color(0xFFC8FACC) : const Color(0xFFFFD3D3);
    final fg = correct ? const Color(0xFF0B7A2A) : const Color(0xFFB00020);
    final btn = correct ? const Color(0xFF25C15A) : const Color(0xFFD32F2F);

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        offset: visible ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: visible ? 1 : 0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: bg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, -8),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(correct ? Icons.check_circle : Icons.cancel,
                        color: fg, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: fg,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                color: fg.withOpacity(0.9),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 46,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: btn,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: onContinue,
                        child: const Text(
                          "CONTINUE",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AkSelectImageTask extends StatefulWidget {
  final String prompt;
  final List<AkImageOption> options;
  final TaskCallbacks callbacks;

  final AkAngryHelpSpec? angryHelp;

  // ✅ NEW: allow disabling in rare cases (default ON)
  final bool enableSadReduceOptions;

  const AkSelectImageTask({
    super.key,
    required this.prompt,
    required this.options,
    required this.callbacks,
    this.angryHelp,
    this.enableSadReduceOptions = true,
  });

  @override
  State<AkSelectImageTask> createState() => _AkSelectImageTaskState();
}

class _AkSelectImageTaskState extends State<AkSelectImageTask> {
  late final List<AkImageOption> _optsShuffled;
  late List<AkImageOption> _visibleOpts;

  final _rng = math.Random();

  bool _answered = false;
  bool _correct = false;

  bool _sadReduced = false;

  EmotionAdaptationController? get _ctrl => widget.callbacks.emotion;
  String? get _taskId => widget.callbacks.taskId;

  @override
  void initState() {
    super.initState();
    _optsShuffled = List.of(widget.options);
    _optsShuffled.shuffle(_rng);
    _visibleOpts = List.of(_optsShuffled);

    _ctrl?.addListener(_onEmotionEvent);
  }

  @override
  void didUpdateWidget(covariant AkSelectImageTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.callbacks.emotion != widget.callbacks.emotion) {
      oldWidget.callbacks.emotion?.removeListener(_onEmotionEvent);
      widget.callbacks.emotion?.addListener(_onEmotionEvent);
    }
  }

  void _onEmotionEvent() {
    if (!mounted) return;
    if (!widget.enableSadReduceOptions) return;
    if (_answered || _sadReduced) return;

    final ev = _ctrl?.lastEvent;
    final id = _taskId;
    if (ev == null || id == null) return;

    if (ev.type == EmotionAdaptationType.sadReduceOptions && ev.taskId == id) {
      final reduced = akReduceOptionsForSad<AkImageOption>(
        items: _visibleOpts,
        isCorrect: (o) => o.isCorrect,
        rng: _rng,
      );

      // If nothing changes, do nothing
      if (reduced.length == _visibleOpts.length) return;

      setState(() {
        _visibleOpts = reduced;
        _sadReduced = true;
      });
    }
  }

  void _tap(AkImageOption opt) {
    if (_answered) return;

    final ok = opt.isCorrect;
    setState(() {
      _answered = true;
      _correct = ok;
    });

    if (!ok) widget.callbacks.onMistake();
  }

  void _revealCorrectByAngerHelp() {
    if (_answered) return;
    setState(() {
      _answered = true;
      _correct = true;
    });
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onEmotionEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final cfg = widget.callbacks.difficulty?.configForTask(widget.callbacks.taskId);
    final hideLabels = cfg?.hideOptionLabels == true;
    final correctLabel = _visibleOpts.firstWhere((o) => o.isCorrect).label;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.prompt,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.85,
                  children: _visibleOpts.map((opt) {
                    final showGreen = _answered && opt.isCorrect;

                    final border = showGreen
                        ? const Color(0xFF25C15A)
                        : Colors.black.withOpacity(0.10);

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _tap(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: showGreen ? const Color(0xFFD8FFD8) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Expanded(
                              child: Center(
                                child: Text(
                                  opt.emoji,
                                  style: const TextStyle(fontSize: 72),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (!hideLabels)
                              Text(
                                opt.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black.withOpacity(0.70),
                                ),
                              )
                            else
                              const SizedBox(height: 0),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        AkFeedbackBar(
          visible: _answered,
          correct: _correct,
          title: _correct ? "Amazing!" : "Oops!",
          subtitle: _correct ? null : "Correct: $correctLabel",
          onContinue: () {
            widget.callbacks.onComplete(shouldRepeat: !_correct);
          },
        ),

        // Angry overlay (unchanged)
        if (widget.angryHelp != null &&
            widget.callbacks.emotion != null &&
            widget.callbacks.taskId != null)
          AkAngryHelpOverlay(
            callbacks: widget.callbacks,
            spec: widget.angryHelp!,
            disabled: _answered,
            onRevealAnswer: _revealCorrectByAngerHelp,
          ),
      ],
    );
  }
}

class AkBuildWordDragTask extends StatefulWidget {
  final String prompt;
  final String pictureEmoji;
  final List<String> parts;
  final TaskCallbacks callbacks;
  final AkAngryHelpSpec? angryHelp;

  // ✅ NEW: enable sad assist (auto-fill 1 correct part)
  final bool enableSadAutoFillOne;

  const AkBuildWordDragTask({
    super.key,
    required this.prompt,
    required this.pictureEmoji,
    required this.parts,
    required this.callbacks,
    this.angryHelp,
    this.enableSadAutoFillOne = false,
  });

  @override
  State<AkBuildWordDragTask> createState() => _AkBuildWordDragTaskState();
}

class _AkBuildWordDragTaskState extends State<AkBuildWordDragTask> {
  late List<String?> placed;
  late List<String> pool;
  bool hadMistake = false;
  bool done = false;

  final _rng = math.Random();

  // ✅ Angry reveal-all support (already used)
  bool _revealedByHelp = false;

  // ✅ NEW: track which index was auto-filled by SAD (highlight green)
  final Set<int> _sadAutoFilled = <int>{};

  EmotionAdaptationController? get _ctrl => widget.callbacks.emotion;
  String? get _taskId => widget.callbacks.taskId;

  @override
  void initState() {
    super.initState();
    placed = List<String?>.filled(widget.parts.length, null);
    pool = List<String>.of(widget.parts);
    pool.shuffle(_rng);

    _ctrl?.addListener(_onEmotionEvent);
  }

  @override
  void didUpdateWidget(covariant AkBuildWordDragTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.callbacks.emotion != widget.callbacks.emotion) {
      oldWidget.callbacks.emotion?.removeListener(_onEmotionEvent);
      widget.callbacks.emotion?.addListener(_onEmotionEvent);
    }
  }

  bool get allPlaced => placed.every((e) => e != null);

  void _onEmotionEvent() {
    if (!mounted) return;
    if (!widget.enableSadAutoFillOne) return;
    if (done || _revealedByHelp) return;
    if (_sadAutoFilled.isNotEmpty) return; // only once

    final ev = _ctrl?.lastEvent;
    final id = _taskId;
    if (ev == null || id == null) return;

    // ✅ Use your “sad streak” event
    if (ev.type == EmotionAdaptationType.sadReduceOptions && ev.taskId == id) {
      _sadAutoFillOneCorrectPart();
    }
  }

  void _sadAutoFillOneCorrectPart() {
    final candidates = <int>[];
    for (int i = 0; i < placed.length; i++) {
      if (placed[i] == null) candidates.add(i);
    }
    if (candidates.isEmpty) return;

    final i = candidates[_rng.nextInt(candidates.length)];
    final correctPart = widget.parts[i];

    setState(() {
      placed[i] = correctPart;
      pool.remove(correctPart); // safe even if already removed
      _sadAutoFilled.add(i);

      if (allPlaced) done = true;
    });
  }

  void _revealCorrectByAngerHelp() {
    if (done) return;

    setState(() {
      _revealedByHelp = true;
      hadMistake = false;
      done = true;
      placed = widget.parts.map<String?>((p) => p).toList();
      pool.clear();
    });
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onEmotionEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

  final cfg = widget.callbacks.difficulty?.configForTask(widget.callbacks.taskId);
  final hideGhost = cfg?.hideGhostText == true;

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
              const SizedBox(height: 18),
              Center(
                child: Text(widget.pictureEmoji, style: const TextStyle(fontSize: 90)),
              ),
              const SizedBox(height: 18),

              // Targets
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.parts.length, (i) {
                  final correct = widget.parts[i];
                  final current = placed[i];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DragTarget<String>(
                      onWillAccept: (data) => !done,
                      onAccept: (data) {
                        if (done) return;

                        if (data == correct) {
                          setState(() {
                            placed[i] = data;
                            pool.remove(data);
                            if (allPlaced) done = true;
                          });
                        } else {
                          hadMistake = true;
                          widget.callbacks.onMistake();
                        }
                      },
                      builder: (context, candidate, rejected) {
                        final greenAll = _revealedByHelp || (done && !hadMistake);
                        final greenThisSlot = _sadAutoFilled.contains(i);

                        final revealGreen = greenAll || greenThisSlot;

                        final bg = revealGreen ? const Color(0xFFD8FFD8) : Colors.white;
                        final borderColor = revealGreen
                            ? const Color(0xFF25C15A)
                            : Colors.black.withOpacity(0.12);

                        return Container(
                          width: 86,
                          height: 62,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!hideGhost)
                                Text(
                                  correct,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black.withOpacity(0.18),
                                  ),
                                ),
                              if (current != null)
                                Text(
                                  current,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 26),

              // Pool
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: pool.map((p) {
                  return Draggable<String>(
                    data: p,
                    feedback: _LetterTile(text: p, elevated: true),
                    childWhenDragging: _LetterTile(text: p, dim: true),
                    child: _LetterTile(text: p),
                  );
                }).toList(),
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

        if (widget.angryHelp != null &&
            widget.callbacks.emotion != null &&
            widget.callbacks.taskId != null)
          AkAngryHelpOverlay(
            callbacks: widget.callbacks,
            spec: widget.angryHelp!,
            disabled: done,
            onRevealAnswer: _revealCorrectByAngerHelp,
          ),
      ],
    );
  }
}

class _LetterTile extends StatelessWidget {
  final String text;
  final bool dim;
  final bool elevated;

  const _LetterTile({
    required this.text,
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withOpacity(0.12),
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: dim ? Colors.black.withOpacity(0.25) : Colors.black,
          ),
        ),
      ),
    );
  }
}

class AkFillBlankChoiceTask extends StatefulWidget {
  final String prompt;
  final String blankText;
  final List<String> options;
  final String correct;
  final TaskCallbacks callbacks;
  final String? questionAudio;

  final AkAngryHelpSpec? angryHelp;

  // ✅ NEW
  final bool enableSadReduceOptions;

  const AkFillBlankChoiceTask({
    super.key,
    required this.prompt,
    required this.blankText,
    required this.options,
    required this.correct,
    required this.callbacks,
    this.angryHelp,
    this.enableSadReduceOptions = true,
    this.questionAudio,
  });

  @override
  State<AkFillBlankChoiceTask> createState() => _AkFillBlankChoiceTaskState();
}


class _AkFillBlankChoiceTaskState extends State<AkFillBlankChoiceTask> {
  bool answered = false;
  bool correct = false;
  String? picked;

  int _plays = 0;


  late List<String> _visibleOptions;
  bool _sadReduced = false;
  final _rng = math.Random();

  EmotionAdaptationController? get _ctrl => widget.callbacks.emotion;
  String? get _taskId => widget.callbacks.taskId;

  final AudioPlayer _qPlayer = AudioPlayer();

  Future<void> _playQuestion() async {

    final cfg = widget.callbacks.difficulty?.configForTask(widget.callbacks.taskId);
    final maxPlays = cfg?.maxQuestionAudioPlays;

    if (maxPlays != null && _plays >= maxPlays) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Audio used for this try 🙂")),
      );
      return;
    }

  _plays += 1;

    final asset = widget.questionAudio;
    if (asset == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Audio coming soon 🎧")),
      );
      return;
    }

    try {
      await _qPlayer.stop();
      await _qPlayer.play(AssetSource(asset));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't play audio (missing asset?)")),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _visibleOptions = List.of(widget.options);

    _ctrl?.addListener(_onEmotionEvent);
  }

  @override
  void didUpdateWidget(covariant AkFillBlankChoiceTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.callbacks.emotion != widget.callbacks.emotion) {
      oldWidget.callbacks.emotion?.removeListener(_onEmotionEvent);
      widget.callbacks.emotion?.addListener(_onEmotionEvent);
    }
  }

  void _onEmotionEvent() {
    if (!mounted) return;
    if (!widget.enableSadReduceOptions) return;
    if (answered || _sadReduced) return;

    final ev = _ctrl?.lastEvent;
    final id = _taskId;
    if (ev == null || id == null) return;

    if (ev.type == EmotionAdaptationType.sadReduceOptions && ev.taskId == id) {
      final reduced = akReduceOptionsForSad<String>(
        items: _visibleOptions,
        isCorrect: (o) => o == widget.correct,
        rng: _rng,
      );

      if (reduced.length == _visibleOptions.length) return;

      setState(() {
        _visibleOptions = reduced;
        _sadReduced = true;

        // If user had picked something (shouldn't happen because answered=false),
        // still keep state consistent.
        if (picked != null && !_visibleOptions.contains(picked)) {
          picked = null;
        }
      });
    }
  }

  void _choose(String s) {
    if (answered) return;

    final ok = (s == widget.correct);
    setState(() {
      answered = true;
      correct = ok;
      picked = s;
    });

    if (!ok) widget.callbacks.onMistake();
  }

  void _revealCorrectByAngerHelp() {
    if (answered) return;
    setState(() {
      answered = true;
      correct = true;
      picked = widget.correct;
    });
  }

  @override
  void dispose() {
    _qPlayer.dispose();
    _ctrl?.removeListener(_onEmotionEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final cfg = widget.callbacks.difficulty?.configForTask(widget.callbacks.taskId);
    final maxPlays = cfg?.maxQuestionAudioPlays; // null => unlimited
    final canPlay = maxPlays == null || _plays < maxPlays;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.prompt,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),
              Row(
                children: [
                  InkWell(
                    onTap: canPlay ? _playQuestion : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Audio used for this try 🙂")),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: canPlay ? const Color(0xFF1FB6FF) : Colors.grey,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 10,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: const Icon(Icons.volume_up, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      widget.blankText,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _visibleOptions.map((o) {
                  final isCorrectOpt = o == widget.correct;
                  final isPicked = picked == o;

                  final showGreen = answered && isCorrectOpt;
                  final showRed = answered && isPicked && !isCorrectOpt;

                  final bg = showGreen
                      ? const Color(0xFFD8FFD8)
                      : (showRed ? const Color(0xFFFFD3D3) : Colors.white);

                  final border = showGreen
                      ? const Color(0xFF25C15A)
                      : (showRed ? const Color(0xFFD32F2F) : Colors.black.withOpacity(0.14));

                  return SizedBox(
                    width: 80,
                    height: 72,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: bg,
                        side: BorderSide(color: border, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _choose(o),
                      child: Text(
                        o,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),

        AkFeedbackBar(
          visible: answered,
          correct: correct,
          title: correct ? "Amazing!" : "Oops!",
          subtitle: correct ? null : "Correct: ${widget.correct}",
          onContinue: () {
            widget.callbacks.onComplete(shouldRepeat: !correct);
          },
        ),

        // Angry help overlay (unchanged)
        if (widget.angryHelp != null &&
            widget.callbacks.emotion != null &&
            widget.callbacks.taskId != null)
          AkAngryHelpOverlay(
            callbacks: widget.callbacks,
            spec: widget.angryHelp!,
            disabled: answered,
            onRevealAnswer: _revealCorrectByAngerHelp,
          ),
      ],
    );
  }
}

class AkMultiSelectWordsTask extends StatefulWidget {
  final String prompt;
  final List<String> words;
  final Set<String> correctWords;
  final TaskCallbacks callbacks;

  final AkAngryHelpSpec? angryHelp;

  // ✅ NEW
  final bool enableSadReduceOptions;

  const AkMultiSelectWordsTask({
    super.key,
    required this.prompt,
    required this.words,
    required this.correctWords,
    required this.callbacks,
    this.angryHelp,
    this.enableSadReduceOptions = true,
  });

  @override
  State<AkMultiSelectWordsTask> createState() => _AkMultiSelectWordsTaskState();
}

class _AkMultiSelectWordsTaskState extends State<AkMultiSelectWordsTask> {

  Set<String> _effectiveCorrectWords() {
    final cfg = widget.callbacks.difficulty?.configForTask(widget.callbacks.taskId);
    final starts = cfg?.onlyWordsStartingWith;
    if (starts == null) return widget.correctWords;

    return widget.words.where((w) => w.startsWith(starts)).toSet();
  }

  final Set<String> selected = {};
  bool checked = false;
  bool ok = false;

  late List<String> _visibleWords;
  bool _sadReduced = false;
  final _rng = math.Random();

  EmotionAdaptationController? get _ctrl => widget.callbacks.emotion;
  String? get _taskId => widget.callbacks.taskId;

  @override
  void initState() {
    super.initState();
    _visibleWords = List.of(widget.words);

    _ctrl?.addListener(_onEmotionEvent);
  }

  @override
  void didUpdateWidget(covariant AkMultiSelectWordsTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.callbacks.emotion != widget.callbacks.emotion) {
      oldWidget.callbacks.emotion?.removeListener(_onEmotionEvent);
      widget.callbacks.emotion?.addListener(_onEmotionEvent);
    }
  }

  void _onEmotionEvent() {
    if (!mounted) return;
    if (!widget.enableSadReduceOptions) return;
    if (checked || _sadReduced) return;

    final ev = _ctrl?.lastEvent;
    final id = _taskId;
    if (ev == null || id == null) return;

    if (ev.type == EmotionAdaptationType.sadReduceOptions && ev.taskId == id) {
      final reduced = akReduceWordsForSad(
        words: _visibleWords,
        correctWords: _effectiveCorrectWords(),
        rng: _rng,
      );

      if (reduced.length == _visibleWords.length) return;

      setState(() {
        _visibleWords = reduced;
        _sadReduced = true;

        // Clean selections if we removed a previously selected wrong word
        selected.removeWhere((w) => !_visibleWords.contains(w));
      });
    }
  }

  void _toggle(String w) {
    if (checked) return;
    setState(() {
      if (selected.contains(w)) {
        selected.remove(w);
      } else {
        selected.add(w);
      }
    });
  }

  void _check() {
    if (checked) return;

    final effCorrect = _effectiveCorrectWords();
    final isCorrect = setEquals(selected, widget.correctWords);
    setState(() {
      checked = true;
      ok = isCorrect;
    });

    if (!isCorrect) widget.callbacks.onMistake();
  }

  void _revealCorrectByAngerHelp() {
    if (checked) return;
    setState(() {
      selected
        ..clear()
        ..addAll(widget.correctWords);
      checked = true;
      ok = true;
    });
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onEmotionEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final cfg = widget.callbacks.difficulty?.configForTask(widget.callbacks.taskId);
    final prompt = cfg?.overridePrompt ?? widget.prompt;
    final correctList = widget.correctWords.join(", ");

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prompt,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _visibleWords.map((w) {
                  final s = selected.contains(w);
                  return ChoiceChip(
                    label: Text(w,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    selected: s,
                    onSelected: (_) => _toggle(w),
                    selectedColor: const Color(0xFFD8FFD8),
                    backgroundColor: Colors.white,
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.black.withOpacity(0.12), width: 2),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF25C15A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _check,
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
          subtitle: ok ? null : "Correct: $correctList",
          onContinue: () {
            widget.callbacks.onComplete(shouldRepeat: !ok);
          },
        ),

        // Angry help overlay (unchanged)
        if (widget.angryHelp != null &&
            widget.callbacks.emotion != null &&
            widget.callbacks.taskId != null)
          AkAngryHelpOverlay(
            callbacks: widget.callbacks,
            spec: widget.angryHelp!,
            disabled: checked,
            onRevealAnswer: _revealCorrectByAngerHelp,
          ),
      ],
    );
  }
}


class AkBalloonPopTask extends StatefulWidget {
  final String prompt;
  final String targetLetter;
  final int targetCount;
  final double targetProbability; // e.g., 0.25
  final List<String> otherLetters;
  final TaskCallbacks callbacks;

  const AkBalloonPopTask({
    super.key,
    required this.prompt,
    required this.targetLetter,
    required this.targetCount,
    required this.targetProbability,
    required this.otherLetters,
    required this.callbacks,
  });

  @override
  State<AkBalloonPopTask> createState() => _AkBalloonPopTaskState();
}

class _AkBalloonPopTaskState extends State<AkBalloonPopTask> with TickerProviderStateMixin {

  int get _effectiveTargetCount {
    final cfg = widget.callbacks.difficulty?.configForTask(widget.callbacks.taskId);
    return cfg?.balloonTargetCount ?? widget.targetCount;
  }

  List<String> get _effectiveOtherLetters {
    final cfg = widget.callbacks.difficulty?.configForTask(widget.callbacks.taskId);
    final extra = cfg?.balloonExtraConfusers ?? const <String>[];
    final all = <String>{...widget.otherLetters, ...extra};
    return all.toList();
  }

  final _rng = math.Random();
  final List<_Balloon> _balloons = [];
  Timer? _spawnTimer;

  int _hit = 0;
  bool _done = false;
  bool _hadMistake = false;

  // ✅ NEW: once angry is detected on THIS task, paint correct balloons green
  bool _highlightTargetBalloons = false;

  EmotionAdaptationController? get _ctrl => widget.callbacks.emotion;
  String? get _taskId => widget.callbacks.taskId;

  @override
  void initState() {
    super.initState();

    // ✅ listen for emotion adaptation events
    _ctrl?.addListener(_onEmotionEvent);

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 520), (_) {
      if (!mounted || _done) return;
      _spawn();
    });
  }

  @override
  void didUpdateWidget(covariant AkBalloonPopTask oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.callbacks.emotion != widget.callbacks.emotion) {
      oldWidget.callbacks.emotion?.removeListener(_onEmotionEvent);
      widget.callbacks.emotion?.addListener(_onEmotionEvent);
    }
  }

  void _onEmotionEvent() {
    if (!mounted) return;

    final ev = _ctrl?.lastEvent;
    final id = _taskId;
    if (ev == null || id == null) return;

    // Reuse your existing angryHelp event as the trigger signal.
    // For Task 4, we interpret it as "highlight correct balloons".
    if (ev.type == EmotionAdaptationType.angryHelp && ev.taskId == id) {
      if (_highlightTargetBalloons) return;
      setState(() => _highlightTargetBalloons = true);
    }
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();

    _ctrl?.removeListener(_onEmotionEvent);

    for (final b in _balloons) {
      b.controller.dispose();
    }
    super.dispose();
  }

  void _spawn() {
    final isTarget = _rng.nextDouble() < widget.targetProbability;
    final letter = isTarget
        ? widget.targetLetter
        : _effectiveOtherLetters[_rng.nextInt(_effectiveOtherLetters.length)];
    final x = _rng.nextDouble().clamp(0.08, 0.92);

    final c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2600 + _rng.nextInt(1200)),
    );

    final id = _rng.nextInt(1 << 31);
    final balloon = _Balloon(id: id, x: x, letter: letter, controller: c);

    setState(() {
      _balloons.add(balloon);
    });

    c.addStatusListener((st) {
      if (st == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          _balloons.removeWhere((b) => b.id == id);
        });
        c.dispose();
      }
    });

    c.forward();
  }

  void _pop(_Balloon b) {
    if (_done) return;

    final correct = b.letter == widget.targetLetter;
    if (!correct) {
      _hadMistake = true;
      widget.callbacks.onMistake();
    } else {
      _hit += 1;
    }

    setState(() {
      _balloons.removeWhere((x) => x.id == b.id);
    });

    b.controller.dispose();

    if (_hit >= _effectiveTargetCount) {
      setState(() {
        _done = true;
      });
      _spawnTimer?.cancel();
      _spawnTimer = null;
      for (final bb in _balloons) {
        bb.controller.stop();
        bb.controller.dispose();
      }
      _balloons.clear();
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
                  const SizedBox(height: 10),
                  Text(
                    "Pop $_effectiveTargetCount balloons with “${widget.targetLetter}”  ($_hit/$_effectiveTargetCount)",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Stack(
                      children: _balloons.map((b) {
                        return AnimatedBuilder(
                          animation: b.controller,
                          builder: (context, _) {
                            final t = b.controller.value; // 0..1
                            final y = (h - 220) - t * (h - 60);
                            final x = b.x * w;

                            final isTarget = b.letter == widget.targetLetter;

                            return Positioned(
                              left: x - 42,
                              top: y,
                              child: GestureDetector(
                                onTap: () => _pop(b),
                                child: _BalloonView(
                                  letter: b.letter,
                                  isTarget: isTarget,
                                  // ✅ NEW: if angry was detected, paint target balloons green
                                  highlightTargetGreen: _highlightTargetBalloons,
                                ),
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

class _BalloonView extends StatelessWidget {
  final String letter;
  final bool isTarget;

  // ✅ NEW
  final bool highlightTargetGreen;

  const _BalloonView({
    required this.letter,
    required this.isTarget,
    required this.highlightTargetGreen,
  });

  @override
  Widget build(BuildContext context) {
    final shouldPaintGreen = highlightTargetGreen && isTarget;

    // default look
    final defaultBg = const Color(0xFFDFF6FF);
    final defaultBorder = isTarget ? const Color(0xFF1FB6FF) : Colors.black.withOpacity(0.08);

    // angry-highlight look
    final greenBg = const Color(0xFFD8FFD8);
    final greenBorder = const Color(0xFF25C15A);

    final bg = shouldPaintGreen ? greenBg : defaultBg;
    final border = shouldPaintGreen ? greenBorder : defaultBorder;

    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 3),
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
          letter,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _Balloon {
  final int id;
  final double x;
  final String letter;
  final AnimationController controller;

  _Balloon({
    required this.id,
    required this.x,
    required this.letter,
    required this.controller,
  });
}

class AkMatchWordsToPicturesTask extends StatefulWidget {
  final String prompt;
  final List<AkMatchPair> pairs;
  final TaskCallbacks callbacks;

  final AkAngryHelpSpec? angryHelp;

  // ✅ NEW: enable sad assist (auto-match 1 correct pair)
  final bool enableSadAutoMatchOne;

  const AkMatchWordsToPicturesTask({
    super.key,
    required this.prompt,
    required this.pairs,
    required this.callbacks,
    this.angryHelp,
    this.enableSadAutoMatchOne = false,
  });

  @override
  State<AkMatchWordsToPicturesTask> createState() => _AkMatchWordsToPicturesTaskState();
}

class _AkMatchWordsToPicturesTaskState extends State<AkMatchWordsToPicturesTask> {
  late final List<AkMatchPair> targets;
  late final List<AkMatchPair> wordsPool;

  final Map<String, String> placedWordForEmoji = {}; // emoji -> word
  bool hadMistake = false;
  bool done = false;

  final _rng = math.Random();

  // ✅ NEW: which emoji row was auto-matched by SAD
  final Set<String> _sadAutoMatched = <String>{};

  EmotionAdaptationController? get _ctrl => widget.callbacks.emotion;
  String? get _taskId => widget.callbacks.taskId;

 @override
void initState() {
  super.initState();
  targets = List.of(widget.pairs);
  targets.shuffle(_rng);
  wordsPool = List.of(widget.pairs);
  wordsPool.shuffle(_rng);

  // ✅ NEW: add decoys if hard mode says so
  final cfg = widget.callbacks.difficulty?.configForTask(widget.callbacks.taskId);
  final decoyCount = cfg?.decoyWordCount ?? 0;

  if (decoyCount > 0) {
    final avoid = widget.pairs.map((p) => p.word).toSet();
    final picks = _pickDecoys(
      count: decoyCount,
      avoid: avoid,
      candidates: cfg?.decoyCandidates ?? const <String>[],
    );

    for (final w in picks) {
      wordsPool.add(AkMatchPair(word: w, emoji: "")); // emoji unused in pool
    }

    wordsPool.shuffle(_rng);
  }

  _ctrl?.addListener(_onEmotionEvent);
}

List<String> _pickDecoys({
  required int count,
  required Set<String> avoid,
  required List<String> candidates,
}) {
  final pool = candidates.where((w) => w.trim().isNotEmpty && !avoid.contains(w)).toList();

  // If you didn't provide enough candidates, generate safe placeholders.
  while (pool.length < count) {
    final gen = "වචනය${pool.length + 1}";
    if (!avoid.contains(gen)) pool.add(gen);
  }

  pool.shuffle(_rng);
  return pool.take(count).toList();
}


  @override
  void didUpdateWidget(covariant AkMatchWordsToPicturesTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.callbacks.emotion != widget.callbacks.emotion) {
      oldWidget.callbacks.emotion?.removeListener(_onEmotionEvent);
      widget.callbacks.emotion?.addListener(_onEmotionEvent);
    }
  }

  bool get allMatched => placedWordForEmoji.length == targets.length;

  void _onEmotionEvent() {
    if (!mounted) return;
    if (!widget.enableSadAutoMatchOne) return;
    if (done) return;
    if (_sadAutoMatched.isNotEmpty) return; // only once

    final ev = _ctrl?.lastEvent;
    final id = _taskId;
    if (ev == null || id == null) return;

    if (ev.type == EmotionAdaptationType.sadReduceOptions && ev.taskId == id) {
      _sadAutoMatchOnePair();
    }
  }

  void _sadAutoMatchOnePair() {
    // pick one target not yet matched
    final remaining = targets.where((t) => !placedWordForEmoji.containsKey(t.emoji)).toList();
    if (remaining.isEmpty) return;

    final t = remaining[_rng.nextInt(remaining.length)];

    setState(() {
      placedWordForEmoji[t.emoji] = t.word;
      wordsPool.removeWhere((p) => p.word == t.word);
      _sadAutoMatched.add(t.emoji);

      if (allMatched) done = true;
    });
  }

  void _place({required AkMatchPair target, required AkMatchPair dragged}) {
    if (done) return;

    if (dragged.word == target.word) {
      setState(() {
        placedWordForEmoji[target.emoji] = dragged.word;
        wordsPool.removeWhere((p) => p.word == dragged.word);
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

  void _revealCorrectByAngerHelp() {
    if (done) return;

    setState(() {
      placedWordForEmoji.clear();
      for (final p in widget.pairs) {
        placedWordForEmoji[p.emoji] = p.word;
      }
      wordsPool.clear();
      hadMistake = false;
      done = true;
    });
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onEmotionEvent);
    super.dispose();
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
              const SizedBox(height: 18),
              Expanded(
                child: Row(
                  children: [
                    // Words (left)
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
                              children: wordsPool.map((p) {
                                return Draggable<AkMatchPair>(
                                  data: p,
                                  feedback: _WordChip(text: p.word, elevated: true),
                                  childWhenDragging: _WordChip(text: p.word, dim: true),
                                  child: _WordChip(text: p.word),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Pictures (right)
                    Expanded(
                      child: Column(
                        children: [
                          Text("Pictures",
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
                                final placed = placedWordForEmoji[t.emoji];

                                final auto = _sadAutoMatched.contains(t.emoji);

                                return DragTarget<AkMatchPair>(
                                  onWillAccept: (_) => !done && !auto,
                                  onAccept: (dragged) => _place(target: t, dragged: dragged),
                                  builder: (context, candidate, rejected) {
                                    final highlight = candidate.isNotEmpty;

                                    final bg = auto ? const Color(0xFFD8FFD8) : Colors.white;

                                    final borderColor = auto
                                        ? const Color(0xFF25C15A)
                                        : (highlight
                                            ? const Color(0xFF25C15A)
                                            : Colors.black.withOpacity(0.10));

                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: bg,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: borderColor, width: 2),
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
                                          Text(t.emoji, style: const TextStyle(fontSize: 38)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              placed ?? "Drop word here",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                                color: placed != null
                                                    ? Colors.black
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

        if (widget.angryHelp != null &&
            widget.callbacks.emotion != null &&
            widget.callbacks.taskId != null)
          AkAngryHelpOverlay(
            callbacks: widget.callbacks,
            spec: widget.angryHelp!,
            disabled: done,
            onRevealAnswer: _revealCorrectByAngerHelp,
          ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  final String text;
  final bool dim;
  final bool elevated;

  const _WordChip({
    required this.text,
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
            color: dim ? Colors.black.withOpacity(0.25) : Colors.black,
          ),
        ),
      ),
    );
  }
}
