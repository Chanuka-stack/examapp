import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  Future<void> createUser(
      String uid, String email, String name, String role) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'role': role, // "super_admin", "admin", or "user"
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
