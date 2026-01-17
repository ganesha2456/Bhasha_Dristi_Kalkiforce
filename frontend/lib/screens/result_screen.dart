// lib/screens/result_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatelessWidget {
  final String text;
  final String language;
  final String targetLanguage;
  final String romanText;

  const ResultScreen({
    super.key,
    required this.text,
    required this.language,
    required this.targetLanguage,
    required this.romanText,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0E1117);
    const gold = Color(0xFFC89D29);
    const silver = Colors.white70;

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Result",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heading("Detected Language"),
                    _value(language.toUpperCase()),
                    _heading("Target Script"),
                    _value(targetLanguage.toUpperCase()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heading("Extracted Text"),
                    _longBox(text),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heading("Transliterated"),
                    _longBox(romanText),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    icon: Icons.copy_rounded,
                    label: "Copy",
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: romanText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Copied")),
                      );
                    },
                  ),
                  _actionButton(
                    icon: Icons.share_rounded,
                    label: "Share",
                    onTap: () {
                      Share.share(romanText);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- COMPONENTS ----------
  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _value(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _longBox(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        content.isEmpty ? "No Content" : content,
        style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.4),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: const Color(0xFFC89D29),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFC89D29)),
        ),
      ),
    );
  }
}
