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

    final type = _activityTypeFromText(valueText);
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

  static String _activityTypeFromText(String text) {
    if (text.contains('run')) return 'running';
    if (text.contains('walk')) return 'walking';
    if (text.contains('cycl')) return 'cycling';
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
