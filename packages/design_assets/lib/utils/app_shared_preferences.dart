// Ví dụ sử dụng SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';

enum AppPreferencesKey {
  hasSeenOnboarding,
  hasRunBefore,
}

class AppPreferences {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static bool getBool(AppPreferencesKey key) {
    return _prefs?.getBool(key.name) ?? false;
  }

  static Future<void> setBool(AppPreferencesKey key, bool value) async {
    await _prefs?.setBool(key.name, value);
  }
}
