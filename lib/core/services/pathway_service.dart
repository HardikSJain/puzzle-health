import '../models/fitness_state.dart';
import '../models/health_baseline.dart';
import '../models/pathway.dart';

class PathwayService {
  static Pathway build({
    required FitnessState state,
    required HealthBaseline baseline,
  }) {
    final workouts = (baseline.workoutsPerWeek ?? 0).toStringAsFixed(1);
    final steps = baseline.avgSteps.round();

    switch (state) {
      case FitnessState.sedentaryStarter:
        return Pathway(
          now: 'Starting from ~$steps daily steps.',
          next: 'If you stay on target, next unlock is 4 active days/week.',
          later: 'Then build sustainable weekly volume before intensity.',
          confidence: 78,
        );
      case FitnessState.inconsistentWalker:
        return Pathway(
          now: 'Movement is present but inconsistent (~$steps steps/day).',
          next: 'If this week lands, next unlock is consistency over 5 days.',
          later: 'Then progression shifts toward distance capacity.',
          confidence: 72,
        );
      case FitnessState.consistentWalker:
        return Pathway(
          now: 'You are consistently active at ~$steps steps/day.',
          next: 'If this week lands, next unlock is controlled volume increase.',
          later: 'Then add optional running load when stable.',
          confidence: 74,
        );
      case FitnessState.emergingRunner:
        return Pathway(
          now: 'You are running about $workouts sessions/week.',
          next: 'If this week lands, next unlock is one longer controlled effort.',
          later: 'Then improve pace stability with recovery-safe progression.',
          confidence: 70,
        );
      case FitnessState.regularRunner:
        return Pathway(
          now: 'You are running consistently (~$workouts sessions/week).',
          next: 'If this week lands, next unlock is capacity or pace refinement.',
          later: 'Then periodize load blocks to prevent regression.',
          confidence: 76,
        );
      case FitnessState.unstableLoad:
        return Pathway(
          now: 'Load pattern is unstable relative to your baseline.',
          next: 'If this week lands, next unlock is a safe progression block.',
          later: 'Then resume capacity building with tighter guardrails.',
          confidence: 68,
        );
    }
  }
}
