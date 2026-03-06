import '../models/fitness_state.dart';
import '../models/health_baseline.dart';

class StateClassification {
  final FitnessState state;
  final List<String> overlays;

  const StateClassification({required this.state, required this.overlays});
}

class StateClassifier {
  static StateClassification classify(HealthBaseline baseline) {
    final overlays = <String>[];

    if (baseline.isWeekendWarrior) overlays.add('Weekend-heavy');
    if (baseline.isWeekdayOnly) overlays.add('Weekday-heavy');
    if (baseline.isSporadic) overlays.add('High variance');
    if (baseline.isSleepDeprived) overlays.add('Low sleep');

    final workouts = baseline.workoutsPerWeek ?? 0;

    // Runner states are checked first — a regular runner who had a high-variance
    // week should not be demoted to unstableLoad. Running identity takes precedence.
    if (workouts >= 3.0 && baseline.avgSteps >= 6500) {
      return StateClassification(
        state: FitnessState.regularRunner,
        overlays: overlays,
      );
    }

    if (workouts >= 1.5 && baseline.avgSteps >= 4500) {
      return StateClassification(
        state: FitnessState.emergingRunner,
        overlays: overlays,
      );
    }

    // Instability check applies only to non-runners. High variance on an
    // already-active baseline signals overtraining or inconsistency.
    if (baseline.stepVariance > (baseline.avgSteps * 0.75) &&
        baseline.avgSteps > 7000) {
      return StateClassification(
        state: FitnessState.unstableLoad,
        overlays: overlays,
      );
    }

    if (baseline.avgSteps < 2500 || baseline.activeDaysPerWeek <= 2) {
      return StateClassification(
        state: FitnessState.sedentaryStarter,
        overlays: overlays,
      );
    }

    if (baseline.isConsistent && baseline.activeDaysPerWeek >= 5) {
      return StateClassification(
        state: FitnessState.consistentWalker,
        overlays: overlays,
      );
    }

    return StateClassification(
      state: FitnessState.inconsistentWalker,
      overlays: overlays,
    );
  }
}
