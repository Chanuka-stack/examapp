import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app1/data/user.dart';

class Division {
  // Create a new division with image upload
  Future<void> createDivision(
      String name, String code, List<String> subjects, File? imageFile) async {
    try {
      // Create a document with auto-generated ID
      final docRef = FirebaseFirestore.instance.collection('divisions').doc();

      // Map to store division data
      final Map<String, dynamic> divisionData = {
        'name': name,
        'code': code,
        'subjects': subjects,
        'imageUrl': null, // Will be updated if image is uploaded
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': await UserL().getCurrentUserName(),
        'status': 'Active',
      };

      // Upload image if provided
      if (imageFile != null) {
        final String imagePath =
            'divisions/${docRef.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference storageRef =
            FirebaseStorage.instance.ref().child(imagePath);

        // Upload the file to Firebase Storage
        final UploadTask uploadTask = storageRef.putFile(imageFile);
        final TaskSnapshot taskSnapshot = await uploadTask;

        // Get the download URL
        final String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Update the division data with image URL
        divisionData['imageUrl'] = imageUrl;
      }

      // Save division data to Firestore
      await docRef.set(divisionData);
    } catch (e) {
      print("Error creating division: $e");
      throw e; // Rethrow to handle in the UI
    }
  }

  Future<void> createDivisionWithoutImage(
      String name, String code, List<String> subjects, File? imageFile) async {
    try {
      // Create a document with auto-generated ID
      final docRef = FirebaseFirestore.instance.collection('divisions').doc();

      // Map to store division data
      final Map<String, dynamic> divisionData = {
        'name': name,
        'code': code,
        'subjects': subjects,
        'imageUrl':
            'https://www.google.com/url?sa=i&url=https%3A%2F%2Fsudheerappd.blogspot.com%2F2017%2F07%2Fbeauty-of-uok.html&psig=AOvVaw3Nc7voXrJvL1_LtzucQB6S&ust=1743639199752000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCNjGqqqIuIwDFQAAAAAdAAAAABAE', // Will be updated if image is uploaded
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': await UserL().getCurrentUserName(),
        'status': 'Active',
      };

      // Upload image if provide

      // Save division data to Firestore
      await docRef.set(divisionData);
    } catch (e) {
      print("Error creating division: $e");
      throw e; // Rethrow to handle in the UI
    }
  }

  // Update an existing division
  Future<void> updateDivision(
      String divisionId,
      String name,
      String code,
      List<String> subjects,
      File? newImageFile,
      bool removeExistingImage) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('divisions').doc(divisionId);
      final DocumentSnapshot doc = await docRef.get();

      if (!doc.exists) {
        throw Exception("Division not found");
      }

      final Map<String, dynamic> updateData = {
        'name': name,
        'code': code,
        'subjects': subjects,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': await UserL().getCurrentUserName(),
      };

      // Handle image updates
      if (removeExistingImage) {
        // Get existing image URL
        final String? existingImageUrl = doc.get('imageUrl') as String?;

        // Delete the existing image from storage if it exists
        if (existingImageUrl != null) {
          try {
            final Reference imageRef =
                FirebaseStorage.instance.refFromURL(existingImageUrl);
            await imageRef.delete();
          } catch (e) {
            print("Error deleting existing image: $e");
          }
        }

        // Set imageUrl to null to indicate no image
        updateData['imageUrl'] = null;
      }

      // Upload new image if provided
      if (newImageFile != null) {
        final String imagePath =
            'divisions/${divisionId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference storageRef =
            FirebaseStorage.instance.ref().child(imagePath);

        // Upload the file to Firebase Storage
        final UploadTask uploadTask = storageRef.putFile(newImageFile);
        final TaskSnapshot taskSnapshot = await uploadTask;

        // Get the download URL
        final String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Update the division data with the new image URL
        updateData['imageUrl'] = imageUrl;
      }

      // Update document in Firestore
      await docRef.update(updateData);
    } catch (e) {
      print("Error updating division: $e");
      throw e;
    }
  }

  Future<void> updateDivisionWithoutImage(
    String divisionId,
    String name,
    String code,
    List<String> subjects,
  ) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('divisions').doc(divisionId);
      final DocumentSnapshot doc = await docRef.get();

      if (!doc.exists) {
        throw Exception("Division not found");
      }

      final Map<String, dynamic> updateData = {
        'name': name,
        'code': code,
        'subjects': subjects,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': await UserL().getCurrentUserName(),
      };

      // Update document in Firestore
      await docRef.update(updateData);
    } catch (e) {
      print("Error updating division: $e");
      throw e;
    }
  }

  // Delete a division
  Future<void> deleteDivision(String divisionId) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('divisions').doc(divisionId);
      final DocumentSnapshot doc = await docRef.get();

      if (!doc.exists) {
        throw Exception("Division not found");
      }

      // Get the image URL if it exists
      final String? imageUrl = doc.get('imageUrl') as String?;

      // Delete the image from storage if it exists
      if (imageUrl != null) {
        try {
          final Reference imageRef =
              FirebaseStorage.instance.refFromURL(imageUrl);
          await imageRef.delete();
        } catch (e) {
          print("Error deleting image: $e");
        }
      }

      // Delete the document from Firestore
      await docRef.delete();
    } catch (e) {
      print("Error deleting division: $e");
      throw e;
    }
  }

  // Get a list of all divisions
  Future<List<Map<String, dynamic>>> getAllDivisions() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('divisions')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching divisions: $e");
      return [];
    }
  }

  // Get a specific division by ID
  Future<Map<String, dynamic>?> getDivisionById(String divisionId) async {
    try {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('divisions')
          .doc(divisionId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the data
        return data;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching division: $e");
      return null;
    }
  }

  Future<void> markDivisionAsDeleted(String divisionId) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('divisions').doc(divisionId);
      final DocumentSnapshot doc = await docRef.get();

      if (!doc.exists) {
        throw Exception("Division not found");
      }

      // Update the status to 'Delete' instead of removing the document
      await docRef.update({
        'status': 'Delete',
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': await UserL().getCurrentUserName(),
      });
    } catch (e) {
      print("Error marking division as deleted: $e");
      throw e; // Rethrow to handle in the UI
    }
  }
}
