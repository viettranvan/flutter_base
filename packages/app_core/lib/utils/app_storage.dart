import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppStorageKey {
  accessToken,
  refreshToken,
}

final appStorage = AppStorage();

abstract class IAppStorage {
  Future<String?> getValue(AppStorageKey key);
  Future<void> setValue(AppStorageKey key, String? value);
  Future<void> deleteValue(AppStorageKey key);
  Future<void> deleteAll();
}

class AppStorage implements IAppStorage {
  AppStorage._internal();

  static final _singleton = AppStorage._internal();
  factory AppStorage() => _singleton;

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
