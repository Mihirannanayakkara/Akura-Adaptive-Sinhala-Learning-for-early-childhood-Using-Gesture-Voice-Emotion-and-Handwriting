import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/letter_spec.dart';
import 'letter_painters.dart';
import 'package:lottie/lottie.dart';
import 'combine_shape_canva.dart';
import 'package:audioplayers/audioplayers.dart';

class LetterCanvasController {
  _LetterPageState? _state;
  void _attach(_LetterPageState s) => _state = s;
  void clear() => _state?._clear();
}

class LetterPage extends StatefulWidget {
  final LetterSpec spec;
  final LetterCanvasController? controller;
  final bool startPractice;
  final VoidCallback? onPassedToPractice;
  final VoidCallback? onNextLetter;
  const LetterPage({super.key, required this.spec, this.controller, this.startPractice = false, this.onPassedToPractice, this.onNextLetter});
  @override
  State<LetterPage> createState() => _LetterPageState();
}

class _LetterPageState extends State<LetterPage> {
  late final String svgData;
  final List<List<Offset>> strokes = [];
  Path? _basePath;
  Path? _fittedPath;
  List<Offset> _samples = [];
  Rect _lastStage = Rect.zero;
  double _percentOnPath = 0.0;
  bool _canShowOnPath = false;
  List<Offset> _startGuide = [];
  List<Offset> _endGuide = [];
  int _lastHapticMs = 0;
  bool _isOffPath = false;
  int _offPathSinceMs = 0;
  Timer? _buzzTimer;
  int _buzzInterval = 0;
  _PracticeMode _mode = _PracticeMode.guided;
  static const double _passPct = 80.0;
  double get _thrScale => (_mode == _PracticeMode.practice || _mode == _PracticeMode.done) ? 1.6 : 1.0;
  
  final List<Confetti> _confetti = [];
  Timer? _confettiTimer;
  bool _confettiActive = false;

  int _failedAttempts = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _hasReachedEnd = false; // Tracks if the user is currently at the target
  Timer? _reminderTimer;
  

  @override
  void initState() {
    super.initState();
    svgData = widget.spec.svgData;
    _basePath = parseSvgPathData(svgData);
    widget.controller?._attach(this);
    if (widget.startPractice) {
      _mode = _PracticeMode.practice;
    }
  }

  void _resetReminderTimer() {
  _reminderTimer?.cancel();
  
  if (_mode != _PracticeMode.done && !_hasReachedEnd) {
    _reminderTimer = Timer(const Duration(seconds: 4), () {
      _playReminderVoice();
    });
  }
}

void _playReminderVoice() {
  if (!_hasReachedEnd && _mode != _PracticeMode.done) {
    if (_audioPlayer.state != PlayerState.playing) {
      _audioPlayer.play(AssetSource('audio/end_here.mp3'));
    }
  }
}

  void _fitAndSample(Size size) {
    if (_basePath == null) return;
    final bounds = _basePath!.getBounds();
    final s = min(size.width / bounds.width, size.height / bounds.height) * 0.85;
    final tx = (size.width - bounds.width * s) * 0.5 - bounds.left * s;
    final ty = (size.height - bounds.height * s) * 0.5 - bounds.top * s;
    final m4 = Float64List.fromList([
      s, 0, 0, 0,
      0, s, 0, 0,
      0, 0, 1, 0,
      tx, ty, 0, 1,
    ]);
    _fittedPath = _basePath!.transform(m4);
    _samples = _samplePath(_fittedPath!, 900);
    if (widget.spec.startBase != null) {
      _startGuide = widget.spec.startBase!.map((p) => Offset(p.dx * s + tx, p.dy * s + ty)).toList(growable: false);
    } else if (_samples.isNotEmpty) {
      final n = _samples.length, step = max(1, n ~/ 60);
      _startGuide = [
        _samples[0],
        _samples[min(n - 1, step * 4)],
        _samples[min(n - 1, step * 8)],
      ];
    } else {
      _startGuide = const [];
    }
    if (widget.spec.endBase != null) {
      _endGuide = widget.spec.endBase!.map((p) => Offset(p.dx * s + tx, p.dy * s + ty)).toList(growable: false);
    } else if (_samples.isNotEmpty) {
      final n = _samples.length, step = max(1, n ~/ 60);
      _endGuide = [
        _samples[max(0, n - 1 - step * 8)],
        _samples[max(0, n - 1 - step * 4)],
        _samples[n - 1],
      ];
    } else {
      _endGuide = const [];
    }
  }

