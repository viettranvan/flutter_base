/// Environment configuration
/// Reads from dart-define values passed via --dart-define-from-file
class EnvConfig {
  static const String _envKey = 'ENV';

  /// Get current environment
  static String getEnvironment() {
    return const String.fromEnvironment(_envKey, defaultValue: 'production');
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
