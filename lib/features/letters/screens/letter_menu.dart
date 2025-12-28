import 'package:flutter/material.dart';


const _letters = [letterU, letterTa, letterPa, letterGa, letterKa, letterYa, letterRa];

class LetterHomePage extends StatelessWidget {
  const LetterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Learn Letters',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
            // Header section
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
            // Letters grid
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: _letters.length,
                  itemBuilder: (context, index) {
                    final spec = _letters[index];
                    return _LetterCard(
                      spec: spec,
                      onTap: () {
                         if (spec.jsonAsset != null && spec.jsonAsset!.isNotEmpty) {
        // Has animation, go to animation screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LetterAnimationScreen(spec: spec),
          ),
        );
      } else {
        // No animation, go directly to LetterScreen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LetterScreen(spec: spec),
          ),
        );
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

  const _LetterCard({required this.spec, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF007AFF).withValues(alpha: 0.05),
                const Color(0xFF007AFF).withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Letter display
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    spec.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Letter label
              Text(
                _getLetterName(spec.title),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C1C1E).withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

    String _getLetterName(String title) {
    switch (title) {
      case 'උ':
        return 'U';
      case 'ට':
        return 'Ta';
      case 'ප':
        return 'Pa';
      case 'ග':
        return 'Ga';
      case 'ක':
        return 'Ka';
      case 'ය':
        return 'Ya';
      case 'ර':
        return 'Ra';
      default:
        return title;
    }
  }
}

