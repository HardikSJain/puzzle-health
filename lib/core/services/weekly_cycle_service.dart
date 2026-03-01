import '../models/current_focus.dart';
import '../models/health_baseline.dart';
import 'goal_selector.dart';
import 'health_analyzer.dart';
import 'health_service.dart';
import 'local_store_service.dart';
import 'progress_service.dart';

class WeeklyCycleService {
  static Future<CurrentFocus> initializeOrRefresh({HealthBaseline? seedBaseline}) async {
    final now = DateTime.now();
    final currentWeekStart = _startOfWeek(now);

    final active = LocalStoreService.getActiveFocus();

    // Fresh install / no goal yet
    if (active == null) {
      final baseline = seedBaseline ?? await _computeLatestBaseline();
      await LocalStoreService.saveBaseline(baseline);
      final newFocus = GoalSelector.selectWeeklyFocus(
        weekStart: currentWeekStart,
        baseline: baseline,
      );
      await LocalStoreService.saveActiveFocus(newFocus);
      await LocalStoreService.clearWeeklyRating();
      return newFocus;
    }

    // Same week: no-op
    if (active.weekStartIso == _dateKey(currentWeekStart)) {
      return active;
    }

    // New week: archive previous with completion rate, then generate next.
    final previousCompletionRate = await ProgressService.getCompletionRate(active);
    final archived = CurrentFocus(
      weekStartIso: active.weekStartIso,
      targetSteps: active.targetSteps,
      reason: active.reason,
      state: active.state,
      baselineSteps: active.baselineSteps,
      completionRate: previousCompletionRate,
      goalType: active.goalType,
      fitnessState: active.fitnessState,
      overlays: active.overlays,
      pathway: active.pathway,
    );
    await LocalStoreService.archiveFocus(archived);

    final baseline = await _computeLatestBaseline();
    await LocalStoreService.saveBaseline(baseline);

    final next = GoalSelector.selectWeeklyFocus(
      weekStart: currentWeekStart,
      baseline: baseline,
      previousFocus: active,
      previousCompletionRate: previousCompletionRate,
    );

    await LocalStoreService.saveActiveFocus(next);
    await LocalStoreService.clearWeeklyRating();
    return next;
  }

  static Future<HealthBaseline> _computeLatestBaseline() async {
    try {
      final data = await HealthService.fetchLastNDays(days: 30);
      final unique = HealthService.removeDuplicates(data);
      return HealthAnalyzer.analyzeHealthData(unique, days: 30);
    } catch (_) {
      return LocalStoreService.getBaseline() ?? HealthBaseline.defaultBaseline();
    }
  }

  static DateTime _startOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1)); // Monday start
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
