import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity connectivity;

  ConnectivityService(this.connectivity);

  Stream<bool> get connectionStream {
    return connectivity.onConnectivityChanged.map(
      (result) => result.contains(
        ConnectivityResult.mobile,
      ) ||
          result.contains(
            ConnectivityResult.wifi,
          ),
    );
  }
}