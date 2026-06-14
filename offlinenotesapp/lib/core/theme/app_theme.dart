import 'package:flutter/material.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPalette.black,
    primaryColor: AppPalette.white,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.black,
      foregroundColor: AppPalette.white,
      elevation: 0,
      centerTitle: true,
    ),

    // colorScheme: const ColorScheme.dark(
    //   primary: AppPalette.white,
    //   secondary: AppPalette.white,
    //   surface: AppPalette.black,
    // ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppPalette.white),
      headlineMedium: TextStyle(color: AppPalette.white),
      headlineSmall: TextStyle(color: AppPalette.white),
      titleLarge: TextStyle(color: AppPalette.white),
      titleMedium: TextStyle(color: AppPalette.white),
      titleSmall: TextStyle(color: AppPalette.white),
      bodyLarge: TextStyle(color: AppPalette.white),
      bodyMedium: TextStyle(color: AppPalette.white),
      bodySmall: TextStyle(color: AppPalette.white70),
    ),

    // iconTheme: const IconThemeData(
    //   color: AppPalette.white,
    // ),

    // dividerColor: AppPalette.white24,

    // cardColor: const Color(0xFF121212),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.white,
      foregroundColor: AppPalette.black,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A1A1A),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppPalette.white24,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppPalette.white,
        ),
      ),
    ),
  );
}