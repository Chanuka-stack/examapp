import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app1/data/user.dart';

class Exam {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new exam document with basic details
  Future<String> createExam({
    required String name,
    required String division,
    required String subject,
    required String examDate,
    required String startTime,
    required String endTime,
    required List<String> studentIds,
    required int sections,
    required int totalMarks,
    required String guidelines,
  }) async {
    try {
      // Create the main exam document
      DocumentReference examRef = await _firestore.collection('exams').add({
        'name': name,
        'division': division,
        'subject': subject,
        'examDate': examDate,
        'startTime': startTime,
        'endTime': endTime,
        'studentIds': studentIds,
        'sections': sections,
        'totalMarks': totalMarks,
        'guidelines': guidelines,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': await UserL().getCurrentUserName(),
        'status': 'draft', // draft, published, completed
      });

      return examRef.id;
    } catch (e) {
      print("Error creating exam: $e");
      throw e;
    }
  }

  // Save questions in a separate document
  Future<void> saveExamQuestions({
    required String examId,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      await _firestore.collection('exam_questions').doc(examId).set({
        'questions': questions,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving exam questions: $e");
      throw e;
    }
  }

  // Save exam as draft (update existing exam)
  Future<void> saveExamAsDraft({
    required String examId,
    required Map<String, dynamic> examData,
    List<Map<String, dynamic>>? questions,
  }) async {
    try {
      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Update the main exam document
      DocumentReference examRef = _firestore.collection('exams').doc(examId);
      Map<String, dynamic> updateData = {
        ...examData,
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'draft',
      };
      batch.update(examRef, updateData);

      // If questions are provided, update them as well
      if (questions != null) {
        DocumentReference questionsRef =
            _firestore.collection('exam_questions').doc(examId);
        batch.set(questionsRef, {
          'questions': questions,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print("Error saving exam draft: $e");
      throw e;
    }
  }

  // Publish exam (change status from draft to published)
  Future<void> publishExam(String examId) async {
    try {
      await _firestore.collection('exams').doc(examId).update({
        'status': 'published',
        'publishedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error publishing exam: $e");
      throw e;
    }
  }

  // Get exam details
  Future<Map<String, dynamic>?> getExam(String examId) async {
    try {
      DocumentSnapshot examDoc =
          await _firestore.collection('exams').doc(examId).get();

      if (examDoc.exists) {
        return examDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching exam: $e");
      throw e;
    }
  }

  // Get exam questions
  Future<List<Map<String, dynamic>>> getExamQuestions(String examId) async {
    try {
      DocumentSnapshot questionsDoc =
          await _firestore.collection('exam_questions').doc(examId).get();

      if (questionsDoc.exists) {
        Map<String, dynamic> data = questionsDoc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['questions']);
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching exam questions: $e");
      throw e;
    }
  }

  // Get all exams (with optional filters)
  Future<List<Map<String, dynamic>>> getAllExams({
    String? status,
    String? division,
    String? subject,
  }) async {
    try {
      Query query = _firestore.collection('exams');

      // Apply filters if provided
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      if (division != null) {
        query = query.where('division', isEqualTo: division);
      }
      if (subject != null) {
        query = query.where('subject', isEqualTo: subject);
      }

      // Execute query
      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching exams: $e");
      throw e;
    }
  }

  // Get exams by student ID
  Future<List<Map<String, dynamic>>> getExamsByStudent(String studentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('exams')
          .where('studentIds', arrayContains: studentId)
          .where('status', isEqualTo: 'published')
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching student exams: $e");
      throw e;
    }
  }

  // Delete an exam and its questions
  Future<void> deleteExam(String examId) async {
    try {
      WriteBatch batch = _firestore.batch();

      // Delete the main exam document
      batch.delete(_firestore.collection('exams').doc(examId));

      // Delete the questions document
      batch.delete(_firestore.collection('exam_questions').doc(examId));

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print("Error deleting exam: $e");
      throw e;
    }
  }
}
