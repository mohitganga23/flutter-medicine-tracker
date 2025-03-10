import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_medicine_tracker/core/utils/navigation_helper.dart';

import '../../features/auth/screens/forgot_password.dart';
import '../../features/auth/screens/login.dart';
import '../../features/auth/screens/signup.dart';
import '../../features/dashboard/screens/dashboard.dart';
import '../../features/dashboard/screens/dashboard_pages/home/medication_details.dart';
import '../../features/medication/screens/add_medication.dart';
import '../../features/onboarding/screens/onboarding.dart';
import '../../features/profile/screens/edit_profile.dart';
import '../../features/profile/screens/profile.dart';
import '../../features/splash/splash.dart';

class AppRoutes {
  static const String splash = "/";
  static const String onBoarding = "/onboarding";
  static const String login = "/login";
  static const String signUp = "/signUp";
  static const String forgotPassword = "/forgotPassword";
  static const String dashboard = "/dashboard";
  static const String addMedication = "/addMedication";
  static const String medicationDetails = "/medicationDetails";
  static const String profile = "/profile";
  static const String editProfile = "/editProfile";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return NavigationHelper.fadeRoute(SplashScreen());
      case onBoarding:
        return NavigationHelper.fadeRoute(OnboardingScreen());
      case login:
        return NavigationHelper.fadeRoute(LoginScreen());
      case signUp:
        return NavigationHelper.fadeRoute(SignUpScreen());
      case forgotPassword:
        return NavigationHelper.fadeRoute(ForgotPasswordScreen());
      case dashboard:
        return NavigationHelper.fadeRoute(DashboardScreen());
      case addMedication:
        return NavigationHelper.fadeRoute(AddMedicationForm());
      case medicationDetails:
        final args =
            settings.arguments as QueryDocumentSnapshot<Map<String, dynamic>>;
        return NavigationHelper.fadeRoute(
          MedicationDetailScreen(document: args),
        );
      case profile:
        return NavigationHelper.fadeRoute(ProfileScreen());
      case editProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return NavigationHelper.fadeRoute(EditProfileScreen(userProfile: args));
      default:
        return NavigationHelper.fadeRoute(
          Scaffold(
            body: Center(child: Text("Page not found")),
          ),
        );
    }
  }
}
