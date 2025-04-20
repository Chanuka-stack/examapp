import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ExamAudioStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a single audio file to Firebase Storage
  Future<String> uploadAudio({
    required String examId,
    required String studentId,
    required String filePath,
    required int questionIndex,
    required int subQuestionIndex,
  }) async {
    try {
      // Create reference to the file location in storage
      final fileName = path.basename(filePath);
      final destination =
          'exam_responses/$examId/$studentId/audio_q${questionIndex + 1}_${subQuestionIndex + 1}_$fileName';

      final ref = _storage.ref().child(destination);

      // Upload the file
      final uploadTask = ref.putFile(File(filePath));

      // Wait for the upload to complete and get the download URL
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading audio: $e');
      throw e;
    }
  }

  // Delete an audio file from Firebase Storage
  Future<void> deleteAudio(String fileUrl) async {
    try {
      // Get reference from the full URL
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting audio: $e');
      throw e;
    }
  }
}
