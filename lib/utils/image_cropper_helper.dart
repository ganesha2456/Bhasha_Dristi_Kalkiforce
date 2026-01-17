import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropperHelper {
  static Future<File?> cropImage(String path) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      compressQuality: 95,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: const Color(0xFF1C2331),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFFC89D29),
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (cropped == null) return null;
    return File(cropped.path);
  }
}
