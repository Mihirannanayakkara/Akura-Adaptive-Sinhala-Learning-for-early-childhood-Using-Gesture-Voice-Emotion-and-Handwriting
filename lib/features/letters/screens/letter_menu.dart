import 'package:flutter/material.dart';
import '../../letters/models/letter_spec.dart';
import '../../letters/pages/letter_screen.dart';
import '../../letters/pages/letter_animation_screen.dart';

const _letters = [letterU, letterTa, letterGa,  letterYa, letterRa, letterDa,letterPa];

class LetterHomePage extends StatelessWidget {
  const LetterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'අකුරු උගනිමු',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF007AFF)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_letters.length} letters',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF007AFF),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sinhala Letters',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E).withValues(alpha: 0.9),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Practice tracing beautiful Sinhala characters',
                    style: TextStyle(
                      fontSize: 17,
                      color: const Color(0xFF3C3C43).withValues(alpha: 0.6),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8, 
                  ),
                  itemCount: _letters.length,
                  itemBuilder: (context, index) {
                    final spec = _letters[index];
                    // Example progress pattern
                    double progressLevel = ((index + 1) * 0.23) % 1.1;

                    return _LetterCard(
                      spec: spec,
                      progress: progressLevel,
                      onTap: () {
                        if (spec.jsonAsset != null && spec.jsonAsset!.isNotEmpty) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => LetterAnimationScreen(spec: spec),
                          ));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => LetterScreen(spec: spec),
                          ));
                        }
                      },
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
}

class _LetterCard extends StatelessWidget {
  final LetterSpec spec;
  final VoidCallback onTap;
  final double progress;

  const _LetterCard({
    required this.spec,
    required this.onTap,
    required this.progress,
  });

  String _getImagePath(String title) {
    switch (title) {
      case 'උ': return 'assets/images/eagle.png';
      case 'ට': return 'assets/images/tyre.png';
      case 'ප': return 'assets/images/lamp.png';
      case 'ග': return 'assets/images/tree.png';
      case 'ක': return 'assets/images/ka_object.png';
      case 'ය': return 'assets/images/key.png';
      case 'ර': return 'assets/images/rambutan.png';
      case 'ද': return 'assets/images/dara.png';
      default: return 'assets/images/placeholder.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Standard subtle shadow
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent, // Must be transparent to see the gradient
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
        child: Container(
          // This creates the soft blue-to-white background look
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE3F2FD), // Light Blue at the top (Material Blue 50)
                Colors.white,      // Pure White at the bottom
              ],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // 1. Image Section
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      // Inner container color set to transparent to respect the card's gradient
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2), 
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          _getImagePath(spec.title),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: Color(0x33007AFF),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. The Letter
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        spec.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ),
                  ),

                  // 3. The Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: const Color(0xFFE5E5EA),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}