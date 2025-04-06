import 'package:app1/data/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Examiner {
  Future<void> createExaminer(String uid, String email, String name,
      String division, String examinerId, String contactNumber) async {
    await FirebaseFirestore.instance.collection('examiners').doc(uid).set({
      'email': email,
      'name': name,
      'examinerId': examinerId,
      'division': division,
      'contactNumber': contactNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': await UserL().getCurrentUserName(),
      'status': 'Active'
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

  Future<List<Map<String, dynamic>>> getAllExaminers() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('examiners')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching examiners: $e");
      return [];
    }
  }
}
