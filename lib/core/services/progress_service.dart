import 'package:health/health.dart';

import '../models/current_focus.dart';
import 'health_service.dart';

class WeekProgress {
  final int daysCompleted;
  final int totalDays;
  final int todaySteps;
  final int targetSteps;

  const WeekProgress({
    required this.daysCompleted,
    required this.totalDays,
    required this.todaySteps,
    required this.targetSteps,
  });

  bool get isOnTrackToday => todaySteps >= targetSteps;
  double get completionRate => totalDays == 0 ? 0 : daysCompleted / totalDays;
}

class ProgressService {
  static Future<WeekProgress> getWeekProgress(CurrentFocus focus) async {
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

    grouped.forEach((key, points) {
      final sum = points
          .map((p) => HealthService.getNumericValue(p) ?? 0)
          .fold<double>(0, (a, b) => a + b)
          .round();

      if (key == todayKey) todaySteps = sum;
      if (sum >= focus.targetSteps) daysCompleted++;
    });

    final elapsedDays = _elapsedDaysInWeek(weekStart, now);

    return WeekProgress(
      daysCompleted: daysCompleted,
      totalDays: elapsedDays,
      todaySteps: todaySteps,
      targetSteps: focus.targetSteps,
    );
  }

  static Future<double> getCompletionRate(CurrentFocus focus) async {
    final progress = await getWeekProgress(focus);
    // Weekly adherence should use 7-day denominator for adaptation.
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
}
