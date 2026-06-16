import 'package:flutter/material.dart';

/// Utility class for handling responsive layout breakpoints.
///
/// Provides helper methods to determine the current device type
/// based on screen width, enabling adaptive UI design across
/// mobile, tablet, desktop, and ultra-wide screens.
class ResponsiveSizes {
  /// Returns the current screen width from [MediaQuery].
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Returns `true` if the device is classified as a mobile device.
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < 600;
  }

  /// Returns `true` if the device is classified as a tablet.
  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 600 && screenWidth(context) < 1024;
  }

  /// Returns `true` if the device is classified as a desktop.
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= 1024 && screenWidth(context) < 1440;
  }

  /// Returns `true` if the device is classified as an ultra-wide display.
  static bool isUltrahd(BuildContext context) {
    return screenWidth(context) >= 1440;
  }
}
