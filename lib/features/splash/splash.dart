import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_medicine_tracker/core/constants/hero.dart';
import 'package:flutter_medicine_tracker/core/constants/text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/assets.dart';
import '../../core/constants/routes.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/navigation_helper.dart';
import '../../core/utils/secure_storage/secure_storage_keys.dart';
import '../../core/utils/secure_storage/secure_storage_util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  final SecureStorageUtil secureStorageUtil = SecureStorageUtil();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    // Opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start the animations
    _controller.forward();

    Timer(const Duration(seconds: 5), () {
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
      NavigationHelper.pushReplacementNamed(context, AppRoutes.onBoarding);
      return;
    }

    // If the user is signed in, redirect to DashboardScreen
    if (user != null) {
      if (!mounted) return;
      NavigationHelper.pushReplacementNamed(context, AppRoutes.dashboard);
      return;
    }

    // If the user is not signed in and has completed onboarding, redirect to LoginScreen
    if (!mounted) return;
    NavigationHelper.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fade-in animation for the logo
            FadeTransition(
              opacity: _opacityAnimation,
              child: Hero(
                tag: AppHeroTag.splashToLogin,
                child: Image.asset(
                  AppAssets.appLogo,
                  height: 120.h,
                  width: 120.w,
                ),
              ),
            ),
            SizedBox(height: 10),
            SlideTransition(
              position: _slideAnimation,
              child: Text(
                AppStrings.appName,
                style: AppTextStyles.splashTitle(context),
              ),
            ),
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
