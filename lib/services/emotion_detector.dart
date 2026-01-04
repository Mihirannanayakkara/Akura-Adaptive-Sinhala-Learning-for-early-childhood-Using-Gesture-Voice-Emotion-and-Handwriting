import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class EmotionResult {
  final String label;
  final double confidence;
  final DateTime at;

  EmotionResult({
    required this.label,
    required this.confidence,
    required this.at,
  });
}

class EmotionDetector {
  EmotionDetector._();
  static final EmotionDetector instance = EmotionDetector._();

  // -----------------------
  // MODEL CONFIG
  // -----------------------
  static const String modelAssetPath = 'assets/models/emotion_detector_mnv2.tflite';
  static const String labelsAssetPath = "assets/models/emotion_labels.txt";

  // If your training used [-1, 1] normalization: (pix - 127.5) / 127.5
  static const double normMean = 127.5;
  static const double normStd = 127.5;

  // Predict once every 5 seconds
  static const int minMsBetweenInferences = 5000;

  // If you KNOW your training data was mirrored selfie-style, set true.
  static const bool mirrorFrontCameraForModel = false;
  // -----------------------

  final StreamController<EmotionResult> _results = StreamController.broadcast();
  Stream<EmotionResult> get results => _results.stream;

  Interpreter? _interpreter;
  List<String> _labels = const [];

  CameraController? _camera;
  CameraController? get cameraController => _camera;

  final InterpreterOptions _opts = InterpreterOptions()..threads = 2;

  int _refCount = 0;
  bool _streaming = false;
  bool _busy = false;
  DateTime _lastInfer = DateTime.fromMillisecondsSinceEpoch(0);

  // Serialize start/stop to avoid races when navigating quickly.
  Future<void> _op = Future.value();
  Future<void> _serialize(Future<void> Function() fn) {
    _op = _op.then((_) => fn()).catchError((_) {});
    return _op;
  }

  Future<void> init() async {
    _interpreter ??= await Interpreter.fromAsset(modelAssetPath, options: _opts);
    _labels = await _loadLabels();
  }

  Future<void> start() {
    _refCount++;
    return _serialize(() async {
      if (_refCount > 1) return;
      await init();
      await _startCameraStream();
    });
  }

  Future<void> stop() {
    _refCount = math.max(0, _refCount - 1);
    return _serialize(() async {
      if (_refCount > 0) return;
      await _stopCameraStream();
    });
  }

  Future<void> disposeHard() async {
    _refCount = 0;
    await _serialize(() async {
      await _stopCameraStream();
      _interpreter?.close();
      _interpreter = null;
      if (!_results.isClosed) {
        await _results.close();
      }
    });
  }

  Future<List<String>> _loadLabels() async {
    try {
      final raw = await rootBundle.loadString(labelsAssetPath);
      return raw
          .split(RegExp(r"\r?\n"))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (_) {
      return const ["neutral", "happy", "sad", "angry"];
    }
  }

  Future<void> _startCameraStream() async {
    if (_streaming) return;

    final cams = await availableCameras();
    if (cams.isEmpty) {
      throw StateError("No cameras available on this device/emulator.");
    }

    final cam = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cams.first,
    );

    final controller = CameraController(
      cam,
      // ✅ IMPORTANT: lower resolution = fewer buffers + far less CPU work
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _camera = controller;
    await controller.initialize();

    _streaming = true;
    await controller.startImageStream(_onFrame);
  }

  Future<void> _stopCameraStream() async {
    final c = _camera;
    _camera = null;

    if (c == null) return;

    try {
      if (_streaming) {
        await c.stopImageStream();
      }
    } catch (_) {}

    _streaming = false;

    try {
      await c.dispose();
    } catch (_) {}
  }

  void _onFrame(CameraImage frame) {
    // MUST return fast, otherwise ImageReader buffers fill and Android freaks out.
    if (_busy) return;

    final now = DateTime.now();
    if (now.difference(_lastInfer).inMilliseconds < minMsBetweenInferences) return;

    _busy = true;
    _lastInfer = now;

    try {
      final interpreter = _interpreter;
      if (interpreter == null) return;

      final inputTensor = interpreter.getInputTensor(0);
      final inputShape = inputTensor.shape; // [1,h,w,c]
      if (inputShape.length != 4) return;

      final inH = inputShape[1];
      final inW = inputShape[2];

      final outputTensor = interpreter.getOutputTensor(0);
      final outShape = outputTensor.shape;
      final classes = outShape.length == 2 ? outShape[1] : outShape[0];

      final c = _camera;
      final isFront = c?.description.lensDirection == CameraLensDirection.front;

      final rotation = _computeRotationDegrees(c);
      final mirror = isFront && mirrorFrontCameraForModel;

      // ✅ Big win: generate model input directly from YUV (crop+resize+rotate in one pass)
      final inputData = _yuv420ToFloatInput(
        frame,
        outW: inW,
        outH: inH,
        rotationDegrees: rotation,
        mirrorHorizontally: mirror,
      );

      final input = inputData.reshape([1, inH, inW, 3]);
      final output = List.filled(classes, 0.0).reshape([1, classes]);

      interpreter.run(input, output);

      final raw = (output[0] as List).map((e) => (e as num).toDouble()).toList();
      if (raw.isEmpty) return;

      final probs = _maybeSoftmax(raw);

      var bestIdx = 0;
      var best = probs[0];
      for (int i = 1; i < probs.length; i++) {
        if (probs[i] > best) {
          best = probs[i];
          bestIdx = i;
        }
      }

      final label = (bestIdx < _labels.length) ? _labels[bestIdx] : "class_$bestIdx";
      _results.add(EmotionResult(label: label, confidence: best, at: now));
    } catch (_) {
      // swallow; never block the stream
    } finally {
      _busy = false;
    }
  }

  int _computeRotationDegrees(CameraController? c) {
    if (c == null || kIsWeb) return 0;

    final sensor = c.description.sensorOrientation;
    final device = _deviceOrientationToDegrees(c.value.deviceOrientation);
    final isFront = c.description.lensDirection == CameraLensDirection.front;

    // Keep your previous compensation logic
    return isFront ? (sensor + device) % 360 : (sensor - device + 360) % 360;
  }

  int _deviceOrientationToDegrees(DeviceOrientation o) {
    switch (o) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeLeft:
        return 90;
      case DeviceOrientation.portraitDown:
        return 180;
      case DeviceOrientation.landscapeRight:
        return 270;
      default:
        return 0;
    }
  }

