import '../models/health_baseline.dart';
import '../models/user_fitness_profile.dart';
import '../models/workout_session.dart';
import 'health_analyzer.dart';
import 'health_service.dart';
import 'state_classifier.dart';
import 'workout_extractor.dart';

class FitnessProfileService {
  static Future<UserFitnessProfile> buildLast30DaysProfile() async {
    final data = await HealthService.fetchLastNDays(days: 30);
    final unique = HealthService.removeDuplicates(data);
    final baseline = HealthAnalyzer.analyzeHealthData(unique, days: 30);
    final classification = StateClassifier.classify(baseline);

    final workouts = WorkoutExtractor.fromHealthData(unique);
    final runs = workouts.where((w) => w.isRun).toList();

    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final weeklyRunCount = runs.where((r) => !r.start.isBefore(weekStart)).length;

    final avgRunDistance = runs.isEmpty
        ? null
        : runs
                .where((r) => r.distanceMeters != null)
                .map((r) => r.distanceMeters!)
                .fold<double>(0, (a, b) => a + b) /
            runs.where((r) => r.distanceMeters != null).length.clamp(1, runs.length);

    final runPaces = runs
        .where((r) => r.paceMinPerKm != null)
        .map((r) => r.paceMinPerKm!)
        .toList();
    final avgPace = runPaces.isEmpty
        ? null
        : runPaces.fold<double>(0, (a, b) => a + b) / runPaces.length;

    final confidence = _confidenceScore(baseline, runs);

    return UserFitnessProfile(
      baseline: baseline,
      state: classification.state,
      overlays: classification.overlays,
      workouts30d: workouts,
      lastRun: runs.isNotEmpty ? runs.first : null,
      weeklyRunCount: weeklyRunCount,
      avgRunDistanceMeters: avgRunDistance,
      avgRunPaceMinPerKm: avgPace,
      confidence: confidence,
    );
  }

  static int _confidenceScore(
    HealthBaseline baseline,
    List<WorkoutSession> runs,
  ) {
    int score = baseline.dataCompletenessScore;
    if (runs.isNotEmpty) score += 10;
    return score.clamp(0, 100);
  }
}
