import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/ocr_service.dart';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  bool isRecording = false;
  bool isProcessing = false;
  bool recorderReady = false;

  String recognizedText = "Tap the mic and speak";
  String targetLanguage = "Hindi";

  final List<String> languages = [
    "Hindi",
    "Tamil",
    "Telugu",
    "Bengali",
    "Kannada",
    "Malayalam",
    "Gujarati",
    "Punjabi",
  ];

  late AnimationController _pulseController;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.85,
      upperBound: 1.1,
    );
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) return;

    await _recorder.openRecorder();
    recorderReady = true;
    setState(() {});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  // ▶️ Start Recording
  Future<void> startRecording() async {
    if (!recorderReady) return;

    final dir = await getTemporaryDirectory();
    _audioPath = "${dir.path}/voice.wav";

    await _recorder.startRecorder(
      toFile: _audioPath,
      codec: Codec.pcm16WAV,
    );

    _pulseController.repeat(reverse: true);

    setState(() {
      isRecording = true;
      recognizedText = "Listening...";
    });
  }

  // ⏹ Stop Recording
  Future<void> stopRecording() async {
    _pulseController.stop();
    _pulseController.reset();

    await _recorder.stopRecorder();

    setState(() {
      isRecording = false;
      isProcessing = true;
      recognizedText = "Processing...";
    });

    if (_audioPath == null) return;

    final response =
        await OCRService.processVoice(_audioPath!, targetLanguage);

    if (response.containsKey("error")) {
      setState(() {
        recognizedText = "❌ ${response["error"]}";
      });
    } else {
      setState(() {
        recognizedText =
            response["transliterated_text"] ?? "No result";
      });
    }

    setState(() => isProcessing = false);
  }

  void toggleMic() async {
    if (isRecording) {
      await stopRecording();
    } else if (!isProcessing) {
      await startRecording();
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC89D29);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Voice Transliteration"),
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
              const SizedBox(height: 16),

              // 🌍 Language Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: DropdownButtonFormField<String>(
                  value: targetLanguage,
                  dropdownColor: const Color(0xFF1C2331),
                  items: languages
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang,
                              style:
                                  const TextStyle(color: Colors.white)),
                        ),
                      )
                      .toList(),
                  onChanged: isRecording
                      ? null
                      : (val) =>
                          setState(() => targetLanguage = val!),
                  decoration: const InputDecoration(
                    labelText: "Target Script",
                    labelStyle:
                        TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 📝 Result Panel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  recognizedText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),

              const Spacer(),

              // 🎤 Mic Button
              GestureDetector(
                onTap: toggleMic,
                child: ScaleTransition(
                  scale: _pulseController,
                  child: CircleAvatar(
                    radius: isRecording ? 70 : 55,
                    backgroundColor: gold.withOpacity(0.15),
                    child: Icon(
                      isRecording
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      size: 56,
                      color: gold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                isRecording
                    ? "Tap to stop"
                    : isProcessing
                        ? "Processing..."
                        : "Tap to speak",
                style:
                    const TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
