import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/core/constants/routes.dart';
import 'package:flutter_medicine_tracker/core/utils/exception_handler/exception_handler.dart';
import 'package:flutter_medicine_tracker/core/utils/local_notification_service/local_notification_service.dart';
import 'package:flutter_medicine_tracker/core/utils/navigation_helper.dart';
import 'package:flutter_medicine_tracker/core/utils/ui_helper/dialog.dart';
import 'package:flutter_medicine_tracker/features/auth/providers/login_provider.dart';
import 'package:flutter_medicine_tracker/features/auth/providers/sign_up_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  LocalNotificationService lns = LocalNotificationService();

  Future<void> signInWithEmail({
    required BuildContext ctx,
    required String email,
    required String password,
  }) async {
    LoginProvider loginProvider = Provider.of<LoginProvider>(
      ctx,
      listen: false,
    );

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      loginProvider.resetProvider();

      if (!ctx.mounted) return;
      NavigationHelper.pushAndRemoveUntilNamed(
        ctx,
        AppRoutes.dashboard,
        (route) => false,
      );
    } catch (e) {
      loginProvider.toggleLoading();
      ExceptionHandler.onException(ctx, e);
    }
  }

  Future<void> signUpWithEmail({
    required BuildContext ctx,
    required String email,
    required String password,
  }) async {
    SignUpProvider signUpProvider = Provider.of<SignUpProvider>(
      ctx,
      listen: false,
    );
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      UserModel newUser = UserModel(
        username: email.split('@').first,
        email: email.trim(),
        name: '',
        age: '-',
        gender: '-',
        profilePhotoUrl: '',
        createdOn: DateTime.now(),
      );

      await _firestore
          .collection('user_profile')
          .doc(userCredential.user!.email!)
          .set(newUser.toMap());

      if (!ctx.mounted) return;
      signUpProvider.resetProvider();
      DialogHelper.showSuccessDialog(
        context: ctx,
        title: "Account created",
        message: "Your account has been created successfully.",
        onPressed: () => NavigationHelper.pushAndRemoveUntilNamed(
          ctx,
          AppRoutes.login,
          (route) => false,
        ),
      );
    } catch (e) {
      signUpProvider.toggleSigningUpLoading();
      ExceptionHandler.onException(ctx, e);
    }
  }

  Future<void> signInWithGoogle({required BuildContext ctx}) async {
    LoginProvider loginProvider = Provider.of<LoginProvider>(
      ctx,
      listen: false,
    );

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (!ctx.mounted) return;
        ExceptionHandler.onException(ctx, "unknown-error");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      DocumentSnapshot doc = await _firestore
          .collection('user_profile')
          .doc(userCredential.user!.email!)
          .get();

      if (!doc.exists) {
        UserModel newUser = UserModel(
          username: userCredential.user!.email!.split('@').first,
          email: userCredential.user!.email!.trim(),
          name: userCredential.user!.displayName ?? '',
          age: '-',
          gender: '-',
          profilePhotoUrl: userCredential.user!.photoURL ?? '',
          createdOn: DateTime.now(),
        );

        await _firestore
            .collection('user_profile')
            .doc(userCredential.user!.email!)
            .set(newUser.toMap());
      }

      loginProvider.resetProvider();

      if (!ctx.mounted) return;
      NavigationHelper.pushAndRemoveUntilNamed(
        ctx,
        AppRoutes.dashboard,
        (route) => false,
      );
    } catch (e) {
      loginProvider.toggleSignInWithGoogleLoading();
      ExceptionHandler.onException(ctx, e);
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await lns.cancelAllNotifications();
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> deleteUserAccount(BuildContext ctx) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String userEmail = user.email ?? "";
    String userProfilePhotoPath = "profile_photos/$userEmail.jpg";
    String userMedicationsPath = "medications/$userEmail/user_medications";

    try {
      // 1. Delete Medications
      await _deleteCollection(userMedicationsPath);

      // 2. Delete Profile Data
      await _firestore.collection("user_profile").doc(userEmail).delete();

      // 3. Delete Profile Photo from Storage
      if (ctx.mounted) await _deleteProfilePhoto(ctx, userProfilePhotoPath);

      // 4. Delete Firebase User
      await user.delete();
    } catch (e) {
      if (ctx.mounted) ExceptionHandler.onException(ctx, e);
    }
  }

  // Helper function to delete a Firestore collection
  Future<void> _deleteCollection(String path) async {
    var collectionRef = _firestore.collection(path);
    var snapshots = await collectionRef.get();

    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  // Helper function to delete profile photo from Firebase Storage
  Future<void> _deleteProfilePhoto(BuildContext ctx, String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      if (ctx.mounted) ExceptionHandler.onException(ctx, e);
    }
  }
}
