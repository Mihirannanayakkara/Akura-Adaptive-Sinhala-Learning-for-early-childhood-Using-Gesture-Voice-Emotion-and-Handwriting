import 'package:flutter/material.dart';
import 'package:letter_train/features/home/pages/Rata_menu.dart';
import 'letter_menu.dart';
import '../../mini_games/pages/mini_game_1_page.dart';
import '../../mini_games/pages/mini_game_2_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS system background color
      appBar: AppBar(
      
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF007AFF)), // iOS blue
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Header section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose an Activity',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E).withValues(alpha: 0.9),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn Sinhala letters or play fun mini games',
                    style: TextStyle(
                      fontSize: 17,
                      color: const Color(0xFF3C3C43).withValues(alpha: 0.6),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMenuCard(
                      context: context,
                      icon: Icons.flag_rounded,
                      title: 'රටා උගනිමු',
                      subtitle: 'Learn about countries and shapes',
                      color: const Color(0xFF34C759), 
                      onTap: () {
                         Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RataHomePage()),
                      );
                      },
                    ),
      
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.school_rounded,
                    title: 'අකුරු උගනිමු',
                    subtitle: 'Learn to trace Sinhala letters',
                    color: const Color(0xFF007AFF), // iOS blue
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LetterHomePage()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.games_rounded,
                    title: 'Mini Game 1',
                    subtitle: 'Coming soon - Fun letter challenges',
                    color: const Color(0xFFFF9500), // iOS orange
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MiniGame1Page()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.sports_esports_rounded,
                    title: 'Mini Game 2',
                    subtitle: 'Coming soon - Interactive learning',
                    color: const Color(0xFFFF9500), // iOS orange
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MiniGame2Page()),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Text(
                '© 2025 AKURA',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF8E8E93).withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFF3C3C43).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFC7C7CC),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