  List<Offset> _samplePath(Path path, int n) {
    final metrics = path.computeMetrics().toList(growable: false);
    final lengths = metrics.map((m) => m.length).toList(growable: false);
    final sum = lengths.fold<double>(0, (a, b) => a + b);
    final result = <Offset>[];
    for (int i = 0; i <= n; i++) {
      final dist = (i / n) * sum;
      double t = dist;
      for (final m in metrics) {
        if (t <= m.length || identical(m, metrics.last)) {
          final tan = m.getTangentForOffset(t.clamp(0, m.length));
          result.add(tan!.position);
          break;
        } else {
          t -= m.length;
        }
      }
    }
    return result;
  }

  void _startStroke(Offset p) {
    _hasReachedEnd = false; 
  _resetReminderTimer();
    if (strokes.isEmpty && _startGuide.isNotEmpty) {
      final stageMin = min(_lastStage.width, _lastStage.height);
      final thr = stageMin * 0.035 * _thrScale;
      final d = _distToPolyline(_startGuide, p);
      if (d > thr) {
        _audioPlayer.play(AssetSource('audio/starthere.mp3'));
        HapticFeedback.lightImpact();
        return;
      }
    }
    setState(() {
      strokes.add([p]);
    });
  }

  void _extendStroke(Offset p) {
    if (strokes.isEmpty) return;
    if (!_hasReachedEnd) {
    _resetReminderTimer();
  }
    final s = strokes.last;
    if (s.isEmpty || (s.last - p).distanceSquared > 2) {
      // ignore: unused_local_variable
      final prev = s.isNotEmpty ? s.last : p;
      setState(() {
        s.add(p);
      });
      _maybeHapticOffPath(p);
    }
  }

  void _endStroke() {
    _reminderTimer?.cancel();
    if (strokes.isNotEmpty && strokes.last.isNotEmpty) {
      final stageMin = min(_lastStage.width, _lastStage.height);
      final thr = stageMin * 0.035;
      final lastPoint = strokes.last.last;
      bool nearProgressEnd = false;
      bool nearEndFlag = false;
      if (_samples.length > 5) {
        final idx = _nearestIndex(lastPoint).$1;
        if (idx >= 0) {
          final t = (_samples.length - 1) > 0 ? idx / (_samples.length - 1) : 0.0;
          nearProgressEnd = t >= 0.92;
        }
      }
      if (_endGuide.isNotEmpty) {
        final d = _distToPolyline(_endGuide, lastPoint);
        final thrEnd = thr * 1.5;
        nearEndFlag = d <= thrEnd;
      }
      if (!nearEndFlag) _resetReminderTimer();
    }
    _analyze();
    _persistTrace();
  }

