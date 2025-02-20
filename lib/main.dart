import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'core/constants/routes.dart';
import 'core/constants/theme.dart';
import 'core/utils/logger.dart';
import 'features/auth/providers/login_provider.dart';
import 'features/auth/providers/sign_up_provider.dart';
import 'features/dashboard/providers/home_provider.dart';
import 'features/medication/providers/medication_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      CustomLogger().error("Flutter Error", details.exception);
    };

    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Screen Utils
    await ScreenUtil.ensureScreenSize();

    // Initialize TimeZone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    runApp(const MyApp());
  }, (error, stackTrace) {
    CustomLogger().fatal("Uncaught Error", {
      "error": error.toString(),
      "stackTrace": stackTrace.toString(),
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
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
            navigatorKey: navigatorKey,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: ThemeMode.system,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
          ),
        );
      },
    );
  }
}
