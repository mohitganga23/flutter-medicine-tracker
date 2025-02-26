import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/core/utils/navigation_helper.dart';
import 'package:flutter_medicine_tracker/core/utils/ui_helper/dialog.dart';

class ExceptionHandler {
  static void onException(BuildContext ctx, Object error) {
    String title = "Something Went Wrong";
    String message = "An unexpected error occurred. Please try again.";

    if (error is FirebaseAuthException) {
      _handleAuthError(ctx, error); // Handle known Firebase errors
      return;
    } else if (error is FirebaseException) {
      title = "Service Unavailable";
      message =
          "There was an issue connecting to the server. Please try again later.";
    } else if (error is SocketException) {
      title = "No Internet Connection";
      message = "Please check your internet and try again.";
    } else if (error is TimeoutException) {
      title = "Request Timed Out";
      message =
          "The request took too long. Please check your internet and try again.";
    } else if (error is FormatException) {
      title = "Invalid Format";
      message = "Something went wrong with the data. Please try again.";
    }

    DialogHelper.showErrorDialog(
      context: ctx,
      title: title,
      message: message,
      onPressed: () => NavigationHelper.pop(ctx),
    );
  }

  static void _handleAuthError(BuildContext ctx, FirebaseAuthException e) {
    String title;
    String message;

    switch (e.code) {
      case 'user-not-found':
        title = "Account Not Found";
        message =
            "We couldn't find an account with this email. Please check the email or sign up.";
        break;

      case 'invalid-credential':
        title = "Invalid Credentials";
        message =
            "The credentials you entered are incorrect or have expired. Please try again.";
        break;

      case 'wrong-password':
        title = "Incorrect Password";
        message =
            "The password you entered is incorrect. Please try again or reset your password.";
        break;

      case 'email-already-in-use':
        title = "Email Already Registered";
        message =
            "An account with this email already exists. Please log in instead.";
        break;

      case 'weak-password':
        title = "Weak Password";
        message =
            "Your password is too weak. Try using a stronger password with letters, numbers, and symbols.";
        break;

      case 'invalid-email':
        title = "Invalid Email Address";
        message =
            "The email address format is incorrect. Please check and enter a valid email.";
        break;

      case 'network-request-failed':
        title = "No Internet Connection";
        message = "Please check your internet connection and try again.";
        break;

      case 'too-many-requests':
        title = "Too Many Attempts";
        message =
            "You've attempted too many logins in a short period. Please try again later.";
        break;

      case 'account-exists-with-different-credential':
        title = "Different Sign-in Method";
        message =
            "This email is already linked with another sign-in method. Try using Google or another option.";
        break;

      case 'credential-already-in-use':
        title = "Credential In Use";
        message =
            "This account is already linked to another user. Try using a different sign-in method.";
        break;

      case 'user-disabled':
        title = "Account Disabled";
        message =
            "This account has been disabled. Please contact support for assistance.";
        break;

      case 'invalid-verification-code':
        title = "Invalid OTP Code";
        message =
            "The verification code you entered is incorrect. Please try again.";
        break;

      case 'requires-recent-login':
        title = "Re-authentication Required";
        message =
            "For security reasons, please log in again to complete this action.";
        break;

      case 'user-token-expired':
        title = "Session Expired";
        message = "Your session has expired. Please log in again.";
        break;

      default:
        title = "Authentication Error";
        message = e.message ?? "Something went wrong. Please try again.";
    }

    DialogHelper.showErrorDialog(
      context: ctx,
      title: title,
      message: message,
      onPressed: () => NavigationHelper.pop(ctx),
    );
  }
}
