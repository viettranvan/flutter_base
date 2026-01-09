/// Base exception class for app
/// All app-specific exceptions extend from this
///
/// Usage Example:
/// ```dart
/// try {
///   final response = await httpClient.get('/users');
/// } on NetworkException catch (e) {
///   print('Network error: ${e.message}');
/// } on AuthException catch (e) {
///   print('Auth error: ${e.message}');
/// } on ServerException catch (e) {
///   print('Server error: ${e.statusCode} - ${e.message}');
/// } on AppException catch (e) {
///   print('General error: ${e.message}');
/// }
/// ```
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() =>
      '$runtimeType: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Network-related exceptions (timeout, connection error, etc)
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.statusCode,
  });
}

/// Authentication-related exceptions (401, invalid token, etc)
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.statusCode,
  });
}

/// Server-side exceptions (500, 502, etc)
class ServerException extends AppException {
  ServerException({
    required super.message,
    super.statusCode,
  });
}

/// Validation exceptions (400, form errors, etc)
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException({
    required super.message,
    super.statusCode,
    this.errors,
  });
}

/// Not found exceptions (404)
class NotFoundException extends AppException {
  NotFoundException({
    required super.message,
    super.statusCode,
  });
}

/// Permission/Forbidden exceptions (403)
class ForbiddenException extends AppException {
  ForbiddenException({
    required super.message,
    super.statusCode,
  });
}

/// Generic exception for unmapped errors
class GenericException extends AppException {
  GenericException({
    required super.message,
    super.statusCode,
  });
}
