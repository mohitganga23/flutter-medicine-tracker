import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  LocalNotificationService lns = LocalNotificationService();

  Future<void> signInWithEmail({
    required BuildContext ctx,
    required String email,
    required String password,
  }) async {
    try {
      LoginProvider loginProvider = Provider.of<LoginProvider>(
        ctx,
        listen: false,
      );

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
      ExceptionHandler.onException(ctx, e);
    }
  }

  Future<void> signUpWithEmail({
    required BuildContext ctx,
    required String email,
    required String password,
  }) async {
    try {
      SignUpProvider signUpProvider = Provider.of<SignUpProvider>(
        ctx,
        listen: false,
      );

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
      ExceptionHandler.onException(ctx, e);
    }
  }

  Future<void> signInWithGoogle({required BuildContext ctx}) async {
    try {
      LoginProvider loginProvider = Provider.of<LoginProvider>(
        ctx,
        listen: false,
      );

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
}
