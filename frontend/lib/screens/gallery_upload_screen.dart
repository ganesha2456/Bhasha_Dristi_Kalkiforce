// lib/screens/gallery_upload_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ocr_service.dart';
import '../services/history_manager.dart';
import 'result_screen.dart';

class GalleryUploadScreen extends StatefulWidget {
  const GalleryUploadScreen({super.key});

  @override
  State<GalleryUploadScreen> createState() => _GalleryUploadScreenState();
}

class _GalleryUploadScreenState extends State<GalleryUploadScreen> {
  File? _selectedImage;
  bool _isProcessing = false;

  // BACKEND TARGET SCRIPT OPTIONS
  final Map<String, String> _languageScripts = {
    "Devanagari": "Devanagari",
    "Bengali": "Bengali",
    "Odia": "Odia",
    "Gujarati": "Gujarati",
    "Punjabi": "Gurmukhi",

    "Tamil": "Tamil",
    "Telugu": "Telugu",
    "Kannada": "Kannada",
    "Malayalam": "Malayalam",

    "English": "ISO",
    "Latin": "ISO",
  };

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<String?> _selectTargetLanguage() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1C2331), // navy
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose Target Script",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC89D29), // gold
                  ),
                ),
                const SizedBox(height: 10),
                ..._languageScripts.entries.map(
                  (entry) => ListTile(
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    onTap: () => Navigator.pop(context, entry.value),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    final target = await _selectTargetLanguage();
    if (target == null) return;

    setState(() => _isProcessing = true);

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Processing image...")),
      );

      final result = await OCRService.processImage(_selectedImage!.path, target);

      final extracted = result["extracted_text"] ?? "No text found";
      final detectedLang = result["language"] ?? "Unknown";
      final roman = result["transliterated"] ?? extracted;

      await HistoryManager.addHistory(
        sourceText: extracted,
        translatedText: roman,
        type: "gallery",
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            text: extracted,
            language: detectedLang,
            targetLanguage: target,
            romanText: roman,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1C2331);
    const gold = Color(0xFFC89D29);
    const ivory = Color(0xFFFAFAF7);

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        title: const Text("Upload from Gallery"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ivory),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _selectedImage == null
            ? ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_rounded, color: navy),
                label: const Text("Choose Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: navy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.file(
                    _selectedImage!,
                    width: 300,
                    height: 350,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _processImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isProcessing ? "Processing..." : "Process Image",
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
