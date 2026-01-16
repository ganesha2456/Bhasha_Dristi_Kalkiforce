import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _titles = [
    "भाषा दृष्टि",       // Hindi
    "ଭାଷା ଦୃଷ୍ଟି",       // Odia
    "భాషా దృష్టి",       // Telugu
    "ಭಾಷಾ ದೃಷ್ಟಿ",       // Kannada
    "ഭാഷാ ദൃഷ്ടി",       // Malayalam
    "ভাষা দৃষ্টি",       // Bengali
    "Bhasha Dristi",     // English
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _titles.length;
      });
    });

    Future.delayed(const Duration(seconds: 5), () {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🌑 Dark premium gradient background
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.4,
                colors: [
                  Color(0x221C2331), // subtle glow
                  Color(0xFF0F1522), // deep navy
                  Color(0xFF05070D), // near black
                ],
              ),
            ),
          ),

          // ✨ Glass animated title
          Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 650),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.94, end: 1.0).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _titles[_currentIndex],
                  key: ValueKey(_titles[_currentIndex]),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerif(
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.white.withOpacity(0.88),

                    // 🌈 Glass glow effect
                    shadows: const [
                      Shadow(
                        blurRadius: 20,
                        color: Color(0x88FFFFFF),
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 34,
                        color: Color(0x22C89D29),
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Subtitle
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "See Language. Feel Meaning.",
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  letterSpacing: 1.6,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
