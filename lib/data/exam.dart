import 'package:app1/data/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference _examsCollection;
  final CollectionReference _examQuestionsCollection;

  ExamFirebaseService()
      : _examsCollection = FirebaseFirestore.instance.collection('exams'),
        _examQuestionsCollection =
            FirebaseFirestore.instance.collection('exam_questions');

  // Create a new exam with basic details
  Future<String> createExam(
      {required String name,
      required String division,
      required String subject,
      required String examDate,
      required String startTime,
      required String endTime,
      required List<String> studentIds,
      required int sections,
      required int totalMarks,
      required String guidelines,
      required String status}) async {
    try {
      // Parse the date string (assuming format: dd/MM/yyyy)
      List<String> dateParts = examDate.split('/');
      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int year = int.parse(dateParts[2]);

      // Parse time strings (assuming format from TimeOfDay.format: h:mm AM/PM)
      DateTime examDateTime = DateTime(year, month, day);

      // Create the exam document with timestamps
      DocumentReference examRef = await _examsCollection.add({
        'name': name,
        'division': division,
        'subject': subject,
        'examDate': Timestamp.fromDate(examDateTime),
        'startTime': startTime, // Keep the original string for display
        'endTime': endTime, // Keep the original string for display
        'examDateTime':
            Timestamp.fromDate(examDateTime), // Add this new field for querying
        'studentIds': studentIds,
        'sections': sections,
        'totalMarks': totalMarks,
        'guidelines': guidelines,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': await UserL().getCurrentUserName(),
        'status': status, // draft, published, completed
      });

      return examRef.id;
    } catch (e) {
      print("Error creating exam: $e");
      throw e;
    }
  }

  // Save questions structure to the exam_questions collection
  Future<void> saveExamQuestions({
    required String examId,
    required List<Map<String, dynamic>> sections,
  }) async {
    try {
      await _examQuestionsCollection.doc(examId).set({
        'sections': sections,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving exam questions: $e");
      throw e;
    }
  }

  // Update an existing exam (save as draft)
  Future<void> updateExam({
    required String examId,
    required Map<String, dynamic> examData,
  }) async {
    try {
      await _examsCollection.doc(examId).update({
        ...examData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating exam: $e");
      throw e;
    }
  }

  // Save full exam as draft (both exam details and questions)
  Future<void> saveExamAsDraft({
    required String examId,
    required Map<String, dynamic> examData,
    required List<Map<String, dynamic>> sections,
  }) async {
    try {
      // Create a batch write operation
      WriteBatch batch = _firestore.batch();

      // Update exam details
      DocumentReference examRef = _examsCollection.doc(examId);
      batch.update(examRef, {
        ...examData,
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'draft',
      });

      // Update exam questions
      DocumentReference questionsRef = _examQuestionsCollection.doc(examId);
      batch.set(questionsRef, {
        'sections': sections,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print("Error saving exam draft: $e");
      throw e;
    }
  }

  // Publish an exam (change status from draft to published)
  Future<void> publishExam(String examId) async {
    try {
      await _examsCollection.doc(examId).update({
        'status': 'Active',
        'publishedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error publishing exam: $e");
      throw e;
    }
  }

  // Get exam details by ID
  Future<Map<String, dynamic>?> getExamById(String examId) async {
    try {
      DocumentSnapshot examDoc = await _examsCollection.doc(examId).get();

      if (examDoc.exists) {
        Map<String, dynamic> data = examDoc.data() as Map<String, dynamic>;
        data['id'] = examDoc.id;
        return data;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching exam details: $e");
      throw e;
    }
  }

  // Get exam sections and questions
  Future<List<Map<String, dynamic>>> getExamSections(String examId) async {
    try {
      DocumentSnapshot questionsDoc =
          await _examQuestionsCollection.doc(examId).get();

      if (questionsDoc.exists) {
        Map<String, dynamic> data = questionsDoc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['sections']);
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching exam sections: $e");
      throw e;
    }
  }

  // Get all exams (with optional filters)
  Future<List<Map<String, dynamic>>> getExams({
    String? status,
    String? division,
    String? subject,
    String? createdBy,
  }) async {
    try {
      Query query = _examsCollection;

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
      if (createdBy != null) {
        query = query.where('createdBy', isEqualTo: createdBy);
      }

      // Order by creation time (newest first)
      query = query.orderBy('createdAt', descending: true);

      // Execute query
      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
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
      QuerySnapshot snapshot = await _examsCollection
          .where('studentIds', arrayContains: studentId)
          .where('status', isEqualTo: 'published')
          .orderBy('examDate')
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

      // Delete exam document
      batch.delete(_examsCollection.doc(examId));
      // Delete exam questions document
      batch.delete(_examQuestionsCollection.doc(examId));

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print("Error deleting exam: $e");
      throw e;
    }
  }

  // Calculate exam statistics
  Future<Map<String, dynamic>> getExamStatistics(String examId) async {
    try {
      // Get exam details first
      Map<String, dynamic>? exam = await getExamById(examId);
      if (exam == null) {
        throw Exception("Exam not found");
      }

      // This is a placeholder for actual statistics calculation
      // In a real app, you would gather data from student submissions
      return {
        'totalStudents': exam['studentIds']?.length ?? 0,
        'averageScore': 0, // Would calculate from actual submissions
        'highestScore': 0,
        'lowestScore': 0,
        'completionRate': 0,
      };
    } catch (e) {
      print("Error calculating exam statistics: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingExams({
    String? division,
    String? subject,
    String? studentId,
  }) async {
    try {
      // Get current date at midnight
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      Timestamp todayTimestamp = Timestamp.fromDate(today);

      // Start with base query using the timestamp field
      Query query = _examsCollection
          .where('status', isEqualTo: 'Active')
          .where('examDateTime', isGreaterThanOrEqualTo: todayTimestamp)
          .orderBy('examDateTime');

      // Apply optional filters
      if (division != null) {
        query = query.where('division', isEqualTo: division);
      }

      if (subject != null) {
        query = query.where('subject', isEqualTo: subject);
      }

      // If studentId is provided, filter by student enrollment
      if (studentId != null) {
        query = query.where('studentIds', arrayContains: studentId);
      }

      // Execute query
      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching upcoming exams: $e");
      throw e;
    }
  }

  // Add this function to your ExamFirebaseService class
  Future<Map<String, dynamic>> getExamWithQuestions(String examId) async {
    try {
      // Get exam details
      DocumentSnapshot examDoc = await _examsCollection.doc(examId).get();

      if (!examDoc.exists) {
        throw Exception("Exam not found");
      }

      // Get exam questions
      DocumentSnapshot questionsDoc =
          await _examQuestionsCollection.doc(examId).get();

      Map<String, dynamic> examData = examDoc.data() as Map<String, dynamic>;
      examData['id'] = examDoc.id;

      // Add questions data if available
      if (questionsDoc.exists) {
        Map<String, dynamic> questionsData =
            questionsDoc.data() as Map<String, dynamic>;
        examData['sections'] = questionsData['sections'] ?? [];
      } else {
        examData['sections'] = [];
      }

      return examData;
    } catch (e) {
      print("Error fetching exam with questions: $e");
      throw e;
    }
  }
}
