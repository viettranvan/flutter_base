import 'package:app_core/errors/error_mapper.dart';
import 'package:dio/dio.dart';

/// Interceptor to map DioException to AppException
/// Centralized error handling for all HTTP errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Map DioException → AppException
    final appException = mapDioException(err);

    // Throw AppException so it bubbles up to BLoC
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        type: err.type,
        response: err.response,
      ),
    );
  }
}
