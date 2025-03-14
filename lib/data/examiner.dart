import 'package:cloud_firestore/cloud_firestore.dart';

class Examiner {
  Future<void> createExaminer(
      String uid, String email, String name, String role) async {
    await FirebaseFirestore.instance.collection('examiners').doc(uid).set({
      'email': email,
      'name': name,
      'role': role, // "super_admin", "admin", or "user"
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool?> getIsLoginStatus(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('examiners')
          .doc(uid)
          .get();

      if (doc.exists) {
        return doc.get('isLogin') as bool?;
      } else {
        print("No examiner found with this UID.");
        return null;
      }
    } catch (e) {
      print("Error fetching isLogin: $e");
      return null;
    }
  }
}
