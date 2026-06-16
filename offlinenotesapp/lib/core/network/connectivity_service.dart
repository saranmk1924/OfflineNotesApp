import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service responsible for monitoring and checking network connectivity.
///
/// Provides both a real-time connectivity stream and a method for
/// performing on-demand connectivity checks.
class ConnectivityService {
  /// Connectivity plugin instance used to access network status.
  final Connectivity connectivity;

  /// Creates a new [ConnectivityService].
  ConnectivityService(this.connectivity);

  /// Stream that emits the current internet connectivity state.
  ///
  /// Returns:
  /// - `true` when the device is connected via mobile data or Wi-Fi.
  /// - `false` when no supported network connection is available.
  Stream<bool> get connectionStream {
    return connectivity.onConnectivityChanged.map(
      (result) =>
          result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi),
    );
  }

  /// Checks the current network connectivity status.
  ///
  /// Returns `true` if the device is connected through mobile data
  /// or Wi-Fi, otherwise returns `false`.
  Future<bool> isConnected() async {
    final result = await connectivity.checkConnectivity();

    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);
  }
}
