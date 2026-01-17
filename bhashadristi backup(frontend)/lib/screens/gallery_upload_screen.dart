import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

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

  // 🌐 Supported Target Scripts
  final Map<String, String> _languageScripts = {
    "Hindi (Devanagari)": "Devanagari",
    "Bengali": "Bengali",
    "Odia": "Odia",
    "Gujarati": "Gujarati",
    "Punjabi (Gurmukhi)": "Gurmukhi",
    "Tamil": "Tamil",
    "Telugu": "Telugu",
    "Kannada": "Kannada",
    "Malayalam": "Malayalam",
    "English (Latin)": "Latin",
  };

  // ✅ Enter immersive mode during crop
  Future<void> _enterCropMode() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  // ✅ Restore system UI after crop
  Future<void> _exitCropMode() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  // 📸 Pick + Crop Image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      await _enterCropMode();

      final cropped = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Crop Image",
            toolbarColor: const Color(0xFF1C2331),
            toolbarWidgetColor: const Color(0xFFC89D29),
            activeControlsWidgetColor: const Color(0xFFC89D29),
            statusBarColor: const Color(0xFF1C2331),
            hideBottomControls: false,
            lockAspectRatio: false,
          ),
        ],
      );

      await _exitCropMode();

      if (cropped == null) return;
      if (!mounted) return;

      setState(() => _selectedImage = File(cropped.path));
    } catch (e) {
      await _exitCropMode();
      debugPrint("Crop Error: $e");
    }
  }

  // 🌍 Select Target Language Bottom Sheet
  Future<String?> _selectTargetLanguage() {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1C2331),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: Text(
                  "Select Target Script",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC89D29),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._languageScripts.entries.map(
                (entry) => ListTile(
                  title: Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white54,
                  ),
                  onTap: () => Navigator.pop(context, entry.value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🚀 OCR Processing
  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    final targetLang = await _selectTargetLanguage();
    if (targetLang == null) return;

    setState(() => _isProcessing = true);

    try {
      final result =
          await OCRService.processImage(_selectedImage!.path, targetLang);

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
            targetLanguage: targetLang,
            romanText: roman,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1C2331);
    const gold = Color(0xFFC89D29);

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        title: const Text("Upload Image"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: _selectedImage == null
            ? ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text("Choose Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: navy,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                    width: 280,
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
                          horizontal: 26, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isProcessing ? "Processing..." : "Select Language →",
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
