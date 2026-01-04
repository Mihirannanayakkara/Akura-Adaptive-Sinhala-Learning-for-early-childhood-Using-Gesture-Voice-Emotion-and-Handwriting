import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import '../models/combine_shape.dart'; 
import 'letter_painters.dart';
import 'package:lottie/lottie.dart';

class CombineShapeScreen extends StatefulWidget {
  final String letterTitle;
  const CombineShapeScreen({super.key, required this.letterTitle});

  
  static CombineShapeSpec? getSpec(String title) {
    if (title == "උ") return combineshape1;
    if (title == "ය") return combineshape2;
    if (title == "ර") return combineshape3;
    if (title == "ද") return combineshape4;
    return null;
  }

  @override
  State<CombineShapeScreen> createState() => _CombineShapeScreenState();
}

class _CombineShapeScreenState extends State<CombineShapeScreen> {
  late CombineShapeSpec activeSpec;
  bool _isInitialized = false;

  // Tracing State
  final List<List<Offset>> strokes = [];
  int currentStage = 1; 
  int currentRound = 1;
  int attemptCount = 0;
  bool _isDrawingActive = false;

  // Haptic State Variables
  bool _isOffPath = false;
  int _offPathSinceMs = 0;
  int _lastHapticMs = 0;
  Timer? _buzzTimer;
  int _buzzInterval = 0;

  // Path & Scaling State
  Path? _fittedPath;
  List<Offset> _samples = [];
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Rect _lastStageSize = Rect.zero;

  @override
  void initState() {
    super.initState();
    _loadSpec();
  }

  void _loadSpec() {
    final spec = CombineShapeScreen.getSpec(widget.letterTitle);
    
    if (spec != null) {
      activeSpec = spec;
      setState(() {
        _isInitialized = true;
      });
    } else {
      // Emergency fallback: If we somehow landed here without a spec, go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  void _clear() {
    setState(() {
      strokes.clear();
      currentStage = 1;
      currentRound = 1;
      attemptCount = 0;
      _isDrawingActive = false;
    });
  }

  void _handleSuccess() {
    if (currentStage == 1) {
      setState(() { 
        currentStage = 2; 
        attemptCount = 0; 
      });
      HapticFeedback.mediumImpact();
      _showSnack("Well done! Now trace the second part.");
    } else {
      if (currentRound < 2) {
        setState(() {
          currentRound = 2;
          currentStage = 1; 
          strokes.clear();
          attemptCount = 0;
        });
        HapticFeedback.mediumImpact();
        _showSnack("Great! One more round to go.");
      } else {
        HapticFeedback.heavyImpact();
        _showSuccessDialog();
      }
    }
  }

  void _calculateScaling(Size size) {
    final basePath = parseSvgPathData(activeSpec.svgData);
    final bounds = basePath.getBounds();
    
    _scale = min(size.width / bounds.width, size.height / bounds.height) * 0.9;
    _offset = Offset(
      (size.width - bounds.width * _scale) * 0.5 - bounds.left * _scale,
      (size.height - bounds.height * _scale) * 0.5 - bounds.top * _scale,
    );

    final matrix = Float64List.fromList([
      _scale, 0, 0, 0,
      0, _scale, 0, 0,
      0, 0, 1, 0,
      _offset.dx, _offset.dy, 0, 1,
    ]);

    _fittedPath = basePath.transform(matrix);
    _samples = _samplePath(_fittedPath!, 1200);
  }

  List<Offset> _samplePath(Path path, int n) {
    final metrics = path.computeMetrics().toList();
    final totalLen = metrics.fold<double>(0, (sum, m) => sum + m.length);
    final result = <Offset>[];
    for (int i = 0; i <= n; i++) {
      final t = (i / n) * totalLen;
      double cur = 0;
      for (final m in metrics) {
        if (t <= cur + m.length) {
          result.add(m.getTangentForOffset(t - cur)!.position);
          break;
        }
        cur += m.length;
      }
    }
    return result;
  }

  @override
  void dispose() {
    _stopBuzz();
    super.dispose();
  }

  void _maybeHapticOffPath(Offset p) {
    if (_samples.isEmpty) return;
    double minD = double.infinity;
    for (final s in _samples) {
      final d = (s - p).distance;
      if (d < minD) minD = d;
    }
    final minDim = min(_lastStageSize.width, _lastStageSize.height);
    final thr = minDim * 0.05; 
    final off = minD > thr;
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
    double r = ((minD - thr) / thr).clamp(0.0, 1.5);
    int cooldown = r < 0.3 ? 100 : (r < 0.8 ? 70 : 45);
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

  void _onPointerDown(Offset localPosition) {
    final targetStartBase = currentStage == 1 ? activeSpec.startBase1 : activeSpec.startBase2;
    if (targetStartBase == null) return;
    final targetStart = targetStartBase.first * _scale + _offset;
    final dist = (localPosition - targetStart).distance;
    if (dist < 60.0) {
      setState(() {
        _isDrawingActive = true;
        strokes.add([localPosition]);
      });
    } else {
      _isDrawingActive = false;
      HapticFeedback.lightImpact();
      _showSnack("Start at the green flag for Part $currentStage!");
    }
  }

  void _onPointerMove(Offset localPosition) {
    if (!_isDrawingActive || strokes.isEmpty) return;
    setState(() => strokes.last.add(localPosition));
    _maybeHapticOffPath(localPosition);
  }

  void _onPointerUp() {
    _stopBuzz();
    if (!_isDrawingActive || strokes.isEmpty || strokes.last.isEmpty) return;
    final targetEndBase = currentStage == 1 ? activeSpec.endBase1 : activeSpec.endBase2;
    if (targetEndBase == null) return;
    final targetEnd = targetEndBase.last * _scale + _offset;
    final userEnd = strokes.last.last;
    if ((userEnd - targetEnd).distance < 55.0) {
      _handleSuccess();
    } else {
      _handleFailure();
    }
    _isDrawingActive = false;
  }

  void _handleFailure() {
    attemptCount++;
    HapticFeedback.vibrate();
    if (attemptCount >= 2) {
      _clear();
      _showSnack("Let's try again from the start!");
    } else {
      setState(() => strokes.removeLast());
      _showSnack("Close! Try tracing that shape again.");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 1500)),
    );
  }

