import 'package:flutter/material.dart';

import 'camera_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'home_dashboard_screen.dart';
import 'gallery_upload_screen.dart';
import 'text_input_screen.dart';
import 'voice_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void switchTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void openGalleryUpload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GalleryUploadScreen()),
    );
  }

  void openTextInput(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TextInputScreen()),
    );
  }

  void openVoiceInput(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VoiceInputScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeDashboardScreen(
            onCamera: () => switchTab(1),
            onHistory: () => switchTab(2), // history tab switch
            onUpload: () => openGalleryUpload(context),
            onTextInput: () => openTextInput(context),
            onVoiceInput: () => openVoiceInput(context),
          ),
           CameraScreen(),
          const HistoryScreen(), // MUST BE index 2
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: switchTab,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_rounded), label: "Camera"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), label: "History"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded), label: "Settings"),
        ],
      ),
    );
  }
}
