// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/history_item.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

enum Screen { splash, onboarding, home }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(HistoryItemAdapter());
  await Hive.openBox<HistoryItem>("historyBox");

  runApp(const BhashaDristiApp());
}

class BhashaDristiApp extends StatefulWidget {
  const BhashaDristiApp({super.key});

  @override
  State<BhashaDristiApp> createState() => _BhashaDristiAppState();
}

class _BhashaDristiAppState extends State<BhashaDristiApp> {
  Screen _currentScreen = Screen.splash;

  void _setScreen(Screen s) => setState(() => _currentScreen = s);

  ThemeData _theme() {
    const navy = Color(0xFF1C2331);
    const gold = Color(0xFFC89D29);
    const ivory = Color(0xFFFAFAF7);

    final base = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: navy,
      colorScheme: const ColorScheme.dark(primary: gold, surface: navy),
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.cormorantGaramond(
          textStyle: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.w600, color: ivory),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentScreen) {
      case Screen.splash:
        return SplashScreen(onComplete: () => _setScreen(Screen.onboarding));
      case Screen.onboarding:
        return OnboardingScreen(onComplete: () => _setScreen(Screen.home));
      case Screen.home:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bhasha Dristi",
      theme: _theme(),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildScreen(),
      ),
    );
  }
}
