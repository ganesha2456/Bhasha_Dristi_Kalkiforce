import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../utils/image_cropper_helper.dart';
import 'select_language_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  bool _flashOn = false;
  int _cameraIndex = 0;
  bool _isTakingPhoto = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras![_cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> toggleFlash() async {
    if (_controller == null) return;

    setState(() => _flashOn = !_flashOn);
    await _controller!.setFlashMode(
      _flashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> switchCamera() async {
    _cameraIndex = (_cameraIndex + 1) % _cameras!.length;
    await initCamera();
  }

  Future<void> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isTakingPhoto = true);

    try {
      final pic = await _controller!.takePicture();

      final cropped =
          await ImageCropperHelper.cropImage(pic.path);

      if (cropped == null) {
        setState(() => _isTakingPhoto = false);
        return;
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelectLanguageScreen(imageFile: cropped),
        ),
      ).then((_) {
        if (mounted) setState(() => _isTakingPhoto = false);
      });
    } catch (e) {
      debugPrint("Capture Error: $e");
      setState(() => _isTakingPhoto = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: CameraPreview(_controller!)),

            if (!_isTakingPhoto)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: toggleFlash,
                        icon: Icon(
                          _flashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      GestureDetector(
                        onTap: captureImage,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 5),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: switchCamera,
                        icon: const Icon(
                          Icons.cameraswitch_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
