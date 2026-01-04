import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:confetti/confetti.dart';
import 'package:animate_do/animate_do.dart';
import 'lesson_data.dart';

class PracticeScreen extends StatefulWidget {
  final LessonItem lessonItem;

  const PracticeScreen({super.key, required this.lessonItem});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with TickerProviderStateMixin {
  late final AudioRecorder _audioRecorder;
  final FlutterTts _flutterTts = FlutterTts();
  late ConfettiController _confettiController;

  bool _isRecording = false;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  String? _errorMessage;
  bool _isSuccess = false;

  List<Map<String, String>> _mistakes = [];

  // ⚠️ CHANGE THIS IP
  final String _serverUrl = 'http://10.0.2.2:8000/analyze';

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _setupChildFriendlyVoice();

    // Auto-play introduction
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (mounted) {
        await _speak("කියන්න..."); // "Say..."
        await Future.delayed(const Duration(milliseconds: 1000));
        await _speak(widget.lessonItem.word);
      }
    });
  }

  Future<void> _setupChildFriendlyVoice() async {
    await _flutterTts.setLanguage("si-LK");
    await _flutterTts.setSpeechRate(0.35);
    await _flutterTts.setPitch(1.3);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _errorMessage = null;
      _analysisResult = null;
      _isSuccess = false;
      _mistakes = [];
    });

    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/temp_audio.wav';
        const config = RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1);
        await _audioRecorder.start(config, path: filePath);
      }
    } catch (e) {
      setState(() => _errorMessage = "Mic Error");
    }
  }

  Future<void> _stopAndAnalyze() async {
    try {
      final String? path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _isAnalyzing = true;
      });

      if (path != null) await _uploadAudio(path);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = "Error";
      });
    }
  }

  Future<void> _uploadAudio(String filePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_serverUrl));
      request.fields['expected_word'] = widget.lessonItem.word;
      request.files.add(await http.MultipartFile.fromPath('audio', filePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final decoded = jsonDecode(respStr);
        var resultData = decoded['result'];
        if (resultData is String) resultData = jsonDecode(resultData);

        final rawLetters = resultData['letters'] as List<dynamic>;
        final mergedSyllables = _mergeSinhalaSyllables(rawLetters);

        // --- ZERO CORRECT LOGIC ---
        bool hasAtLeastOneCorrect = mergedSyllables.any((s) => s['status'] == 'correct');

        if (!hasAtLeastOneCorrect) {
          if (mounted) {
            setState(() {
              _isAnalyzing = false;
              _analysisResult = null;
              _mistakes = [];
              _errorMessage = "I didn't hear anything... 🙉";
            });
            _speak("මට ඇහුණේ නෑ. ආයේ කියන්න.");
          }
          return;
        }
        // -------------------------

        List<Map<String, String>> detectedMistakes = [];
        bool perfect = true;

        for (var s in mergedSyllables) {
          if (s['status'] == 'mispronounced') {
            perfect = false;
            detectedMistakes.add({
              'type': 'wrong',
              'said': s['predicted_char'],
              'should_be': s['expected_char']
            });
          } else if (s['status'] == 'missing') {
            perfect = false;
            detectedMistakes.add({
              'type': 'missing',
              'said': '',
              'should_be': s['expected_char']
            });
          }
        }

        if (mounted) {
          setState(() {
            _analysisResult = resultData;
            _isAnalyzing = false;
            _isSuccess = perfect;
            _mistakes = detectedMistakes;
          });

          if (perfect) {
            _confettiController.play();
            _speak("හරිම ෂෝක්! ඔයා දිනුම්!");
          } else {
            if (detectedMistakes.isNotEmpty) {
              var m = detectedMistakes.first;
              if (m['type'] == 'wrong') {
                _speak("අයියෝ! '${m['said']}' නෙමෙයි... '${m['should_be']}' කියන්න.");
              } else {
                _speak("ඔයාට '${m['should_be']}' මග හැරුණා. ආයේ කියමු.");
              }
            }
          }
        }
      } else {
        if (mounted) setState(() { _errorMessage = "Server Error"; _isAnalyzing = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = "Connection Error"; _isAnalyzing = false; });
    }
  }

  List<Map<String, dynamic>> _mergeSinhalaSyllables(List<dynamic> rawLetters) {
    List<Map<String, dynamic>> merged = [];
    final modifiers = ['්', 'ා', 'ැ', 'ෑ', 'ි', 'ී', 'ු', 'ූ', 'ෘ', 'ෙ', 'ේ', 'ෛ', 'ො', 'ෝ', 'ෞ', 'ෟ', 'ෲ', 'ෳ', 'ං', 'ඃ'];

    for (var item in rawLetters) {
      String expChar = item['expected'] ?? "";
      String predChar = item['predicted'] ?? "";
      String status = item['status'];

      if (status == 'extra') continue;

      bool isModifier = modifiers.contains(expChar) || modifiers.contains(predChar);

      if (merged.isNotEmpty && isModifier) {
        var last = merged.last;
        last['expected_char'] = (last['expected_char'] ?? "") + expChar;
        if (predChar.isNotEmpty) {
          last['predicted_char'] = (last['predicted_char'] ?? "") + predChar;
        }
        if (status != 'correct') {
          last['status'] = 'mispronounced';
        }
      } else {
        merged.add({
          'expected_char': expChar,
          'predicted_char': predChar.isEmpty ? expChar : predChar,
          'status': status,
        });
      }
    }

    for (var m in merged) {
      if (m['predicted_char'] == m['expected_char'] && m['status'] == 'mispronounced') {
        m['status'] = 'correct';
      }
    }

    return merged;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displaySyllables = [];
    if (_analysisResult != null) {
      displaySyllables = _mergeSinhalaSyllables(_analysisResult!['letters']);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Color Blob
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(color: widget.lessonItem.color.withOpacity(0.2), shape: BoxShape.circle),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Navbar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // --- MAIN CONTENT AREA ---
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          // 1. The Image with a nice border
                          Hero(
                            tag: widget.lessonItem.letter,
                            child: Container(
                              width: 240,
                              height: 240,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
                                  ],
                                  border: Border.all(color: widget.lessonItem.color.withOpacity(0.5), width: 4)
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  widget.lessonItem.imagePath,
                                  fit: BoxFit.cover,
                                  // 🔥 FIXED ERROR HERE: Use standard icon if image fails
                                  errorBuilder: (c, o, s) => const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // 2. The Word Card (Initial State) or Result State
                          if (_analysisResult == null)
                          // Initial Flashcard Style
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              decoration: BoxDecoration(
                                color: widget.lessonItem.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    widget.lessonItem.word,
                                    style: const TextStyle(fontSize: 60, fontFamily: 'Iskoola Pota', fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                      widget.lessonItem.englishMeaning,
                                      style: TextStyle(fontSize: 22, color: Colors.grey[600], fontWeight: FontWeight.w500)
                                  ),
                                ],
                              ),
                            )
                          else
                          // Result Text (Colored)
                            _buildMergedTextDisplay(displaySyllables),

                          const SizedBox(height: 30),

                          // 3. Feedback Cards (Mistakes or Success)
                          if (_mistakes.isNotEmpty)
                            ..._mistakes.map((m) => FadeInUp(
                                duration: const Duration(milliseconds: 600),
                                child: _buildMistakeCard(m)
                            )),

                          // Success Card
                          if (_isSuccess && _analysisResult != null)
                            FadeInUp(
                              duration: const Duration(milliseconds: 600),
                              child: _buildSuccessCard(),
                            ),

                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Bottom Error/Status Messages
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
                      child: Text(_errorMessage!, style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),

                if (_isAnalyzing) const Text("Thinking... 🐇", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                if (_isRecording) const VoiceWaveformWidget(),
                const SizedBox(height: 10),

                // 5. Controls
                if (_analysisResult == null || _isRecording)
                  _buildMicButton()
                else if (!_isSuccess)
                  _buildRetakeButton()
                else
                  _buildSuccessButtons() // "Next" Button
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSuccessCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green.shade200, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
          ]
      ),
      child: Column(
        children: [
          Bounce(
            infinite: true,
            child: const Icon(Icons.star_rounded, size: 80, color: Colors.orangeAccent),
          ),
          const SizedBox(height: 10),
          const Text(
            "නියමයි! (Awesome!)",
            style: TextStyle(fontSize: 28, fontFamily: 'Iskoola Pota', fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 5),
          Text(
            "You said it perfectly!",
            style: TextStyle(fontSize: 16, color: Colors.green.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildMergedTextDisplay(List<Map<String, dynamic>> syllables) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 60, fontFamily: 'Iskoola Pota', fontWeight: FontWeight.bold, color: Colors.black),
        children: syllables.map<InlineSpan>((item) {
          String char = item['expected_char'];
          String status = item['status'];

          if (status == 'mispronounced' || status == 'missing') {
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: ZoomLetter(char: char, color: Colors.redAccent),
            );
          } else {
            return TextSpan(text: char, style: const TextStyle(color: Colors.green));
          }
        }).toList(),
      ),
    );
  }

  Widget _buildMistakeCard(Map<String, String> mistake) {
    bool isMissing = mistake['type'] == 'missing';
    Color rightSideColor = isMissing ? Colors.red : Colors.green;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.shade100, width: 2),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              if (!isMissing)
                const Icon(Icons.close, color: Colors.red, size: 24),

              Text(
                  isMissing ? "?" : mistake['said']!,
                  style: const TextStyle(fontSize: 32, color: Colors.red, fontFamily: 'Iskoola Pota', fontWeight: FontWeight.bold)
              ),
              Text(isMissing ? "Not Pronounced" : "You Said", style: const TextStyle(fontSize: 10, color: Colors.red)),
            ],
          ),

          const Icon(Icons.arrow_forward_rounded, color: Colors.orange, size: 30),

          Column(
            children: [
              if (!isMissing)
                Icon(Icons.check, color: rightSideColor, size: 24),

              Text(
                  mistake['should_be']!,
                  style: TextStyle(fontSize: 32, color: rightSideColor, fontFamily: 'Iskoola Pota', fontWeight: FontWeight.bold)
              ),
              Text("Correct", style: TextStyle(fontSize: 10, color: rightSideColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return Column(
      children: [
        GestureDetector(
          onLongPress: _startRecording,
          onLongPressUp: _stopAndAnalyze,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isRecording ? 110 : 100,
            width: _isRecording ? 110 : 100,
            decoration: BoxDecoration(
                color: _isRecording ? Colors.redAccent : widget.lessonItem.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: widget.lessonItem.color.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
                ]
            ),
            child: Icon(
              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white, size: 50,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          _isRecording ? "Listening..." : "Hold to Speak",
          style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRetakeButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() { _analysisResult = null; _mistakes.clear(); _errorMessage = null; });
            _speak(widget.lessonItem.word);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text("Try Again", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSuccessButtons() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text("Done!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// --- HELPER CLASSES ---
class ZoomLetter extends StatefulWidget {
  final String char;
  final Color color;
  const ZoomLetter({super.key, required this.char, required this.color});

  @override
  State<ZoomLetter> createState() => _ZoomLetterState();
}

class _ZoomLetterState extends State<ZoomLetter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Text(widget.char, style: TextStyle(color: widget.color, fontSize: 60, fontFamily: 'Iskoola Pota', fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}

class VoiceWaveformWidget extends StatefulWidget {
  const VoiceWaveformWidget({super.key});

  @override
  State<VoiceWaveformWidget> createState() => _VoiceWaveformWidgetState();
}

class _VoiceWaveformWidgetState extends State<VoiceWaveformWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = sin((_controller.value * 2 * pi) + (index * 1.0));
              final height = 15.0 + (15.0 * value.abs());
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: height,
                decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)),
              );
            },
          );
        }),
      ),
    );
  }
}