  void _showSuccessDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // Allows the Lottie to overflow if needed
        children: [
          // 1. White Card Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // NEW: Trophy/Badge Lottie Animation
                Lottie.network(
                  'https://assets10.lottiefiles.com/packages/lf20_touohxv0.json',
                  height: 120,
                  animate: true,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Excellent Work",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "You completed tracing letter ${widget.letterTitle} shapes",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF3A3A3C)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 41, 117, 215),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Continue", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Confetti Lottie Animation (Background/Overlay)
          // We wrap this in a Positioned.fill to ensure it overlays the card
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.network(
                'https://assets9.lottiefiles.com/packages/lf20_u4yrau.json',
                repeat: false,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text('රටා සමග අකුරු - Learning', 
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 0, 0, 0))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _clear, icon: const Icon(Icons.refresh_rounded), color: const Color(0xFF007AFF)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Learning Mode', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('Follow the stroke shape for ${widget.letterTitle}', style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    Positioned(
                      top: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF007AFF).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text('Round $currentRound/2', style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final stageSize = Size(box.maxWidth, box.maxHeight);
                      if (_lastStageSize.size != stageSize) {
                        _lastStageSize = Offset.zero & stageSize;
                        _calculateScaling(stageSize);
                      }
                      final activeStart = (currentStage == 1 ? activeSpec.startBase1 : activeSpec.startBase2)?.map((p) => p * _scale + _offset).toList() ?? [];
                      final activeEnd = (currentStage == 1 ? activeSpec.endBase1 : activeSpec.endBase2)?.map((p) => p * _scale + _offset).toList() ?? [];
                      return Listener(
                        onPointerDown: (e) => _onPointerDown(e.localPosition),
                        onPointerMove: (e) => _onPointerMove(e.localPosition),
                        onPointerUp: (_) => _onPointerUp(),
                        child: CustomPaint(
                          size: stageSize,
                          painter: SkeletonPainter(_fittedPath, activeStart, activeEnd),
                          foregroundPainter: DrawPainter(strokes, _samples, 1.0),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _LegendItem(color: Color(0xFF22C55E), label: 'Start here', icon: Icons.flag_rounded),
                  SizedBox(width: 18),
                  _LegendItem(color: Color(0xFFDC2626), label: 'End here', icon: Icons.outlined_flag_rounded),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}