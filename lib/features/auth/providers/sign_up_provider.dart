import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/features/auth/services/auth_service.dart';

class SignUpProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  get formKey => _formKey;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool _isSigningUp = false;

  bool get isSigningUp => _isSigningUp;

  bool _passwordVisible = false;

  bool get passwordVisible => _passwordVisible;

  bool _confirmPasswordVisible = false;

  bool get confirmPasswordVisible => _confirmPasswordVisible;

  void toggleSigningUpLoading() {
    _isSigningUp = !_isSigningUp;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _confirmPasswordVisible = !_confirmPasswordVisible;
    notifyListeners();
  }

  onSignUpClick(BuildContext ctx) async {
    if (_formKey.currentState!.validate()) {
      toggleSigningUpLoading();

      await _authService.signUpWithEmail(
        ctx: ctx,
        email: emailController.text,
        password: passwordController.text,
      );
    }
  }

  resetProvider() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _isSigningUp = false;
    _passwordVisible = false;
    _confirmPasswordVisible = false;
    _errorMessage = null;
  }

  @override
  void dispose() {
    resetProvider();
    super.dispose();
  }
}
