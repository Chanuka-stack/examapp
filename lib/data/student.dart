import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app1/data/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Student {
  // Create a new student document in Firestore
  Future<void> createStudent(
    String uid,
    String email,
    String name,
    String studentId,
    String division,
    String contactNumber,
  ) async {
    await FirebaseFirestore.instance.collection('students').doc(uid).set({
      'email': email,
      'name': name,
      'studentId': studentId,
      'division': division,
      'contactNumber': contactNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': await UserL().getCurrentUserName(),
      'isLogin': false,
      'status': 'Active' // Track if student has logged in
    });
  }

  // Get student login status
  Future<bool?> getIsLoginStatus(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .get();

      if (doc.exists) {
        return doc.get('isLogin') as bool?;
      } else {
        print("No student found with this UID.");
        return null;
      }
    } catch (e) {
      print("Error fetching student login status: $e");
      return null;
    }
  }

  // Update student information
  Future<void> updateStudent(
    String uid,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .update(updatedData);
    } catch (e) {
      print("Error updating student information: $e");
      throw e;
    }
  }

  // Delete a student
  Future<void> deleteStudent(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('students').doc(uid).delete();
    } catch (e) {
      print("Error deleting student: $e");
      throw e;
    }
  }

  // Get student by ID
  Future<Map<String, dynamic>?> getStudentById(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print("No student found with this UID.");
        return null;
      }
    } catch (e) {
      print("Error fetching student: $e");
      return null;
    }
  }

  // Get all students in a specific division
  Future<List<Map<String, dynamic>>> getStudentsByDivision(
      String division) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('division', isEqualTo: division)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching students by division: $e");
      return [];
    }
  }

  // Update login status
  Future<void> updateLoginStatus(String uid, bool status) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .update({'isLogin': status});
    } catch (e) {
      print("Error updating login status: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('students')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching students: $e");
      return [];
    }
  }

  // Get all student IDs
  Future<List<String>> getAllStudentIds() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('students').get();

      return snapshot.docs
          .map((doc) => doc.get('studentId') as String)
          .where((id) => id != null) // Filter out null values
          .toList();
    } catch (e) {
      print("Error fetching student IDs: $e");
      return [];
    }
  }

  Future<String> getCurrentStudentId() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .get();

      if (doc.exists) {
        return doc.get('studentId') as String;
      } else {
        print("No stu found with this UID.");
        return 'null';
      }
    } catch (e) {
      print("Error fetching isLogin: $e");
      return 'null';
    }
  }
}
