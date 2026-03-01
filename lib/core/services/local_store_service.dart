import 'dart:convert';

import '../exceptions/exception_logger.dart';
import '../models/current_focus.dart';
import '../models/health_baseline.dart';
import '../models/user_fitness_profile.dart';
import '../shared_preference/shared_preference_keys.dart';
import '../shared_preference/shared_preference_manager.dart';

class LocalStoreService {
  static const int _maxArchivedFocusWeeks = 52;

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

    try {
      return HealthBaseline.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (exception, stackTrace) {
      ExceptionLogger.track(
        Exception('Failed to decode latestBaseline. raw=$raw | error=$exception'),
        stackTrace,
      );
      return null;
    }
  }

  static Future<void> saveActiveFocus(CurrentFocus focus) async {
    await SharedPreferenceManager.setString(
      SharedPreferenceKeys.activeWeeklyFocus,
      focus.encode(),
    );
  }

  static Future<void> saveFitnessProfile(UserFitnessProfile profile) async {
    await SharedPreferenceManager.setString(
      SharedPreferenceKeys.latestFitnessProfile,
      jsonEncode(profile.toJson()),
    );
  }

  static UserFitnessProfile? getFitnessProfile() {
    final raw = SharedPreferenceManager.getString(
      SharedPreferenceKeys.latestFitnessProfile,
    );
    if (raw == null || raw.isEmpty) return null;

    try {
      return UserFitnessProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (exception, stackTrace) {
      ExceptionLogger.track(
        Exception(
          'Failed to decode latestFitnessProfile. raw=$raw | error=$exception',
        ),
        stackTrace,
      );
      return null;
    }
  }

  static CurrentFocus? getActiveFocus() {
    final raw = SharedPreferenceManager.getString(
      SharedPreferenceKeys.activeWeeklyFocus,
    );
    if (raw == null || raw.isEmpty) return null;

    try {
      return CurrentFocus.decode(raw);
    } catch (exception, stackTrace) {
      ExceptionLogger.track(
        Exception(
          'Failed to decode activeWeeklyFocus. raw=$raw | error=$exception',
        ),
        stackTrace,
      );
      return null;
    }
  }

  static Future<void> archiveFocus(CurrentFocus focus) async {
    final history = getFocusHistory();
    history.insert(0, focus);

    if (history.length > _maxArchivedFocusWeeks) {
      history.removeRange(_maxArchivedFocusWeeks, history.length);
    }

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

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CurrentFocus.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (exception, stackTrace) {
      ExceptionLogger.track(
        Exception(
          'Failed to decode weeklyFocusHistory. raw=$raw | error=$exception',
        ),
        stackTrace,
      );
      return [];
    }
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
