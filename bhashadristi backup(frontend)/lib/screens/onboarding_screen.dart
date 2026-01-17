import 'dart:ui';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1C2331);
    const gold = Color(0xFFC89D29);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [navy, Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              _glassCard(
                child: Column(
                  children: const [
                    Text(
                      "Welcome to Bhasha Dristi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Transliterate any Indian script instantly using camera, voice or text.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _featureCard(Icons.camera_alt, "Scan Text",
                  "Capture text from signboards and books."),
              _featureCard(Icons.mic, "Voice Input",
                  "Speak and transliterate instantly."),
              _featureCard(Icons.translate, "Multi Script",
                  "Supports Indian language scripts."),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: onComplete,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [gold, Color(0xFFFFD166)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Get Started",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: _glassCard(
        child: Row(
          children: [
            Icon(icon, color: Colors.amberAccent, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
