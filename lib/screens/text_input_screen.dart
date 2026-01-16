// lib/screens/text_input_screen.dart

import 'package:flutter/material.dart';
import '../services/ocr_service.dart';
import 'result_screen.dart';

class TextInputScreen extends StatefulWidget {
  const TextInputScreen({super.key});

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final TextEditingController controller = TextEditingController();

  String selectedLang = "Hindi";
  bool isLoading = false;

  final List<String> languages = [
    "English",
    "Hindi",
    "Bengali",
    "Odia",
    "Tamil",
    "Telugu",
    "Kannada",
    "Malayalam",
    "Gujarati",
    "Punjabi",
    "Marathi",
    "Urdu",
  ];

  Future<void> processTextInput() async {
    if (controller.text.trim().isEmpty) return;

    setState(() => isLoading = true);

    final result = await OCRService.processText(
      controller.text.trim(),
      selectedLang,
    );

    setState(() => isLoading = false);

    if (result.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${result["error"]}")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          text: controller.text,
          language: result["language"] ?? "",
          romanText: result["transliterated"] ?? "",
          targetLanguage: selectedLang,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC89D29);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Transliteration"),
        backgroundColor: gold,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Enter text to transliterate",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 🌍 Language Dropdown
            DropdownButtonFormField<String>(
              value: selectedLang,
              decoration: const InputDecoration(
                labelText: "Select Target Language",
                border: OutlineInputBorder(),
              ),
              items: languages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => selectedLang = value!),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : processTextInput,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isLoading ? "Processing..." : "Transliterate"),
            ),
          ],
        ),
      ),
    );
  }
}
