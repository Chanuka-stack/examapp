import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserL {
  Future<void> createUser(
      String uid, String email, String name, String role) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'role': role, // "super_admin", "admin", or "user"
      'createdAt': FieldValue.serverTimestamp(),
      'isFirstLogin': true,
    });
  }

  Future<String> getUserRole() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      return userDoc['role'];
    } else {
      throw Exception("User role not found!");
    }
  }

  Future<bool?> getIsFirstLoginStatus(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        return doc.get('isFirstLogin') as bool?;
      } else {
        print("No examiner found with this UID.");
        return null;
      }
    } catch (e) {
      print("Error fetching isLogin: $e");
      return null;
    }
  }

  Future<void> updateFirstLoginState(bool isFirstLoggedIn) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'isFirstLogin': isFirstLoggedIn});

      print("Login state updated successfully for user: $uid");
    } catch (e) {
      print("Error updating login state: $e");
      throw Exception("Failed to update login state: $e");
    }
  }
}
