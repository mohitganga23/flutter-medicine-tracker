import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/strings.dart';
import '../../core/constants/text_styles.dart';
import '../../core/utils/navigation_helper.dart';
import '../../core/utils/secure_storage/secure_storage_keys.dart';
import '../../core/utils/secure_storage/secure_storage_util.dart';
import '../auth/screens/login.dart';
import '../dashboard/screens/dashboard.dart';
import '../onboarding/screens/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorageUtil secureStorageUtil = SecureStorageUtil();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      requestNotificationPermission();
      _checkUserSignIn();
    });
  }

  void _checkUserSignIn() async {
    User? user = _auth.currentUser;
    String? hasOnboardingDone = await secureStorageUtil.get(hasOnboarded);

    // If onboarding is not done, redirect to OnboardingScreen
    if (hasOnboardingDone == null || hasOnboardingDone != "true") {
      if (!mounted) return;
      NavigationHelper.pushReplacement(context, const OnboardingScreen());
      return;
    }

    // If the user is signed in, redirect to DashboardScreen
    if (user != null) {
      if (!mounted) return;
      NavigationHelper.pushReplacement(context, const DashboardScreen());
      return;
    }

    // If the user is not signed in and has completed onboarding, redirect to LoginScreen
    if (!mounted) return;
    NavigationHelper.pushReplacement(context, LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.appName,
              style: AppTextStyles.titleTextStyle,
            ),
            SizedBox(height: 10.h),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> requestNotificationPermission() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (granted != null && granted) {
      debugPrint('Notification permission granted.');
    } else {
      debugPrint('Notification permission denied.');
    }
  }
}
