import 'package:flutter/material.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppPalette.purple,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
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
