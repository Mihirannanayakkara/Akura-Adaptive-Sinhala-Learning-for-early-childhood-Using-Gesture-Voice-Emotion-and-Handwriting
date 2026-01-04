import 'package:flutter/material.dart';

class MiniGame1Page extends StatelessWidget {
  const MiniGame1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Learning Activities',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007AFF)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.games_rounded,
                  color: Color(0xFFFF9500),
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Coming Soon!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Fun letter challenges and interactive learning activities.',
                style: TextStyle(
                  fontSize: 17,
                  color: const Color(0xFF3C3C43).withValues(alpha: 0.6),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
