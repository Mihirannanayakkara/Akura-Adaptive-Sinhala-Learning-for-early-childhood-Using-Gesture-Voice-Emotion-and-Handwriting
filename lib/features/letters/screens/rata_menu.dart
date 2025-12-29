import 'package:flutter/material.dart';
import '../../letters/models/letter_spec.dart';
import '../../letters/pages/letter_animation_screen.dart';
import '../../letters/pages/letter_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _rataShapes = [
  shape1,
  shape2,
  shape3,
  shape4,
  shape5,
  shape6,
  shape7,
  shape8,
  shape9,
  shape10,
  shape11,
  shape12,
  shape13,
];

class RataHomePage extends StatelessWidget {
  const RataHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'රට උගනිමු',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF34C759)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Countries & Shapes',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E).withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trace and explore fun shapes',
                    style: TextStyle(
                      fontSize: 17,
                      color: const Color(0xFF3C3C43).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  itemCount: _rataShapes.length,
                  // Inside GridView.builder
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Expert change: 3 items per row
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio:
                        0.85, // Slightly taller than wide to fit text + icon
                  ),
                  itemBuilder: (context, index) {
                    final spec = _rataShapes[index];
                    return _RataCard(
                      spec: spec,
                      index: index,
                      onTap: () {
                        if (spec.jsonAsset != null &&
                            spec.jsonAsset!.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LetterAnimationScreen(spec: spec),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
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

//
// ---------------- Card ----------------
//

class _RataCard extends StatefulWidget {
  final LetterSpec spec;
  final int index;
  final VoidCallback onTap;

  const _RataCard({
    required this.spec,
    required this.index,
    required this.onTap,
  });

  @override
  State<_RataCard> createState() => _RataCardState();
}

class _RataCardState extends State<_RataCard> {
  bool _isPressed = false;

  // 1. Defined pastel background colors
  static const _colors = [
    Color(0xFFA2E1CC), // Mint Green
    Color(0xFFFFD1A1), // Soft Orange
    Color(0xFFD1C4E9), // Soft Purple
    Color(0xFFB3E5FC), // Sky Blue
  ];

  // 2. Defined darker matching stroke colors for better UI harmony
  static const _strokeColors = [
    Color(0xFF2D6A4F), // Dark Green
    Color(0xFF874110), // Dark Brown
    Color(0xFF4A148C), // Dark Purple
    Color(0xFF01579B), // Dark Blue
  ];

  @override
  Widget build(BuildContext context) {
    // Determine colors based on index
    final baseColor = _colors[widget.index % _colors.length];
    final strokeColor = _strokeColors[widget.index % _strokeColors.length];

    // Convert Flutter color to Hex string for SVG
    final hexColor = '#${strokeColor.value.toRadixString(16).substring(2)}';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        // Moves the card down 4 pixels when pressed to simulate a button
        margin: EdgeInsets.only(
          top: _isPressed ? 4 : 0,
          bottom: _isPressed ? 0 : 4,
        ),
        decoration: BoxDecoration(
          color: baseColor,
          // Thick white border makes it look like a physical sticker
          border: Border.all(color: Colors.white, width: 4),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 6), // The solid "depth" shadow
                blurRadius: 0,
              ),
          ],
        ),
        child: Column(
          children: [
            // Top spacing to balance the stars at the bottom
            const SizedBox(height: 12),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SvgPicture.string(
                    '''<svg viewBox="0 0 250 250" xmlns="http://www.w3.org/2000/svg">
      <g transform="translate(25, 25)"> 
        <path d="${widget.spec.svgData}" 
              fill="none" 
              stroke="$hexColor" 
              stroke-width="14" 
              stroke-linecap="round" 
              stroke-linejoin="round" />
      </g>
     </svg>''',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Stars section moved slightly up with padding
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                    Icons.star,
                    size: 18,
                    // Using a very faint version of black for empty stars for a cleaner look
                    color: i < 2
                        ? Colors.amber
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
