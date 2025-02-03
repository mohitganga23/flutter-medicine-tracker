import 'package:flutter/material.dart';

void showCustomSnackBar(
  BuildContext context,
  String message,
  Color backgroundColor, {
  int durationInSeconds = 3,
}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: durationInSeconds),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
