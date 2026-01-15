/// Abstract interface for managing user preferences and app settings
///
/// Provides type-safe API for storing and retrieving:
/// - App preferences (FCM token, theme, language)
/// - User settings (first login flag, etc)
/// - Feature flags and app configuration
///
/// This storage uses in-memory values where appropriate for performance.
/// All values are persisted to secure storage.
///
/// Usage:
/// ```dart
/// final prefs = StorageFactory.preferenceStorage;
/// await prefs.setFcmToken('new-token-123');
/// bool isFirst = await prefs.isFirstLogin();
/// ```
abstract class PreferenceStorage {
  /// Get FCM notification token
  /// Returns null if not set
  Future<String?> getFcmToken();

  /// Save FCM notification token
  /// Called when FCM token is refreshed
  Future<void> setFcmToken(String token);

  /// Check if this is the first time user opened the app
  /// Returns null if not set, true/false otherwise
  Future<bool?> isFirstLogin();

  /// Set first login flag (typically false after first successful login)
  Future<void> setFirstLogin(bool value);

  /// Get app theme mode (light/dark/system)
  /// Returns null if not set
  Future<String?> getThemeMode();

  /// Set app theme mode
  Future<void> setThemeMode(String mode);

  /// Get language code (e.g., 'en', 'vi', 'fr')
  /// Returns null if not set
  Future<String?> getLanguageCode();

  /// Set language code for app localization
  Future<void> setLanguageCode(String code);
}
