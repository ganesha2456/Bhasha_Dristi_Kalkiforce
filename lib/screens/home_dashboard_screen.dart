import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeDashboardScreen extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onHistory;
  final VoidCallback onUpload;
  final VoidCallback onTextInput;
  final VoidCallback onVoiceInput;

  const HomeDashboardScreen({
    super.key,
    required this.onCamera,
    required this.onHistory,
    required this.onUpload,
    required this.onTextInput,
    required this.onVoiceInput,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1C2331);
    const gold = Color(0xFFC89D29);
    const ivory = Color(0xFFFAFAF7);

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Bhasha Dristi",
          style: GoogleFonts.cormorantGaramond(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: gold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _btn(
                Icons.camera_alt_rounded, "Start Camera", gold, navy, onCamera),
            const SizedBox(height: 18),
            _btn(Icons.photo_library_rounded, "Upload from Gallery",
                Colors.white12, ivory, onUpload),
            const SizedBox(height: 18),
            _btn(Icons.edit_note_rounded, "Enter Text Manually", Colors.white12,
                ivory, onTextInput),
            const SizedBox(height: 18),
            _btn(Icons.mic_rounded, "Voice Input", Colors.white12, ivory,
                onVoiceInput),
            const SizedBox(height: 26),
            _chip(Icons.history_rounded, "History", onHistory),
          ],
        ),
      ),
    );
  }

  Widget _btn(
      IconData icon, String label, Color bg, Color tc, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: bg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: tc, size: 24),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: tc, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber),
          color: Colors.white12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
