import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceManager {
  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();

  // Call this method from initState() function of mainApp().
  static Future<SharedPreferences?> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance;
  }

  // String
  static String? getString(String key) {
    return _prefsInstance?.getString(key);
  }

  static Future<bool> setString(String key, String value) async {
    return _prefsInstance?.setString(key, value) ?? Future.value(false);
  }

  // Bool
  static bool? getBool(String key) {
    return _prefsInstance?.getBool(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    return _prefsInstance?.setBool(key, value) ?? Future.value(false);
  }

  // Int
  static int? getInt(String key) {
    return _prefsInstance?.getInt(key);
  }

  static Future<bool> setInt(String key, int value) async {
    return _prefsInstance?.setInt(key, value) ?? Future.value(false);
  }

  // Clear all data (for logout)
  static Future<bool> clearAll() async {
    return _prefsInstance?.clear() ?? Future.value(false);
  }
}
