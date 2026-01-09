/// Custom API exceptions for network layer
abstract class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}

/// Exception for API errors (4xx, 5xx responses)
class ApiException extends NetworkException {
  final int? statusCode;
  final dynamic originalException;

  ApiException(super.message, {this.statusCode, this.originalException});
}

/// Exception for network/connectivity errors
class DioNetworkException extends NetworkException {
  final dynamic originalException;

  DioNetworkException(super.message, {this.originalException});
}

/// Exception for parsing/deserialization errors
class ParsingException extends NetworkException {
  final dynamic originalException;

  ParsingException(super.message, {this.originalException});
}
