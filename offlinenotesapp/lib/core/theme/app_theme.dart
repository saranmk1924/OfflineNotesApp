import 'package:flutter/material.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';

/// Defines the global theme configuration for the application.
///
/// Currently provides a dark theme used across the app, including
/// consistent styling for scaffold background, typography, app bar,
/// buttons, and input fields.
class AppTheme {
  /// Dark theme used as the primary application theme.
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    /// Background color for all scaffold screens.
    scaffoldBackgroundColor: AppPalette.black,

    /// Primary color used for widgets like buttons and accents.
    primaryColor: AppPalette.white,

    /// Global AppBar styling configuration.
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.black,
      foregroundColor: AppPalette.white,
      elevation: 0,
      centerTitle: true,
    ),

    /// Default text styles used across the app.
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

    /// Floating action button styling.
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.white,
      foregroundColor: AppPalette.black,
    ),

    /// Default styling for text input fields.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A1A1A),

      /// Default border style for input fields.
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

      /// Border when the input field is enabled but not focused.
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.white24),
      ),

      /// Border when the input field is focused.
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.white),
      ),
    ),
  );
}
