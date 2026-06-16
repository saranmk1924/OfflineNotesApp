import 'package:flutter/cupertino.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(radius: 40, color: AppPalette.purple);
  }
}
