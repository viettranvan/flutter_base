import 'package:app_core/errors/app_exception.dart';
import 'package:dio/dio.dart';

/// Map DioException to AppException
/// Single mapper for consistent error handling across app
///
/// Usage Example:
/// ```dart
/// try {
///   final response = await httpClient.get('/users');
/// } on DioException catch (e) {
///   final appException = mapDioException(e);
///   handleError(appException);
/// }
/// ```
AppException mapDioException(DioException exception) {
  final statusCode = exception.response?.statusCode;
  final message = _extractErrorMessage(exception);

  // Network errors (no response from server)
  if (exception.type == DioExceptionType.connectionTimeout) {
    return NetworkException(message: 'Connection timeout');
  }

  if (exception.type == DioExceptionType.receiveTimeout) {
    return NetworkException(message: 'Response timeout');
  }

  if (exception.type == DioExceptionType.sendTimeout) {
    return NetworkException(message: 'Request timeout');
  }

  if (exception.type == DioExceptionType.unknown) {
    return NetworkException(message: message);
  }

  // HTTP errors (got response but with error status)
  if (exception.type == DioExceptionType.badResponse) {
    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          statusCode: statusCode,
          errors: _extractValidationErrors(exception),
        );

      case 401:
        return AuthException(
          message: message,
          statusCode: statusCode,
        );

      case 403:
        return ForbiddenException(
          message: message,
          statusCode: statusCode,
        );

      case 404:
        return NotFoundException(
          message: message,
          statusCode: statusCode,
        );

      case 500:
      case 502:
      case 503:
        return ServerException(
          message: message,
          statusCode: statusCode,
        );

      default:
        return GenericException(
          message: message,
          statusCode: statusCode,
        );
    }
  }

  // Other errors
  return GenericException(message: message, statusCode: statusCode);
}

/// Extract error message from DioException
String _extractErrorMessage(DioException exception) {
  // Try to get message from response data first
  if (exception.response?.data != null) {
    final data = exception.response!.data;

    // JSON response with 'message' field
    if (data is Map) {
      if (data['message'] is String) {
        return data['message'] as String;
      }
      if (data['error'] is String) {
        return data['error'] as String;
      }
    }

    // String response
    if (data is String && data.isNotEmpty) {
      return data;
    }
  }

  // Fallback to DioException message
  return exception.message ?? 'Unknown error occurred';
}

/// Extract validation errors from 400 response
Map<String, dynamic>? _extractValidationErrors(DioException exception) {
  if (exception.response?.data == null) return null;

  final data = exception.response!.data;

  // Check common validation error formats
  if (data is Map) {
    // Format: { "errors": { "field": ["error1", "error2"] } }
    if (data['errors'] is Map) {
      return Map<String, dynamic>.from(data['errors'] as Map);
    }

    // Format: { "field1": "error1", "field2": "error2" }
    // Filter out non-string values
    return Map.fromEntries(
      data.entries
          .where((e) => e.value is String)
          .cast<MapEntry<String, dynamic>>(),
    );
  }

  return null;
}
