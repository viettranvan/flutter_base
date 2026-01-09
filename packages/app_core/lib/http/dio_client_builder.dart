import 'package:dio/dio.dart';

/// Logging level for HTTP requests
enum HttpLogLevel {
  /// Minimal logging (status code only)
  basic,

  /// Detailed logging (headers, body, etc)
  verbose,

  /// No logging
  off,
}

typedef HttpLogCallback = Function(
  String message, {
  String? label,
  dynamic error,
  StackTrace? stackTrace,
});

/// Builder for configuring and creating Dio instances
/// Uses singleton pattern to maintain single configuration
class DioClientBuilder {
  String _baseUrl = '';
  int _connectTimeout = 60;
  int _receiveTimeout = 60;
  int _sendTimeout = 60;
  HttpLogLevel _logLevel = HttpLogLevel.basic;
  HttpLogCallback? _logCallback;
  void Function(DioException error)? _onUnknownErrors;
  final List<Interceptor> _additionalInterceptors = [];
  Map<String, dynamic>? _defaultHeaders;
  Dio? _exposedDio;

  DioClientBuilder._internal();

  static final DioClientBuilder _instance = DioClientBuilder._internal();

  factory DioClientBuilder() => _instance;

  /// Set the base URL for API requests
  DioClientBuilder setBaseUrl(String url) {
    _baseUrl = url;
    return this;
  }

  /// Set connection timeout in seconds
  DioClientBuilder setConnectTimeout(int seconds) {
    _connectTimeout = seconds;
    return this;
  }

  /// Set receive timeout in seconds
  DioClientBuilder setReceiveTimeout(int seconds) {
    _receiveTimeout = seconds;
    return this;
  }

  /// Set send timeout in seconds
  DioClientBuilder setSendTimeout(int seconds) {
    _sendTimeout = seconds;
    return this;
  }

  /// Set logging level
  DioClientBuilder setLogLevel(HttpLogLevel level) {
    _logLevel = level;
    return this;
  }

  /// Set custom logging callback
  DioClientBuilder setLogCallback(HttpLogCallback callback) {
    _logCallback = callback;
    return this;
  }

  /// Set callback for unknown errors
  DioClientBuilder setOnUnknownErrors(
      void Function(DioException error) callback) {
    _onUnknownErrors = callback;
    return this;
  }

  /// Add custom interceptor
  DioClientBuilder addInterceptor(Interceptor interceptor) {
    _additionalInterceptors.add(interceptor);
    return this;
  }

  /// Set default headers
  DioClientBuilder setDefaultHeaders(Map<String, dynamic> headers) {
    _defaultHeaders = headers;
    return this;
  }

  /// Expose Dio instance (for advanced usage)
  DioClientBuilder setExposedDio(Dio dio) {
    _exposedDio = dio;
    return this;
  }

  /// Build and configure Dio instance
  Dio build() {
    final dio = _exposedDio ??
        Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: Duration(seconds: _connectTimeout),
            receiveTimeout: Duration(seconds: _receiveTimeout),
            sendTimeout: Duration(seconds: _sendTimeout),
            contentType: 'application/json',
            headers: _defaultHeaders ?? {},
          ),
        );

    // Add custom interceptors
    for (final interceptor in _additionalInterceptors) {
      dio.interceptors.add(interceptor);
    }

    return dio;
  }

  /// Get all configuration as a map (useful for DI setup)
  Map<String, dynamic> getConfig() {
    return {
      'baseUrl': _baseUrl,
      'connectTimeout': _connectTimeout,
      'receiveTimeout': _receiveTimeout,
      'sendTimeout': _sendTimeout,
      'logLevel': _logLevel,
      'logCallback': _logCallback,
      'onUnknownErrors': _onUnknownErrors,
      'additionalInterceptors': _additionalInterceptors,
      'exposedDio': _exposedDio,
      'defaultHeaders': _defaultHeaders,
    };
  }

  /// Reset builder to initial state
  void reset() {
    _baseUrl = '';
    _connectTimeout = 30;
    _receiveTimeout = 30;
    _sendTimeout = 30;
    _logLevel = HttpLogLevel.basic;
    _logCallback = null;
    _onUnknownErrors = null;
    _additionalInterceptors.clear();
    _exposedDio = null;
    _defaultHeaders = null;
  }
}
