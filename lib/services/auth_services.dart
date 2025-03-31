import 'dart:ffi';

import 'package:app1/data/examiner.dart';
import 'package:app1/data/student.dart';
import 'package:app1/pages/auth_pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../pages/main_pages/home_screen.dart';
import '../data/user.dart';
import '../pages/auth_pages/create_new_password.dart';

class AuthService {
  Future<void> signup(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await Future.delayed(const Duration(seconds: 1));

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const LoginPage()));
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {}
  }

  Future<void> signin(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await Future.delayed(const Duration(seconds: 1));

      String uid = FirebaseAuth.instance.currentUser!.uid;
      UserL user = UserL();
      bool? isFirstLogin = await user.getIsFirstLoginStatus(uid);
      if (isFirstLogin == true) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const CreatePassword()));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {}
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
  }

  Future<void> updateUserPassword(String newPassword) async {
    try {
      // Get user by ID (for admin SDK only) or use currentUser
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Update the password
        await user.updatePassword(newPassword);
        print("Password updated successfully for user:");
        return;
      } else {
        // Note: Regular Firebase client SDK cannot update other users' passwords
        // Only the user themselves can update their password, or you need Firebase Admin SDK
        throw Exception(
            "Cannot update password: Current user does not match requested user ID");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // If the user's credential is too old, we need to reauthenticate
        throw Exception("Please sign in again before updating your password");
      } else {
        throw Exception("Error updating password: ${e.message}");
      }
    } catch (e) {
      throw Exception("Failed to update password: $e");
    }
  }

  Future<void> signupExaminer({
    required String email,
    required String password,
    required String name,
    required String examinerId,
    required String division,
    required String contactNumber,
    required BuildContext context,
  }) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Get the UID of the created user
      User? user = userCredential.user;
      if (user == null) {
        throw Exception("User creation failed. Please try again.");
      }

      String uid = user.uid; //  Get newly created user's UID
      print("New Examiner UID: $uid");

      // Create user document in Firestore under "users" collection
      UserL userL = UserL();
      await userL.createUser(
          uid, email, name, 'admin'); // Assuming role is 'examiner'

      // Create examiner document in Firestore under "examiners" collection
      Examiner examiner = Examiner();
      await examiner.createExaminer(
          uid, email, name, division, examinerId, contactNumber);

      await Future.delayed(const Duration(seconds: 2));

      //Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      print(e);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> signupStudent({
    required String email,
    required String password,
    required String name,
    required String studentId,
    required String division,
    required String contactNumber,
    required BuildContext context,
  }) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Get the UID of the created user
      User? user = userCredential.user;
      if (user == null) {
        throw Exception("User creation failed. Please try again.");
      }

      String uid = user.uid; //  Get newly created user's UID
      print("New Student UID: $uid");

      // Create user document in Firestore under "users" collection
      UserL userL = UserL();
      await userL.createUser(uid, email, name, 'student');

      // Create examiner document in Firestore under "examiners" collection
      Student student = Student();
      await student.createStudent(
          uid, email, name, division, studentId, contactNumber);

      await Future.delayed(const Duration(seconds: 2));

      //Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      print(e);
    } catch (e) {
      print("Error: $e");
    }
  }
}
