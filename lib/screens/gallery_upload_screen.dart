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

  // ✅ Enter immersive mode (hide status + nav safely)
  Future<void> _enterCropMode() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  // ✅ Restore system UI fully after crop
  Future<void> _exitCropMode() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      // 🔒 Hide system bars before opening cropper
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

      // 🔓 Always restore UI
      await _exitCropMode();

      if (cropped == null) return;

      if (!mounted) return;
      setState(() => _selectedImage = File(cropped.path));
    } catch (e) {
      await _exitCropMode(); // safety restore
      debugPrint("Crop Error: $e");
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() => _isProcessing = true);

    try {
      final result =
          await OCRService.processImage(_selectedImage!.path, "Latin");

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
            targetLanguage: "Latin",
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
