import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  get formKey => _formKey;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isSignInWithGoogle = false;

  bool get isSignInWithGoogle => _isSignInWithGoogle;

  bool _passwordVisible = false;

  bool get passwordVisible => _passwordVisible;

  void toggleLoading() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  void toggleSignInWithGoogleLoading() {
    _isSignInWithGoogle = !_isSignInWithGoogle;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  Future<void> onLoginWithEmailClick(BuildContext ctx) async {
    if (formKey.currentState!.validate()) {
      toggleLoading();
      await _authService.signInWithEmail(
        ctx: ctx,
        email: emailController.text,
        password: passwordController.text,
      );
    }
  }

  Future<void> onLoginWithGoogleClick(BuildContext ctx) async {
    toggleSignInWithGoogleLoading();
    await _authService.signInWithGoogle(ctx: ctx);
  }

  resetProvider() {
    emailController.clear();
    passwordController.clear();
    _isLoading = false;
    _isSignInWithGoogle = false;
    _passwordVisible = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
