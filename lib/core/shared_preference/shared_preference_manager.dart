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
    final prefs = await _instance;
    return prefs.setString(key, value);
  }

  // Bool
  static bool? getBool(String key) {
    return _prefsInstance?.getBool(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    final prefs = await _instance;
    return prefs.setBool(key, value);
  }

  // Int
  static int? getInt(String key) {
    return _prefsInstance?.getInt(key);
  }

  static Future<bool> setInt(String key, int value) async {
    final prefs = await _instance;
    return prefs.setInt(key, value);
  }

  // Remove key
  static Future<bool> remove(String key) async {
    final prefs = await _instance;
    return prefs.remove(key);
  }

  // Clear all data (for logout)
  static Future<bool> clearAll() async {
    final prefs = await _instance;
    return prefs.clear();
  }
}
