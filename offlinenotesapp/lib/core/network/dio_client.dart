import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

/// Wrapper around the Dio HTTP client used for making API requests.
///
/// Configures common settings such as:
/// - Base URL
/// - Request and response timeouts
/// - Default headers
///
/// This ensures a consistent network configuration across the application.
class DioClient {
  /// Configured Dio instance used for all HTTP operations.
  final Dio dio;

  DioClient()
    : dio = Dio(
        BaseOptions(
          // Base URL for all API requests.
          baseUrl: ApiConstants.baseUrl,

          // Maximum duration to establish a connection.
          connectTimeout: const Duration(seconds: 30),

          // Maximum duration to wait for a server response.
          receiveTimeout: const Duration(seconds: 30),

          // Default headers sent with every request.
          headers: {'Content-Type': 'application/json'},
        ),
      );
}