  Future<void> _persistTrace() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final tracesDir = Directory('${dir.path}/traces');
      if (!await tracesDir.exists()) {
        await tracesDir.create(recursive: true);
      }
      final ts = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tracesDir.path}/${widget.spec.title}_$ts.json');
      final data = {
        'letter': widget.spec.title,
        'strokes': strokes
            .map((s) => s.map((p) => {'x': p.dx, 'y': p.dy}).toList())
            .toList(),
      };
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    } catch (_) {
      // ignore persistence errors in app UX
    }
  }

  void _clear() {
    _reminderTimer?.cancel();
    setState(() {
      strokes.clear();
      _percentOnPath = 0.0;
      _canShowOnPath = false;
      _isOffPath = false;
      _offPathSinceMs = 0;
      _stopBuzz();
      _stopConfetti();
      _hasReachedEnd = false;

      if (_mode == _PracticeMode.done) {
        _mode = widget.startPractice ? _PracticeMode.practice : _PracticeMode.guided;
      }
      
    });
  }

  void _analyze() {
    if (_samples.isEmpty || strokes.isEmpty) return;
    final stageMin = min(_lastStage.width, _lastStage.height);
    final allPts = strokes.expand((e) => e).toList(growable: false);
    if (allPts.isEmpty) return;
    double minX = double.infinity, minY = double.infinity, maxX = -double.infinity, maxY = -double.infinity;
    for (final p in allPts) {
      if (p.dx < minX) minX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy > maxY) maxY = p.dy;
    }
    final sizeOk = max(maxX - minX, maxY - minY) >= stageMin * 0.25;
    bool directionOk = true;
    bool orderOk = true;
    bool accuracyOk = true;
    final segments = [const _Range(0.0, 1.0)];
    final thr = stageMin * 0.035 * _thrScale;
    double okLen = 0.0;
    double totLen = 0.0;
    bool startOk = false;
    bool endOk = false;
    for (int si = 0; si < strokes.length; si++) {
      final s = strokes[si];
      if (s.length < 2) continue;
      final idxs = <int>[];
      final dists = <double>[];
      for (int i = 0; i < s.length; i += 2) {
        final n = _nearestIndex(s[i]);
        idxs.add(n.$1);
        dists.add(n.$2);
      }
      if (!startOk && _startGuide.isNotEmpty && si == 0) {
        final d0 = _distToPolyline(_startGuide, s.first);
        if (d0 <= thr) startOk = true;
      }
      if (!endOk && _endGuide.isNotEmpty && si == strokes.length - 1) {
        final d1 = _distToPolyline(_endGuide, s.last);
        if (d1 <= thr) endOk = true;
      }
      for (int i = 1; i < s.length; i++) {
        final p0 = s[i - 1];
        final p1 = s[i];
        final segLen = (p1 - p0).distance;
        totLen += segLen;
        final dn = _nearestIndex(p1).$2;
        if (dn <= thr) okLen += segLen;
      }
      int inc = 0, dec = 0;
      for (int i = 1; i < idxs.length; i++) {
        if (idxs[i] > idxs[i - 1]) {
          inc++;
        } else if (idxs[i] < idxs[i - 1]) {
          dec++;
        }
      }
      if (!(inc > dec * 1.5)) directionOk = false;
      final meanDist = dists.isEmpty ? 0 : dists.reduce((a, b) => a + b) / dists.length;
      if (meanDist > thr) accuracyOk = false;
      final seg = segments[min(si, segments.length - 1)];
      int inside = 0;
      for (final id in idxs) {
        final t = id / (_samples.length - 1);
        if (t >= seg.start && t <= seg.end) inside++;
      }
      final frac = idxs.isEmpty ? 0.0 : inside / idxs.length;
      if (frac < 0.6) orderOk = false;
    }
    final ok = sizeOk && directionOk && orderOk && accuracyOk && startOk && endOk;
    
final totalPathLength = _fittedPath!.computeMetrics().fold<double>(
  0.0, 
  (sum, metric) => sum + metric.length
) / 1.8; 


double accuracyPercent = totalPathLength > 0 
    ? (okLen / totalPathLength) * 100.0 
    : 0.0;
