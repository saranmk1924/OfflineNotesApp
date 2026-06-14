import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/connectivity_service.dart';

class ConnectivityCubit extends Cubit<bool> {
  final ConnectivityService connectivityService;

  StreamSubscription? _subscription;

  ConnectivityCubit(
    this.connectivityService,
  ) : super(false) {
    initialize();
  }

  Future<void> initialize() async {
    emit(
      await connectivityService.isConnected(),
    );

    _subscription =
        connectivityService.connectionStream.listen(
      emit,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}