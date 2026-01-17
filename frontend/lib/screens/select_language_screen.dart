// lib/screens/select_language_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../services/ocr_service.dart'; // Import OCR service
import 'result_screen.dart';

class SelectLanguageScreen extends StatefulWidget {
  final File imageFile;

  const SelectLanguageScreen({super.key, required this.imageFile});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String? targetLang;
  bool isLoading = false;

  final List<String> languages = [
    "Latin",
    "Devanagari",
    "Tamil",
    "Bengali",
    "Odia",
    "Gujarati",
    "Punjabi",
    "Kannada",
    "Telugu",
    "Malayalam",
  ];

  Future<void> processImage() async {
    if (targetLang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a language")),
      );
      return;
    }

    setState(() => isLoading = true);

    final result =
        await OCRService.processImage(widget.imageFile.path, targetLang!);

    setState(() => isLoading = false);

    print("📌 RESULT DATA:");
    print(result);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          text: result["extracted_text"] ?? "",
          language: result["language"] ?? "",
          targetLanguage: result["normalized_language"] ?? targetLang!,
          romanText: result["transliterated"] ?? "",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Select Target Script"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: languages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.3,
                ),
                itemBuilder: (_, i) {
                  final lang = languages[i];
                  final selected = targetLang == lang;

                  return GestureDetector(
                    onTap: () => setState(() => targetLang = lang),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? Colors.amber : Colors.white12,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? Colors.amber : Colors.white24,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        lang.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : processImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Continue", style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
