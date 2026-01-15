import 'app_storage.dart';
import 'preference_storage.dart';

/// Default implementation of PreferenceStorage using IAppStorage backend
///
/// Persists all preference data to secure encrypted storage.
/// All get operations are async (reads from storage).
/// All set operations are async (writes to storage).
///
/// This class is INTERNAL and should not be accessed directly.
/// Use [StorageFactory.preferenceStorage] instead.
class DefaultPreferenceStorage implements PreferenceStorage {
  final IAppStorage _storage;

  DefaultPreferenceStorage(this._storage);

  @override
  Future<String?> getFcmToken() => _storage.getValue(AppStorageKey.fcmToken);

  @override
  Future<void> setFcmToken(String token) =>
      _storage.setValue(AppStorageKey.fcmToken, token);

  @override
  Future<bool?> isFirstLogin() async {
    final value = await _storage.getValue(AppStorageKey.isFirstLogin);
    return value == null ? null : value == 'true';
  }

  @override
  Future<void> setFirstLogin(bool value) =>
      _storage.setValue(AppStorageKey.isFirstLogin, value.toString());

  @override
  Future<String?> getThemeMode() => _storage.getValue(AppStorageKey.themeMode);

  @override
  Future<void> setThemeMode(String mode) =>
      _storage.setValue(AppStorageKey.themeMode, mode);

  @override
  Future<String?> getLanguageCode() =>
      _storage.getValue(AppStorageKey.languageCode);

  @override
  Future<void> setLanguageCode(String code) =>
      _storage.setValue(AppStorageKey.languageCode, code);
}
