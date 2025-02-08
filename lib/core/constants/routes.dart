import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case onBoarding:
        return MaterialPageRoute(builder: (context) => OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (context) => SignUpScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (context) => ForgotPasswordScreen());
      case dashboard:
        return MaterialPageRoute(builder: (context) => DashboardScreen());
      case addMedication:
        return MaterialPageRoute(builder: (context) => AddMedicationForm());
      case medicationDetails:
        final args =
            settings.arguments as QueryDocumentSnapshot<Map<String, dynamic>>;
        return MaterialPageRoute(
          builder: (context) => MedicationDetailScreen(document: args),
        );
      case profile:
        return MaterialPageRoute(builder: (context) => ProfileScreen());
      case editProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => EditProfileScreen(userProfile: args),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text("Page not found")),
          ),
        );
    }
  }
}
