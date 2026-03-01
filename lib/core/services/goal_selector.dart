import 'dart:math';

import '../models/current_focus.dart';
import '../models/health_baseline.dart';
import 'health_analyzer.dart';

class GoalSelector {
  static CurrentFocus selectWeeklyFocus({
    required DateTime weekStart,
    required HealthBaseline baseline,
    CurrentFocus? previousFocus,
    double? previousCompletionRate,
  }) {
    final baselineSteps = baseline.avgSteps.round();

    if (previousFocus == null || previousCompletionRate == null) {
      return CurrentFocus(
        weekStartIso: _dateKey(weekStart),
        targetSteps: _roundedSteps(HealthAnalyzer.generateTargetSteps(baseline)),
        reason: _baselineReason(baseline),
        state: 'normal_progression',
        baselineSteps: baselineSteps,
      );
    }

    int target = previousFocus.targetSteps;
    String state = 'normal_progression';
    String reason;

    if (previousCompletionRate >= 0.85) {
      target = (target * 1.08).round();
      state = 'normal_progression';
      reason = 'Strong adherence last week. Progressing target gradually.';
    } else if (previousCompletionRate <= 0.4) {
      final floor = max(1500, (baselineSteps * 0.95).round());
      final reduced = (target * 0.9).round();
      target = max(floor, min(reduced, target));
      state = 'low_compliance';
      reason = 'Last week was hard to sustain. Rebuilding with a more realistic target.';
    } else {
      target = max(target, (baselineSteps * 1.05).round());
      state = 'consistency_rebuild';
      reason = 'Partial adherence last week. Holding focus for consistency.';
    }

    // Pattern-aware guardrails
    if ((baseline.isSporadic || baseline.isWeekendWarrior) && previousCompletionRate < 0.85) {
      target = min(target, previousFocus.targetSteps);
      reason = 'Pattern shows inconsistency. Prioritizing repeatability over stretch.';
      state = 'consistency_rebuild';
    }

    return CurrentFocus(
      weekStartIso: _dateKey(weekStart),
      targetSteps: _roundedSteps(target),
      reason: reason,
      state: state,
      baselineSteps: baselineSteps,
    );
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
