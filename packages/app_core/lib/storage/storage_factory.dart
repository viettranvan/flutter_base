import 'app_storage.dart';
import 'preference_storage.dart';
import 'preference_storage_impl.dart';
import 'token_storage.dart';
import 'token_storage_impl.dart';

/// Factory for creating and managing all storage instances
///
/// This is the single entry point for accessing storage in the application.
/// It ensures all storages are properly initialized and configured.
///
/// Usage:
/// ```dart
/// // Initialize on app startup (call once)
/// await StorageFactory.initialize();
///
/// // Get specific storage in your code
/// final tokenStorage = StorageFactory.tokenStorage;
/// final prefs = StorageFactory.preferenceStorage;
/// ```
///
/// IMPORTANT: Do not create storage instances directly. Always use this factory.
class StorageFactory {
  static late TokenStorage _tokenStorage;
  static late PreferenceStorage _preferenceStorage;

  /// Initialize all storages
  ///
  /// MUST be called once during app initialization, before accessing any storage.
  /// This loads cached tokens from persistent storage.
  ///
  /// Typically called in main.dart or injection_container.dart during setup.
  static Future<void> initialize() async {
    final internalStorage = getInternalAppStorage();

    // Create and initialize TokenStorage
    _tokenStorage = DefaultTokenStorage(internalStorage);
    await _tokenStorage.initialize();

    // Create PreferenceStorage
    _preferenceStorage = DefaultPreferenceStorage(internalStorage);
  }

  /// Get TokenStorage instance
  ///
  /// Throws if [initialize] hasn't been called yet.
  ///
  /// Use for:
  /// - Getting access token (sync, from cache)
  /// - Saving access token (async, persists + updates cache)
  /// - Saving refresh token (async, persists)
  /// - Clearing tokens on logout
  static TokenStorage get tokenStorage {
    return _tokenStorage;
  }

  /// Get PreferenceStorage instance
  ///
  /// Throws if [initialize] hasn't been called yet.
  ///
  /// Use for:
  /// - Managing FCM token
  /// - Tracking first login
  /// - Storing theme mode, language
  /// - Any user preferences
  static PreferenceStorage get preferenceStorage {
    return _preferenceStorage;
  }
}
