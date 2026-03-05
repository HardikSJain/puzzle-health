import 'package:health/health.dart';

import '../models/current_focus.dart';
import 'health_service.dart';

class WeekProgress {
  final int daysCompleted;
  final int totalDays;
  final int todaySteps;
  final int targetSteps;
  final List<int> dailySteps; // Monday..Sunday

  // running goal support
  final int runsCompleted;
  final int targetRunsPerWeek;
  final List<int> dailyRuns; // Monday..Sunday

  const WeekProgress({
    required this.daysCompleted,
    required this.totalDays,
    required this.todaySteps,
    required this.targetSteps,
    required this.dailySteps,
    this.runsCompleted = 0,
    this.targetRunsPerWeek = 0,
    this.dailyRuns = const [0, 0, 0, 0, 0, 0, 0],
  });

  bool get isOnTrackToday {
    if (targetRunsPerWeek > 0) {
      return runsCompleted >= targetRunsPerWeek;
    }
    return targetSteps > 0 && todaySteps >= targetSteps;
  }
  double get completionRate => totalDays == 0 ? 0 : daysCompleted / totalDays;
}

class ProgressService {
  static Future<WeekProgress> getWeekProgress(CurrentFocus focus) async {
    return focus.goalType == 'run_frequency'
        ? _getRunWeekProgress(focus)
        : _getStepWeekProgress(focus);
  }

  static Future<WeekProgress> _getStepWeekProgress(CurrentFocus focus) async {
    final weekStart = DateTime.parse(focus.weekStartIso);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final now = DateTime.now();

    final end = now.isBefore(weekEnd) ? now : weekEnd;

    final data = await HealthService.fetchData(
      types: [HealthDataType.STEPS],
      startTime: weekStart,
      endTime: end,
    );

    final grouped = HealthService.groupByDate(data);
    final todayKey = _dateKey(now);
    int todaySteps = 0;
    int daysCompleted = 0;

    final dailySteps = List<int>.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final key = _dateKey(day);
      final points = grouped[key] ?? <HealthDataPoint>[];
      final sum = points
          .map((p) => HealthService.getNumericValue(p) ?? 0)
          .fold<double>(0, (a, b) => a + b)
          .round();

      dailySteps[i] = sum;

      if (key == todayKey) todaySteps = sum;
      if (sum >= focus.targetSteps) daysCompleted++;
    }

    final elapsedDays = _elapsedDaysInWeek(weekStart, now);

    return WeekProgress(
      daysCompleted: daysCompleted,
      totalDays: elapsedDays,
      todaySteps: todaySteps,
      targetSteps: focus.targetSteps,
      dailySteps: dailySteps,
    );
  }

  static Future<WeekProgress> _getRunWeekProgress(CurrentFocus focus) async {
    final weekStart = DateTime.parse(focus.weekStartIso);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final now = DateTime.now();
    final end = now.isBefore(weekEnd) ? now : weekEnd;

    final workouts = await HealthService.fetchData(
      types: [HealthDataType.WORKOUT],
      startTime: weekStart,
      endTime: end,
    );

    // For each day, check ALL workout entries — a mixed run/walk session may be
    // stored as a single "walking" WORKOUT by Google Health, but the user may
    // also have a separate RUNNING WORKOUT entry for the running segment.
    // Count a day as a run day if ANY workout entry that day is a run.
    final dailyRuns = List<int>.filled(7, 0);
    final daysCounted = <int>{};

    for (final point in workouts) {
      final idx = point.dateFrom.weekday - 1;
      if (idx < 0 || idx >= 7 || daysCounted.contains(idx)) continue;

      if (_isRunWorkout(point)) {
        dailyRuns[idx] += 1;
        daysCounted.add(idx);
      }
    }

    final runsCompleted = dailyRuns.fold<int>(0, (a, b) => a + b);
    final targetRuns = focus.targetRunsPerWeek ?? 2;

    return WeekProgress(
      daysCompleted: runsCompleted,
      totalDays: targetRuns,
      todaySteps: 0,
      targetSteps: focus.targetSteps,
      dailySteps: const [0, 0, 0, 0, 0, 0, 0],
      runsCompleted: runsCompleted,
      targetRunsPerWeek: targetRuns,
      dailyRuns: dailyRuns,
    );
  }

  static Future<double> getCompletionRate(CurrentFocus focus) async {
    final progress = await getWeekProgress(focus);
    if (focus.goalType == 'run_frequency') {
      final target = (focus.targetRunsPerWeek ?? 2).clamp(1, 7);
      return (progress.runsCompleted / target).clamp(0.0, 1.0);
    }
    return progress.daysCompleted / 7.0;
  }

  static int _elapsedDaysInWeek(DateTime weekStart, DateTime now) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (now.isAfter(weekEnd)) return 7;
    final elapsed = now.difference(weekStart).inDays + 1;
    return elapsed.clamp(1, 7);
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Determines if a WORKOUT data point represents a run using the structured
  /// activity type first, falling back to string matching.
  static bool _isRunWorkout(HealthDataPoint point) {
    final value = point.value;
    if (value is WorkoutHealthValue) {
      final t = value.workoutActivityType;
      return t == HealthWorkoutActivityType.RUNNING ||
          t == HealthWorkoutActivityType.RUNNING_TREADMILL ||
          t == HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING;
    }
    return point.value.toString().toLowerCase().contains('run');
  }
}
