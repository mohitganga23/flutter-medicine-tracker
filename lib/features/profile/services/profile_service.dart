import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/core/utils/exception_handler/exception_handler.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<DocumentSnapshot<Map<String, dynamic>?>?> getUserProfile(
    BuildContext ctx,
  ) async {
    try {
      final docSnapshot = await _firestore
          .collection('user_profile')
          .doc(_auth.currentUser!.email)
          .get();

      return docSnapshot;
    } catch (e) {
      if (!ctx.mounted) return null;
      ExceptionHandler.onException(ctx, e);
      return null;
    }
  }

  Future<void> updateUserProfile({
    required BuildContext ctx,
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
      String currentPhotoUrl = "";
      if (profileImage != null) {
        currentPhotoUrl = (await uploadProfileImage(profileImage))!;
      } else {
        currentPhotoUrl = profilePhotoUrl;
      }

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
      if (ctx.mounted) ExceptionHandler.onException(ctx, e);
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
      if (kDebugMode) print('Error uploading profile image: $e');
      return null;
    }
  }
}
