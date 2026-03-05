import 'package:health/health.dart';

import '../models/workout_session.dart';

class WorkoutExtractor {
  static List<WorkoutSession> fromHealthData(List<HealthDataPoint> data) {
    final workouts = data
        .where((p) => p.type == HealthDataType.WORKOUT)
        .map(_toWorkout)
        .whereType<WorkoutSession>()
        .toList();

    workouts.sort((a, b) => b.start.compareTo(a.start));
    return workouts;
  }

  static WorkoutSession? _toWorkout(HealthDataPoint point) {
    final durationMinutes =
        point.dateTo.difference(point.dateFrom).inMinutes.toDouble();
    if (durationMinutes <= 0) return null;

    final valueText = point.value.toString().toLowerCase();
    final sourceText = point.sourcePlatform.name;

    // Prefer structured workoutActivityType over string parsing.
    // Google Health encodes activity as a typed enum — don't rely on value text.
    final type = _activityTypeFromPoint(point, valueText);
    final distanceMeters = _extractDistanceMeters(valueText);
    final pace = (distanceMeters != null && distanceMeters > 0)
        ? (durationMinutes / (distanceMeters / 1000.0))
        : null;

    return WorkoutSession(
      id: '${point.uuid}_${point.dateFrom.millisecondsSinceEpoch}',
      type: type,
      start: point.dateFrom,
      end: point.dateTo,
      durationMinutes: durationMinutes,
      distanceMeters: distanceMeters,
      paceMinPerKm: pace,
      source: sourceText,
    );
  }

  static String _activityTypeFromPoint(HealthDataPoint point, String valueText) {
    // 1. Check structured workout type from the health package (most reliable)
    final value = point.value;
    if (value is WorkoutHealthValue) {
      final activityType = value.workoutActivityType;
      if (activityType == HealthWorkoutActivityType.RUNNING ||
          activityType == HealthWorkoutActivityType.RUNNING_TREADMILL ||
          activityType == HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING) {
        return 'running';
      }
      if (activityType == HealthWorkoutActivityType.WALKING) return 'walking';
      if (activityType == HealthWorkoutActivityType.BIKING ||
          activityType == HealthWorkoutActivityType.HAND_CYCLING) {
        return 'cycling';
      }
    }

    // 2. Fallback: parse value string (less reliable, especially on Google Health)
    if (valueText.contains('run')) return 'running';
    if (valueText.contains('walk')) return 'walking';
    if (valueText.contains('cycl')) return 'cycling';
    return 'other';
  }

  static double? _extractDistanceMeters(String text) {
    final meterMatch = RegExp(r'(\d+(?:\.\d+)?)\s*m\b').firstMatch(text);
    if (meterMatch != null) {
      return double.tryParse(meterMatch.group(1)!);
    }

    final kmMatch = RegExp(r'(\d+(?:\.\d+)?)\s*km\b').firstMatch(text);
    if (kmMatch != null) {
      final km = double.tryParse(kmMatch.group(1)!);
      return km != null ? km * 1000 : null;
    }
    return null;
  }
}
