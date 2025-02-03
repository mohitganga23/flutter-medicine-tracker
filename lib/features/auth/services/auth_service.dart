import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signUpWithEmail(String email, String password) async {
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

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

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

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
