// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = true;
  bool autoSaveHistory = true;

  void clearHistory() {
    // TODO: Integrate shared_prefs or local memory clear function
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("History Cleared")),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC89D29);
    const ivory = Color(0xFFFAFAF7);
    const navy = Color(0xFF1C2331);

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Preferences",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: gold,
            ),
          ),
          const SizedBox(height: 12),

          // Theme Toggle
          _settingTile(
            title: "Dark Mode",
            subtitle: "Use dark theme across the app",
            trailing: Switch(
              value: darkMode,
              onChanged: (v) => setState(() => darkMode = v),
              activeColor: gold,
            ),
          ),

          // Auto save history
          _settingTile(
            title: "Save History Automatically",
            subtitle: "Store OCR & Transliteration results locally",
            trailing: Switch(
              value: autoSaveHistory,
              onChanged: (v) => setState(() => autoSaveHistory = v),
              activeColor: gold,
            ),
          ),

          const SizedBox(height: 16),
          Text(
            "Data",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: gold,
            ),
          ),
          const SizedBox(height: 12),

          // Clear history button
          ListTile(
            tileColor: Colors.white10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("Clear History", style: TextStyle(color: ivory)),
            trailing:
                const Icon(Icons.delete_forever, color: Colors.redAccent),
            onTap: clearHistory,
          ),

          const SizedBox(height: 22),
          Text(
            "About",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: gold,
            ),
          ),
          const SizedBox(height: 10),
          _settingTile(
            title: "Bhasha Dristi",
            subtitle: "Version 1.0.0",
            trailing: const Icon(Icons.info_outline, color: ivory),
          ),
        ],
      ),
    );
  }

  Widget _settingTile(
      {required String title,
      required String subtitle,
      required Widget trailing}) {
    return ListTile(
      tileColor: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: trailing,
    );
  }
}
