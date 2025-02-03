import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<DocumentSnapshot<Map<String, dynamic>?>?> getUserProfile() async {
    try {
      final docSnapshot = await _firestore
          .collection('user_profile')
          .doc(_auth.currentUser!.email)
          .get();

      return docSnapshot;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String age,
    required String gender,
    required String profilePhotoUrl,
    required File? profileImage,
    required List<Map<String, dynamic>> familyMembers,
    String? currentPhotoUrl,
  }) async {
    // TODO: implement updateProfile
    try {
      await _firestore
          .collection('user_profile')
          .doc(_auth.currentUser!.email)
          .update({
        'name': name,
        'age': age,
        'gender': gender,
        'profile_photo_url': currentPhotoUrl,
        'family_members': familyMembers,
      });
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    // TODO: implement uploadProfileImage
    try {
      final storageRef = _storage
          .ref()
          .child('profile_photos/${_auth.currentUser!.email}.jpg');

      // Upload image
      await storageRef.putFile(imageFile);

      // Get download URL
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
}
