import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage keys enum - shared across all specialized storages
///
/// This enum defines all available storage keys used by different storages.
/// Each specialized storage (TokenStorage, PreferenceStorage, etc.) manages
/// specific keys without direct access to this, enforcing type-safe getters/setters.
enum AppStorageKey {
  // Token keys (managed by TokenStorage)
  accessToken,
  refreshToken,

  // Preference keys (managed by PreferenceStorage)
  isFirstLogin,
  fcmToken,
  themeMode,
  languageCode,

  // Add more keys here as needed
}

/// Abstract interface for low-level storage operations
///
/// INTERNAL: This interface is not meant to be used directly by application code.
/// Instead, use specialized storages like [TokenStorage] and [PreferenceStorage]
/// which provide type-safe, domain-specific APIs.
///
/// This is only used internally by [StorageFactory] to initialize specialized storages.
abstract class IAppStorage {
  /// Get a value from secure storage
  Future<String?> getValue(AppStorageKey key);

  /// Set a value in secure storage
  Future<void> setValue(AppStorageKey key, String? value);

  /// Delete a specific key from secure storage
  Future<void> deleteValue(AppStorageKey key);

  /// Delete all keys from secure storage
  Future<void> deleteAll();
}

/// Internal implementation of IAppStorage using FlutterSecureStorage
///
/// This class is INTERNAL and should not be accessed directly.
/// Use [StorageFactory] to get specialized storage instances instead.
class _AppStorage implements IAppStorage {
  _AppStorage._internal();

  static final _singleton = _AppStorage._internal();
  factory _AppStorage() => _singleton;

  final storage = const FlutterSecureStorage(
      iOptions: IOSOptions(accountName: 'go_bar'),
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  @override
  Future<String?> getValue(AppStorageKey key) => storage.read(key: key.name);

  @override
  Future<void> setValue(AppStorageKey key, String? value) =>
      storage.write(key: key.name, value: value);

  @override
  Future<void> deleteValue(AppStorageKey key) => storage.delete(key: key.name);

  @override
  Future<void> deleteAll() => storage.deleteAll();
}

/// Internal instance of AppStorage - only accessible by StorageFactory
final _internalAppStorage = _AppStorage();

/// Factory function to create/get internal app storage instance
///
/// INTERNAL: This function is only used by [StorageFactory].
/// Application code should use [StorageFactory] instead.
IAppStorage getInternalAppStorage() => _internalAppStorage;
