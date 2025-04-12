import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'core/constants/routes.dart';
import 'core/constants/theme.dart';
import 'features/auth/providers/login_provider.dart';
import 'features/auth/providers/sign_up_provider.dart';
import 'features/dashboard/providers/home_provider.dart';
import 'features/medication/providers/medication_provider.dart';
import 'firebase_options.dart';

class AppConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    TimeZoneConfig.initialize();

    await initializeNotifications();
  }

  static Future<void> initializeNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}

class TimeZoneConfig {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (!_isInitialized) {
      tz.initializeTimeZones();
      try {
        String deviceTimeZone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(deviceTimeZone));
      } catch (e) {
        debugPrint('Timezone initialization failed, using Asia/Kolkata: $e');
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      }
      _isInitialized = true;
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  runApp(const MyApp());
}

// MyApp class remains unchanged
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  static bool _isScreenUtilInitialized = false;

  Size calculateDesignSize(Size screenSize, Size baseDesignSize) {
    final double screenAspectRatio = screenSize.width / screenSize.height;
    final double baseAspectRatio = baseDesignSize.width / baseDesignSize.height;
    bool isTablet = screenSize.shortestSide >= 600;
    bool isLandscape = screenSize.width > screenSize.height;

    double designWidth;
    double designHeight;

    if (isTablet) {
      double heightScale = isLandscape ? 0.65 : 0.75;
      double widthScale = isLandscape ? 0.6 : 0.5;
      if (screenAspectRatio > baseAspectRatio) {
        designHeight = screenSize.height * heightScale;
        designWidth = designHeight * baseAspectRatio;
      } else {
        designWidth = screenSize.width * widthScale;
        designHeight = designWidth / baseAspectRatio;
      }
    } else {
      double heightScale = isLandscape ? 0.8 : 0.85;
      double widthScale = isLandscape ? 0.85 : 0.9;
      if (screenAspectRatio > baseAspectRatio) {
        designHeight = screenSize.height * heightScale;
        designWidth = designHeight * baseAspectRatio;
      } else {
        designWidth = screenSize.width * widthScale;
        designHeight = designWidth / baseAspectRatio;
      }
    }

    return Size(
      designWidth.clamp(0, screenSize.width),
      designHeight.clamp(0, screenSize.height),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final Size screenSize = MediaQuery.of(context).size;
      const Size baseDesignSize = Size(360, 690);

      if (!_isScreenUtilInitialized) {
        final designSize = calculateDesignSize(screenSize, baseDesignSize);
        ScreenUtil.init(
          context,
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
        );
        _isScreenUtilInitialized = true;
      }

      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => LoginProvider()),
          ChangeNotifierProvider(create: (context) => SignUpProvider()),
          ChangeNotifierProvider(create: (context) => HomeProvider()),
          ChangeNotifierProvider(create: (context) => MedicationProvider()),
        ],
        child: MaterialApp(
          title: 'Flutter Medicine',
          debugShowCheckedModeBanner: false,
          navigatorKey: navKey,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        ),
      );
    });
  }
}
