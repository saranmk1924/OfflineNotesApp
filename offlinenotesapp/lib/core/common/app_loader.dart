import 'package:flutter/cupertino.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';

/// A reusable loading indicator used throughout the application.
///
/// Displays a large [CupertinoActivityIndicator] with the app's
/// primary purple color to indicate that a background operation
/// is currently in progress.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    // Renders a Cupertino-style loading spinner.
    return CupertinoActivityIndicator(radius: 40, color: AppPalette.purple);
  }
}
