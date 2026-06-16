import 'package:flutter/material.dart';

class ResponsiveSizes {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static bool isMobile(BuildContext context) {
    return screenWidth(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 600 && screenWidth(context) < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= 1024 && screenWidth(context) < 1440;
  }

  static bool isUltrahd(BuildContext context) {
    return screenWidth(context) >= 1440;
  }
}
