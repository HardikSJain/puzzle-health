import 'dart:math';

import '../models/current_focus.dart';
import '../models/fitness_state.dart';
import '../models/health_baseline.dart';
import '../models/user_fitness_profile.dart';
import 'health_analyzer.dart';
import 'pathway_service.dart';

class GoalSelector {
  static CurrentFocus selectWeeklyFocus({
    required DateTime weekStart,
    required UserFitnessProfile profile,
    CurrentFocus? previousFocus,
    double? previousCompletionRate,
  }) {
    final baseline = profile.baseline;
    final baselineSteps = baseline.avgSteps.round();
    final pathway = PathwayService.build(
      state: profile.state,
      baseline: baseline,
    );

    final prefersRunGoal =
        profile.hasRunningData &&
        (profile.state == FitnessState.emergingRunner ||
            profile.state == FitnessState.regularRunner);

    if (prefersRunGoal) {
      final targetRuns = _selectRunFrequencyTarget(
        currentWeeklyRuns: profile.weeklyRunCount,
        previousFocus: previousFocus,
        previousCompletionRate: previousCompletionRate,
      );

      return CurrentFocus(
        weekStartIso: _dateKey(weekStart),
        targetSteps: max(2000, _roundedSteps((baselineSteps * 0.85).round())),
        targetRunsPerWeek: targetRuns,
        reason:
            'Running data is stable. This week prioritizes repeatable run frequency.',
        state: _stateFromCompletion(previousCompletionRate),
        baselineSteps: baselineSteps,
        goalType: 'run_frequency',
        fitnessState: profile.state,
        overlays: profile.overlays,
        pathway: pathway,
      );
    }

    // fallback to step goal
    final stepTarget = _selectStepTarget(
      baselineSteps: baselineSteps,
      baseline: baseline,
      previousFocus: previousFocus,
      previousCompletionRate: previousCompletionRate,
    );

    return CurrentFocus(
      weekStartIso: _dateKey(weekStart),
      targetSteps: _roundedSteps(stepTarget),
      reason: _baselineReason(baseline),
      state: _stateFromCompletion(previousCompletionRate),
      baselineSteps: baselineSteps,
      goalType: 'steps',
      fitnessState: profile.state,
      overlays: profile.overlays,
      pathway: pathway,
    );
  }

  static int _selectStepTarget({
    required int baselineSteps,
    required HealthBaseline baseline,
    required CurrentFocus? previousFocus,
    required double? previousCompletionRate,
  }) {
    if (previousFocus == null || previousCompletionRate == null) {
      return HealthAnalyzer.generateTargetSteps(baseline);
    }

    int target = previousFocus.targetSteps;

    if (previousCompletionRate >= 0.85) {
      target = (target * 1.08).round();
    } else if (previousCompletionRate <= 0.4) {
      final floor = max(1500, (baselineSteps * 0.95).round());
      final reduced = (target * 0.9).round();
      target = max(floor, min(reduced, target));
    } else {
      target = max(target, (baselineSteps * 1.05).round());
    }

    if ((baseline.isSporadic || baseline.isWeekendWarrior) &&
        previousCompletionRate < 0.85) {
      target = min(target, previousFocus.targetSteps);
    }

    return target;
  }

  static int _selectRunFrequencyTarget({
    required int currentWeeklyRuns,
    required CurrentFocus? previousFocus,
    required double? previousCompletionRate,
  }) {
    int currentTarget = previousFocus?.targetRunsPerWeek ?? max(2, currentWeeklyRuns);

    if (previousCompletionRate == null) {
      return currentTarget.clamp(2, 5);
    }

    if (previousCompletionRate >= 0.85) {
      currentTarget += 1;
    } else if (previousCompletionRate <= 0.4) {
      currentTarget -= 1;
    }

    return currentTarget.clamp(2, 5);
  }

  static String _stateFromCompletion(double? completionRate) {
    if (completionRate == null) return 'normal_progression';
    if (completionRate <= 0.4) return 'low_compliance';
    if (completionRate < 0.85) return 'consistency_rebuild';
    return 'normal_progression';
  }

  static String _baselineReason(HealthBaseline baseline) {
    if (baseline.isWeekendWarrior) {
      return 'Weekend spikes are strong. Goal is set to stabilize weekdays.';
    }
    if (baseline.isWeekdayOnly) {
      return 'Weekend drop is limiting consistency. Goal targets full-week stability.';
    }
    if (baseline.isSporadic) {
      return 'Daily movement is variable. Goal prioritizes consistency first.';
    }
    return 'Goal is calibrated from your recent baseline and recovery-friendly progression.';
  }

  static int _roundedSteps(int value) {
    if (value < 2000) {
      return (value / 50).round() * 50;
    }
    return (value / 100).round() * 100;
  }

  static String _dateKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
