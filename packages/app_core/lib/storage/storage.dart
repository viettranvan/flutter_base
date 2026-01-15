/// Public API for storage - barrel file for easy imports
///
/// This file exports only the public interfaces and factory.
/// Internal implementations are not exposed.
///
/// Usage:
/// ```dart
/// import 'package:app_core/storage/storage.dart';
///
/// final tokenStorage = StorageFactory.tokenStorage;
/// final prefs = StorageFactory.preferenceStorage;
/// ```
library;

export 'app_storage.dart' show AppStorageKey, IAppStorage;
export 'preference_storage.dart' show PreferenceStorage;
export 'storage_factory.dart' show StorageFactory;
export 'token_storage.dart' show TokenStorage;
