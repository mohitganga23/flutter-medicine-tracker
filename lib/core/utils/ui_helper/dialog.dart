import 'dart:ui';

import 'package:flutter/material.dart';

class DialogHelper {
  static void _showDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required Color shadowColor,
    required void Function()? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 10,
        child: Stack(
          children: [
            /// Background with Blur Effect
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withAlpha(100),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Icon
                      Icon(icon, color: iconColor, size: 60),
                      SizedBox(height: 10),

                      /// Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: 10),

                      /// Message
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),

                      SizedBox(height: 20),

                      /// Button
                      OutlinedButton(
                        onPressed: onPressed,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: iconColor),
                        ),
                        child: Text(
                          "OK",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    required void Function()? onPressed,
  }) {
    _showDialog(
      context,
      title: title,
      message: message,
      onPressed: onPressed,
      icon: Icons.check_circle,
      iconColor: Colors.green,
      gradientColors: [Colors.green.shade300, Colors.green.shade200],
      shadowColor: Colors.green.shade700,
    );
  }

  /// Show Error Dialog
  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    required void Function()? onPressed,
  }) {
    _showDialog(
      context,
      title: title,
      message: message,
      onPressed: onPressed,
      icon: Icons.error,
      iconColor: Colors.red,
      gradientColors: [Colors.red.shade200, Colors.red.shade100],
      shadowColor: Colors.red.shade700,
    );
  }

  /// Show Info Dialog
  static void showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    required void Function()? onPressed,
  }) {
    _showDialog(
      context,
      title: title,
      message: message,
      onPressed: onPressed,
      icon: Icons.info,
      iconColor: Colors.blue,
      gradientColors: [Colors.blue.shade200, Colors.blue.shade100],
      shadowColor: Colors.blue.shade700,
    );
  }
}