accuracyPercent = accuracyPercent.clamp(0.0, 100.0);
    final finalOk = ok;

    
    setState(() {
      _percentOnPath = accuracyPercent;
      _canShowOnPath = endOk;
      if (_mode == _PracticeMode.practice && finalOk && accuracyPercent >= _passPct) {
        _mode = _PracticeMode.done;
        HapticFeedback.heavyImpact();
        _startConfetti();
      }else if (accuracyPercent < 50.0) {
          // FAILURE (Below 50%)
          _failedAttempts++;
          
          if (_failedAttempts >= 2) {
            _navigateToCombineShape();
          }
        }
    });
  }

  (int, double) _nearestIndex(Offset p) {
    double minD = double.infinity;
    int idx = -1;
    for (int i = 0; i < _samples.length; i++) {
      final q = _samples[i];
      final d = (q - p).distanceSquared;
      if (d < minD) {
        minD = d;
        idx = i;
      }
    }
    return (idx, sqrt(minD));
  }
  void _maybeHapticOffPath(Offset p) {
    if (_samples.isEmpty) return;
    final d = _nearestIndex(p).$2;
    final minDim = min(_lastStage.width, _lastStage.height);
    final thr = minDim * 0.035 * _thrScale;
    final off = d > thr;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (off && !_isOffPath) {
      _offPathSinceMs = now;
      _lastHapticMs = 0;
      HapticFeedback.heavyImpact();
      HapticFeedback.vibrate();
    }
    _isOffPath = off;
    if (!off) {
      _stopBuzz();
      return;
    }
    double r = (d - thr) / thr;
    if (r < 0) r = 0;
    if (r > 1.5) r = 1.5;
    int cooldown;
    if (r < 0.3) {
      cooldown = 100;
    } else if (r < 0.8) {
      cooldown = 70;
    } else {
      cooldown = 45;
    }
    if (_offPathSinceMs > 0 && now - _offPathSinceMs > 600) {
      cooldown = max(30, cooldown - 15);
    }
    if (_buzzTimer == null || _buzzInterval != cooldown) {
      _startBuzz(cooldown, r < 0.3 ? 0 : 1);
    }
  }
  void _startBuzz(int intervalMs, int strength) {
    _buzzInterval = intervalMs;
    _buzzTimer?.cancel();
    _buzzTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!_isOffPath) {
        _stopBuzz();
        return;
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastHapticMs < intervalMs) return;
      _lastHapticMs = now;
      if (strength == 0) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
        HapticFeedback.vibrate();
      }
    });
  }
  void _stopBuzz() {
    _buzzTimer?.cancel();
    _buzzTimer = null;
    _buzzInterval = 0;
  }
  void _startConfetti() {
    if (_confettiActive) return;
    _confettiActive = true;
    _confetti.clear();
    final rnd = Random();
    final width = _lastStage.width > 0 ? _lastStage.width : 300.0;
    for (int i = 0; i < 90; i++) {
      final x = rnd.nextDouble() * width;
      final y = -rnd.nextDouble() * 50;
      final vx = (rnd.nextDouble() - 0.5) * 2.0;
      final vy = 1.5 + rnd.nextDouble() * 2.5;
      final size = 6.0 + rnd.nextDouble() * 8.0;
      final colors = [const Color(0xFF60A5FA), const Color(0xFF34D399), const Color(0xFFFBBF24), const Color(0xFFF472B6), const Color(0xFFFB7185)];
      final color = colors[rnd.nextInt(colors.length)];
      _confetti.add(Confetti(Offset(x, y), Offset(vx, vy), size, color, 1.0));
    }
    _confettiTimer?.cancel();
    _confettiTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final h = _lastStage.height > 0 ? _lastStage.height : 300.0;
      bool any = false;
      for (int i = 0; i < _confetti.length; i++) {
        final c = _confetti[i];
        final gravity = 0.08;
        c.vel = Offset(c.vel.dx, c.vel.dy + gravity);
        c.pos = c.pos + c.vel;
        c.life -= 0.004;
        if (c.pos.dy < h && c.life > 0) any = true;
      }
      _confetti.removeWhere((c) => c.pos.dy >= h || c.life <= 0);
      if (!any) {
        _stopConfetti();
      }
      if (mounted) setState(() {});
    });
  }
  void _stopConfetti() {
    _confettiTimer?.cancel();
    _confettiTimer = null;
    _confettiActive = false;
    _confetti.clear();
  }

  void _navigateToCombineShape() {
  // 1. Call the static mapper to check if a shape exists
  final spec = CombineShapeScreen.getSpec(widget.spec.title);
  
  if (spec != null) {

    _failedAttempts = 0; 

    _audioPlayer.setSource(
      AssetSource('audio/combine_shape.mp3')
    ).then((_) => _audioPlayer.resume())
     .catchError((e) => debugPrint("Audio Error: $e"));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CombineShapeScreen(
          letterTitle: widget.spec.title,
        ),
      ),
    );
  } else {
    _failedAttempts = 0;
  }
}

