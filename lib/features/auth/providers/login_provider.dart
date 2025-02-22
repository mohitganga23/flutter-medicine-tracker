import 'package:flutter/material.dart';

import '../../../core/constants/routes.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/utils/ui_helper/snackbar.dart';
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

      String? result = await _authService.signInWithEmail(
        emailController.text,
        passwordController.text,
      );

      toggleLoading();

      if (result == null) {
        if (!ctx.mounted) return;
        resetProvider();
        NavigationHelper.pushAndRemoveUntilNamed(
          ctx,
          AppRoutes.dashboard,
          (route) => false,
        );
      } else {
        if (!ctx.mounted) return;
        showCustomSnackBar(ctx, result, Colors.red);
      }
    }
  }

  Future<void> onLoginWithGoogleClick(BuildContext ctx) async {
    toggleSignInWithGoogleLoading();

    String? result = await _authService.signInWithGoogle();

    toggleSignInWithGoogleLoading();

    if (result != null) {
      if (result == "success") {
        if (!ctx.mounted) return;
        resetProvider();
        NavigationHelper.pushAndRemoveUntilNamed(
          ctx,
          AppRoutes.dashboard,
          (route) => false,
        );
      } else {
        // Display error message if Google sign-in fails
        if (!ctx.mounted) return;
        showCustomSnackBar(ctx, result, Colors.red);
      }
    }
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
