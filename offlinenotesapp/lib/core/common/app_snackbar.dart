import 'package:flutter/material.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';

/// Utility class for displaying app-wide snack bar notifications.
///
/// Provides a static [show] method to display a floating snack bar
/// with a customizable message and optional icon. Any currently
/// visible snack bar is dismissed before showing a new one.
class AppSnackBar {
  /// Displays a snack bar with the given [message].
  ///
  /// An optional [icon] can be provided to visually indicate the
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context)
      // Remove any existing snack bar before showing a new one.
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppPalette.purple,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              // Display the icon when provided.
              if (icon != null) ...[
                Icon(icon, color: AppPalette.white),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppPalette.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