@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      Column(
        children: [
      Expanded(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, box) {
                final stageSize = Size(box.maxWidth, box.maxHeight);

                if (_lastStage.size != stageSize) {
                  _lastStage = Offset.zero & stageSize;
                  _fitAndSample(stageSize);
                }

                return Listener(
                  onPointerDown: (e) => _startStroke(e.localPosition),
                  onPointerMove: (e) => _extendStroke(e.localPosition),
                  onPointerUp: (e) => _endStroke(),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: _mode == _PracticeMode.practice || _mode == _PracticeMode.done
                            ? SkeletonPainter(null, _startGuide, _endGuide)
                            : SkeletonPainter(_fittedPath, _startGuide, _endGuide),
                        foregroundPainter: DrawPainter(strokes, _samples, _thrScale),
                      ),
                      
                      if (_confettiActive) 
                        CustomPaint(painter: ConfettiPainter(_confetti)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),

      
      if (_canShowOnPath)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'On-path: ${_percentOnPath.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
        ),

      
      if (_mode == _PracticeMode.guided && _percentOnPath >= _passPct)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onPassedToPractice != null) {
                  widget.onPassedToPractice!();
                } else {
                  setState(() {
                    _mode = _PracticeMode.practice;
                    strokes.clear();
                    _isOffPath = false;
                    _offPathSinceMs = 0;
                    _stopBuzz();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Try Practice Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),

      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _LegendItem(color: Color(0xFF22C55E), label: 'Start here', icon: Icons.flag_rounded),
            SizedBox(width: 18),
            _LegendItem(color: Color(0xFFDC2626), label: 'End here', icon: Icons.outlined_flag_rounded),
          ],
        ),
      ),
      const SizedBox(height: 8),
    ],
  ),
  if (_mode == _PracticeMode.done)
        IgnorePointer(
          child: Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_u4yrau.json',
            repeat: false,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

      if (_mode == _PracticeMode.done)
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // THE CHARACTER (Jumping Star)
              // This is positioned right above the card
              Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_touohxv0.json',
                height: 120,
                animate: true,
              ),
           Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isFilled = _percentOnPath >= (index + 1) * 20;
            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 400 + (index * 150)),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFilled ? const Color.fromARGB(255, 255, 212, 85) : Colors.grey[200],
                    size: 44,
                  ),
                );
              },
            );
          }),
        ),
                const SizedBox(height: 10),
                
                const Text(
                  '🎉 Excellent Work',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 26, 26, 38),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You Completed Letter ${widget.spec.title}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 46, 46, 47),
                  ),
                ),
                const SizedBox(height: 8),
                  Text(
                    'Score: ${_percentOnPath.toStringAsFixed(0)}%', 
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8E93),
                      height: 1.3,
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onNextLetter ?? () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.onNextLetter != null ? 'Next Letter' : 'Back to Home',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
            ],
          ),
        ),
      ],

    );

  }
}


class _Range {
  final double start;
  final double end;
  const _Range(this.start, this.end);
}
enum _PracticeMode { guided, practice, done }


double _distToPolyline(List<Offset> poly, Offset p) {
  double best = double.infinity;
  for (int i = 1; i < poly.length; i++) {
    final a = poly[i - 1];
    final b = poly[i];
    final v = b - a;
    final w = p - a;
    final vv = v.dx * v.dx + v.dy * v.dy;
    double t = vv > 0 ? (w.dx * v.dx + w.dy * v.dy) / vv : 0;
    t = t.clamp(0.0, 1.0);
    final proj = Offset(a.dx + t * v.dx, a.dy + t * v.dy);
    final d = (p - proj).distance;
    if (d < best) best = d;
  }
  if (best == double.infinity && poly.isNotEmpty) best = (p - poly.first).distance;
  return best;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;
  const _LegendItem({required this.color, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
