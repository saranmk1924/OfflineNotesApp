import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/connectivity_service.dart';

/// Cubit responsible for monitoring and exposing network connectivity status.
///
/// Emits a boolean state:
/// - `true` when the device is connected to the internet
/// - `false` when the device is offline
///
/// It listens to real-time connectivity changes using [ConnectivityService].
class ConnectivityCubit extends Cubit<bool> {
  /// Service that provides connectivity status updates.
  final ConnectivityService connectivityService;

  /// Subscription to connectivity stream updates.
  StreamSubscription? _subscription;

  /// Creates a [ConnectivityCubit] and initializes connectivity monitoring.
  ConnectivityCubit(this.connectivityService) : super(false) {
    initialize();
  }

  /// Initializes the connectivity state and starts listening for changes.
  ///
  /// Emits the current connectivity status immediately, then listens
  /// for ongoing network changes.
  Future<void> initialize() async {
    emit(await connectivityService.isConnected());

    _subscription = connectivityService.connectionStream.listen(emit);
  }

  @override
  /// Cancels the connectivity subscription when cubit is disposed.
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
