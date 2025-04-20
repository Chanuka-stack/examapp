import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AudioUploader {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload audio file and return its download URL
  static Future<String> uploadAudio({
    required String filePath,
    required String examId,
    required String studentId,
    required String questionId,
  }) async {
    try {
      // Define storage path (organize by exam/student/question)
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storagePath = 'exam_audio/$examId/$studentId/$questionId/$fileName';

      // Upload file
      final ref = _storage.ref(storagePath);
      await ref.putFile(File(filePath));

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading audio: $e");
      throw e; // Rethrow to handle in UI
    }
  }

  // Delete audio file (optional)
  static Future<void> deleteAudio(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      print("Error deleting audio: $e");
    }
  }
}
