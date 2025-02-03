// Email Validator
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter email address';
  }

  final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  if (!emailPattern.hasMatch(value)) {
    return 'Please enter a valid email address';
  }

  return null;
}

// Password Validator
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }

  return null;
}

// Password Strength Validator (with Uppercase, Lowercase, Number, Special Character)
String? validatePasswordStrength(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }

  final passwordPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$',
  );

  if (!passwordPattern.hasMatch(value)) {
    return 'Password must be at least 8 characters long and should contain at least \n•1 uppercase\n•1 lowercase\n•1 number\n•1 special character';
  }

  return null;
}