  Float32List _yuv420ToFloatInput(
    CameraImage image, {
    required int outW,
    required int outH,
    required int rotationDegrees,
    required bool mirrorHorizontally,
  }) {
    final rawW = image.width;
    final rawH = image.height;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;

    final yRowStride = yPlane.bytesPerRow;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    // Rotated dimensions (what "upright" image would look like)
    final rotW = (rotationDegrees == 90 || rotationDegrees == 270) ? rawH : rawW;
    final rotH = (rotationDegrees == 90 || rotationDegrees == 270) ? rawW : rawH;

    // Center crop in rotated space
    final side = math.min(rotW, rotH);
    final cropX = (rotW - side) / 2.0;
    final cropY = (rotH - side) / 2.0;

    final out = Float32List(outW * outH * 3);
    var idx = 0;

    for (int oy = 0; oy < outH; oy++) {
      final ry = cropY + (oy + 0.5) * side / outH;

      for (int ox = 0; ox < outW; ox++) {
        var rx = cropX + (ox + 0.5) * side / outW;

        if (mirrorHorizontally) {
          rx = (rotW - 1) - rx;
        }

        // Nearest-neighbor sample point in rotated space
        final xr = rx.floor().clamp(0, rotW - 1);
        final yr = ry.floor().clamp(0, rotH - 1);

        // Map rotated(xr, yr) -> raw(x, y)
        int sx, sy;
        switch (rotationDegrees) {
          case 90:
            // rotated W=rawH, H=rawW
            sx = yr;
            sy = (rawH - 1) - xr;
            break;
          case 180:
            sx = (rawW - 1) - xr;
            sy = (rawH - 1) - yr;
            break;
          case 270:
            sx = (rawW - 1) - yr;
            sy = xr;
            break;
          case 0:
          default:
            sx = xr;
            sy = yr;
            break;
        }

        sx = sx.clamp(0, rawW - 1);
        sy = sy.clamp(0, rawH - 1);

        final yIndex = sy * yRowStride + sx;
        final uvIndex = (sy >> 1) * uvRowStride + (sx >> 1) * uvPixelStride;

        final yp = yBytes[yIndex].toDouble();
        final up = uBytes[uvIndex].toDouble() - 128.0;
        final vp = vBytes[uvIndex].toDouble() - 128.0;

        // YUV -> RGB
        var r = yp + 1.403 * vp;
        var g = yp - 0.344 * up - 0.714 * vp;
        var b = yp + 1.770 * up;

        r = r.clamp(0.0, 255.0);
        g = g.clamp(0.0, 255.0);
        b = b.clamp(0.0, 255.0);

        out[idx++] = (r - normMean) / normStd;
        out[idx++] = (g - normMean) / normStd;
        out[idx++] = (b - normMean) / normStd;
      }
    }

    return out;
  }

  List<double> _maybeSoftmax(List<double> v) {
    final sum = v.fold<double>(0.0, (a, b) => a + b);
    if (sum > 0.85 && sum < 1.15 && v.every((x) => x >= 0 && x <= 1.0)) {
      return v;
    }

    final m = v.reduce(math.max);
    final exps = v.map((x) => math.exp(x - m)).toList();
    final z = exps.fold<double>(0.0, (a, b) => a + b);
    return exps.map((e) => e / (z == 0 ? 1 : z)).toList();
  }
}
