import 'dart:convert';

import '../models/current_focus.dart';
import '../models/health_baseline.dart';
import '../shared_preference/shared_preference_keys.dart';
import '../shared_preference/shared_preference_manager.dart';

class LocalStoreService {
  static Future<void> saveBaseline(HealthBaseline baseline) async {
    await SharedPreferenceManager.setString(
      SharedPreferenceKeys.latestBaseline,
      jsonEncode(baseline.toJson()),
    );
  }

  static HealthBaseline? getBaseline() {
    final raw = SharedPreferenceManager.getString(
      SharedPreferenceKeys.latestBaseline,
    );
    if (raw == null || raw.isEmpty) return null;
    return HealthBaseline.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> saveActiveFocus(CurrentFocus focus) async {
    await SharedPreferenceManager.setString(
      SharedPreferenceKeys.activeWeeklyFocus,
      focus.encode(),
    );
  }

  static CurrentFocus? getActiveFocus() {
    final raw = SharedPreferenceManager.getString(
      SharedPreferenceKeys.activeWeeklyFocus,
    );
    if (raw == null || raw.isEmpty) return null;
    return CurrentFocus.decode(raw);
  }

  static Future<void> archiveFocus(CurrentFocus focus) async {
    final history = getFocusHistory();
    history.insert(0, focus);
    await SharedPreferenceManager.setString(
      SharedPreferenceKeys.weeklyFocusHistory,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  static List<CurrentFocus> getFocusHistory() {
    final raw = SharedPreferenceManager.getString(
      SharedPreferenceKeys.weeklyFocusHistory,
    );
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CurrentFocus.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveWeeklyRating(bool isGoodFit) async {
    await SharedPreferenceManager.setBool(
      SharedPreferenceKeys.weeklyGoalRatedGood,
      isGoodFit,
    );
  }

  static bool? getWeeklyRating() {
    return SharedPreferenceManager.getBool(
      SharedPreferenceKeys.weeklyGoalRatedGood,
    );
  }

  static Future<void> clearWeeklyRating() async {
    await SharedPreferenceManager.remove(SharedPreferenceKeys.weeklyGoalRatedGood);
  }
}
