/// Environment configuration
/// Reads from dart-define values passed via --dart-define or --dart-define-from-file
class EnvConfig {
  // Environment keys
  static const String _envKey = 'ENV';
  static const String _jsonPlaceholderUrlKey = 'JSONPLACE_HOLDER_API';
  static const String _dummyJsonUrlKey = 'DUMMY_JSON_API';

  static const String _connectTimeoutKey = 'CONNECT_TIMEOUT';
  static const String _receiveTimeoutKey = 'RECEIVE_TIMEOUT';

  /// Get current environment (development, staging, production)
  static String getEnvironment() {
    return const String.fromEnvironment(_envKey, defaultValue: 'production');
  }

  /// Get API base URL
  static String getJsonPlaceholderUrl() {
    return const String.fromEnvironment(
      _jsonPlaceholderUrlKey,
      defaultValue: 'https://jsonplaceholder.typicode.com',
    );
  }

  static String getDummyJsonUrl() {
    return const String.fromEnvironment(
      _dummyJsonUrlKey,
      defaultValue: 'https://dummyjson.com',
    );
  }

  /// Get connection timeout in seconds
  static int getConnectTimeout() {
    final timeout = const String.fromEnvironment(
      _connectTimeoutKey,
      defaultValue: '10',
    );
    return int.tryParse(timeout) ?? 10;
  }

  /// Get receive timeout in seconds
  static int getReceiveTimeout() {
    final timeout = const String.fromEnvironment(
      _receiveTimeoutKey,
      defaultValue: '10',
    );
    return int.tryParse(timeout) ?? 10;
  }

  /// Check if running in development mode
  static bool isDevelopment() {
    return getEnvironment().toLowerCase() == 'development';
  }

  /// Check if running in staging mode
  static bool isStaging() {
    return getEnvironment().toLowerCase() == 'staging';
  }

  /// Check if running in production mode
  static bool isProduction() {
    return getEnvironment().toLowerCase() == 'production';
  }
}
