import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A service class that handles image selection functionality
/// using the image_picker package.
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Singleton instance
  static final ImagePickerService _instance = ImagePickerService._internal();

  /// Factory constructor to return the singleton instance
  factory ImagePickerService() {
    return _instance;
  }

  /// Private constructor for singleton pattern
  ImagePickerService._internal();

  /// Pick an image from the gallery
  /// Returns a [File] object or null if no image was selected
  Future<File?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Take a photo using the camera
  /// Returns a [File] object or null if no photo was taken
  Future<File?> pickImageFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Pick multiple images from the gallery
  /// Returns a list of [File] objects
  Future<List<File>> pickMultipleImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    return pickedFiles.map((xFile) => File(xFile.path)).toList();
  }

  /// Pick a video from the gallery
  /// Returns a [File] object or null if no video was selected
  Future<File?> pickVideoFromGallery({int? maxDuration}) async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: maxDuration != null ? Duration(seconds: maxDuration) : null,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Record a video using the camera
  /// Returns a [File] object or null if no video was recorded
  Future<File?> pickVideoFromCamera({int? maxDuration}) async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: maxDuration != null ? Duration(seconds: maxDuration) : null,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Show a dialog to select an image source (camera or gallery)
  /// Returns a [File] object or null if no image was selected
  Future<File?> showImageSourceDialog(
    BuildContext context, {
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    File? image;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () async {
                    //Navigator.of(context).pop();
                    image = await pickImageFromGallery(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                    );
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () async {
                    image = await pickImageFromCamera(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    return image;
  }

  /// Method to handle lost data when app is killed while picking
  Future<List<File>> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    final List<File> files = [];

    if (response.isEmpty) {
      return files;
    }

    if (response.files != null) {
      for (final XFile xFile in response.files!) {
        files.add(File(xFile.path));
      }
    }

    return files;
  }
}
