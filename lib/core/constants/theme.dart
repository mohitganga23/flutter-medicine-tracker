import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    fontFamily: GoogleFonts.manrope().fontFamily,
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
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
      bodyMedium: TextStyle(color: AppColors.textSecondaryLight),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: AppColors.surfaceLight,
      backgroundColor: AppColors.primaryLight,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
      fontFamily: GoogleFonts.manrope().fontFamily,
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
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: AppColors.surfaceLight,
        backgroundColor: AppColors.primaryLight,
      ));
}
