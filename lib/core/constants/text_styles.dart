import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle splashTitle(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .headlineLarge!
        .copyWith(letterSpacing: 1.5);
  }
}
