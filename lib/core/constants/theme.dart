import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppThemes {
  static TextTheme _buildTextTheme(
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return TextTheme(
      // Display (Large Headers / Hero Text)
      displayLarge: TextStyle(
        fontSize: 57.sp,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45.sp,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36.sp,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
      ),

      // Headlines (Page / Section Titles)
      headlineLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
      ),

      // Titles (App Bar / Cards)
      titleLarge: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      titleMedium: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
      ),
      titleSmall: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),

      // Body (General Text)
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
      ),

      // Labels (Buttons, Captions, Small Text)
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
      labelSmall: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
      ),
    );
  }

  static final ThemeData lightTheme = ThemeData(
    fontFamily: GoogleFonts.wixMadeforDisplay().fontFamily,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      surface: AppColors.surfaceLight,
      error: AppColors.errorLight,
      onPrimary: AppColors.surfaceLight,
      onSecondary: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      onError: AppColors.surfaceLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        iconColor: AppColors.backgroundLight,
        foregroundColor: AppColors.backgroundLight,
      ),
    ),
    textTheme: _buildTextTheme(
      AppColors.textPrimaryLight,
      AppColors.textSecondaryLight,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: AppColors.surfaceLight,
      backgroundColor: AppColors.primaryLight,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    fontFamily: GoogleFonts.wixMadeforDisplay().fontFamily,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      surface: AppColors.surfaceDark,
      error: AppColors.errorDark,
      onPrimary: AppColors.textPrimaryDark,
      onSecondary: AppColors.textPrimaryDark,
      onSurface: AppColors.textPrimaryDark,
      onError: AppColors.textPrimaryDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        iconColor: AppColors.backgroundLight,
        foregroundColor: AppColors.backgroundLight,
      ),
    ),
    textTheme: _buildTextTheme(
      AppColors.textPrimaryDark,
      AppColors.textSecondaryDark,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: AppColors.surfaceLight,
      backgroundColor: AppColors.primaryLight,
    ),
  );
}
