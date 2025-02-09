import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getAllUserMedication() async {
    return await _firestore
        .collection('medications')
        .doc(_auth.currentUser!.email)
        .collection('user_medications')
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getMedicationStream() {
    return _firestore
        .collection('medications')
        .doc(_auth.currentUser!.email)
        .collection('user_medications')
        .snapshots();
  }
}
