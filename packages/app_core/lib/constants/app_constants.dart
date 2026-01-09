/// HTTP-related constants for the app
class HttpConstants {
  // Prevent instantiation
  HttpConstants._();

  // ============= Timeouts =============
  /// Default connection timeout (seconds)
  static const int connectTimeoutSeconds = 30;

  /// Default receive timeout (seconds)
  static const int receiveTimeoutSeconds = 30;

  /// Default send timeout (seconds)
  static const int sendTimeoutSeconds = 30;

  /// Duration objects for convenience
  static const Duration connectTimeout =
      Duration(seconds: connectTimeoutSeconds);
  static const Duration receiveTimeout =
      Duration(seconds: receiveTimeoutSeconds);
  static const Duration sendTimeout = Duration(seconds: sendTimeoutSeconds);

  // ============= HTTP Status Codes =============
  /// 200 OK
  static const int statusOk = 200;

  /// 201 Created
  static const int statusCreated = 201;

  /// 204 No Content
  static const int statusNoContent = 204;

  /// 400 Bad Request
  static const int statusBadRequest = 400;

  /// 401 Unauthorized
  static const int statusUnauthorized = 401;

  /// 403 Forbidden
  static const int statusForbidden = 403;

  /// 404 Not Found
  static const int statusNotFound = 404;

  /// 500 Internal Server Error
  static const int statusServerError = 500;

  /// 502 Bad Gateway
  static const int statusBadGateway = 502;

  /// 503 Service Unavailable
  static const int statusServiceUnavailable = 503;

  // ============= Common Headers =============
  /// Content-Type: application/json
  static const String contentTypeJson = 'application/json';

  /// Content-Type: application/x-www-form-urlencoded
  static const String contentTypeFormUrlEncoded =
      'application/x-www-form-urlencoded';

  /// Content-Type: multipart/form-data
  static const String contentTypeFormData = 'multipart/form-data';

  /// Bearer token prefix
  static const String authorizationBearer = 'Bearer';

  // ============= Response Fields =============
  /// Common error message field
  static const String errorMessageField = 'message';

  /// Common error code field
  static const String errorCodeField = 'code';

  /// Common errors field (for validation errors)
  static const String errorsField = 'errors';

  /// Common data field
  static const String dataField = 'data';

  /// Common success field
  static const String successField = 'success';

  // ============= Retry Config =============
  /// Max retry attempts for failed requests
  static const int maxRetryAttempts = 3;

  /// Retry delay in milliseconds
  static const int retryDelayMs = 1000;
}

/// App configuration constants
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  /// Max file upload size (10 MB)
  static const int maxUploadSizeBytes = 10 * 1024 * 1024;

  /// Cache duration
  static const Duration cacheDuration = Duration(hours: 1);

  /// Session timeout
  static const Duration sessionTimeout = Duration(hours: 24);
}
