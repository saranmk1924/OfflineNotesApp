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

  Future<bool> isConnected() async {
    final result = await connectivity.checkConnectivity();

    return result.contains(
          ConnectivityResult.mobile,
        ) ||
        result.contains(
          ConnectivityResult.wifi,
        );
  }
}