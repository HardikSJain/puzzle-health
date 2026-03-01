import '../models/current_focus.dart';
import '../models/fitness_state.dart';
import '../models/health_baseline.dart';
import '../models/user_fitness_profile.dart';
import 'fitness_profile_service.dart';
import 'goal_selector.dart';
import 'health_analyzer.dart';
import 'health_service.dart';
import 'local_store_service.dart';
import 'progress_service.dart';

class WeeklyCycleService {
  static Future<CurrentFocus> initializeOrRefresh({
    HealthBaseline? seedBaseline,
  }) async {
    final now = DateTime.now();
    final currentWeekStart = _startOfWeek(now);

    final active = LocalStoreService.getActiveFocus();

    // Fresh install / no goal yet
    if (active == null) {
      final profile = await _computeLatestProfile(seedBaseline: seedBaseline);
      await LocalStoreService.saveBaseline(profile.baseline);
      await LocalStoreService.saveFitnessProfile(profile);

      final newFocus = GoalSelector.selectWeeklyFocus(
        weekStart: currentWeekStart,
        profile: profile,
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
      targetRunsPerWeek: active.targetRunsPerWeek,
      goalType: active.goalType,
      fitnessState: active.fitnessState,
      overlays: active.overlays,
      pathway: active.pathway,
    );
    await LocalStoreService.archiveFocus(archived);

    final profile = await _computeLatestProfile();
    await LocalStoreService.saveBaseline(profile.baseline);
    await LocalStoreService.saveFitnessProfile(profile);

    final next = GoalSelector.selectWeeklyFocus(
      weekStart: currentWeekStart,
      profile: profile,
      previousFocus: active,
      previousCompletionRate: previousCompletionRate,
    );

    await LocalStoreService.saveActiveFocus(next);
    await LocalStoreService.clearWeeklyRating();
    return next;
  }

  static Future<UserFitnessProfile> _computeLatestProfile({
    HealthBaseline? seedBaseline,
  }) async {
    try {
      final profile = await FitnessProfileService.buildLast30DaysProfile();
      if (seedBaseline == null) return profile;

      return UserFitnessProfile(
        baseline: seedBaseline,
        state: profile.state,
        overlays: profile.overlays,
        workouts30d: profile.workouts30d,
        lastRun: profile.lastRun,
        weeklyRunCount: profile.weeklyRunCount,
        avgRunDistanceMeters: profile.avgRunDistanceMeters,
        avgRunPaceMinPerKm: profile.avgRunPaceMinPerKm,
        confidence: profile.confidence,
      );
    } catch (_) {
      final baseline = seedBaseline ?? (await _computeLatestBaseline());
      final fallback = LocalStoreService.getFitnessProfile();
      if (fallback != null) {
        return UserFitnessProfile(
          baseline: baseline,
          state: fallback.state,
          overlays: fallback.overlays,
          workouts30d: fallback.workouts30d,
          lastRun: fallback.lastRun,
          weeklyRunCount: fallback.weeklyRunCount,
          avgRunDistanceMeters: fallback.avgRunDistanceMeters,
          avgRunPaceMinPerKm: fallback.avgRunPaceMinPerKm,
          confidence: fallback.confidence,
        );
      }

      return UserFitnessProfile(
        baseline: baseline,
        state: LocalStoreService.getActiveFocus()?.fitnessState ??
            FitnessState.inconsistentWalker,
        overlays: const [],
        workouts30d: const [],
        lastRun: null,
        weeklyRunCount: 0,
        avgRunDistanceMeters: null,
        avgRunPaceMinPerKm: null,
        confidence: baseline.dataCompletenessScore,
      );
    }
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
