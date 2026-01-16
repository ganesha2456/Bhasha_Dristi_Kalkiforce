// lib/screens/voice_input_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen>
    with SingleTickerProviderStateMixin {
  bool isListening = false;
  String recognizedText = "Tap the microphone to start speaking";

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.8,
      upperBound: 1.1,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void toggleRecording() {
    setState(() => isListening = !isListening);

    if (isListening) {
      recognizedText = "Listening...";
      _pulseController.repeat(reverse: true);
      // TODO → integrate speech logic here later
    } else {
      recognizedText = "Processing audio...";
      _pulseController.stop();
      _pulseController.reset();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1C2331);
    const gold = Color(0xFFC89D29);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Input"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.4,
            colors: [
              Color(0x221C2331),
              Color(0xFF0F1522),
              Color(0xFF05070D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Glass text panel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.12),
                            Colors.white.withOpacity(0.03),
                          ],
                        ),
                      ),
                      child: Text(
                        recognizedText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Glass mic button
              GestureDetector(
                onTap: toggleRecording,
                child: ScaleTransition(
                  scale: _pulseController,
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isListening ? 140 : 120,
                        height: isListening ? 140 : 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: gold.withOpacity(0.9),
                            width: 3,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            if (isListening)
                              BoxShadow(
                                color: gold.withOpacity(0.6),
                                blurRadius: 35,
                                spreadRadius: 6,
                              ),
                          ],
                        ),
                        child: Icon(
                          isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          size: 54,
                          color: gold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Tap to start / stop recording",
                style: TextStyle(
                  color: Colors.white54,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
