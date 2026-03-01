import 'fitness_state.dart';
import 'health_baseline.dart';
import 'workout_session.dart';

class UserFitnessProfile {
  final HealthBaseline baseline;
  final FitnessState state;
  final List<String> overlays;
  final List<WorkoutSession> workouts30d;
  final WorkoutSession? lastRun;
  final int weeklyRunCount;
  final double? avgRunDistanceMeters;
  final double? avgRunPaceMinPerKm;
  final int confidence; // 0..100

  const UserFitnessProfile({
    required this.baseline,
    required this.state,
    required this.overlays,
    required this.workouts30d,
    required this.lastRun,
    required this.weeklyRunCount,
    required this.avgRunDistanceMeters,
    required this.avgRunPaceMinPerKm,
    required this.confidence,
  });

  bool get hasRunningData => weeklyRunCount > 0 || lastRun != null;

  Map<String, dynamic> toJson() => {
    'baseline': baseline.toJson(),
    'state': state.key,
    'overlays': overlays,
    'workouts30d': workouts30d.map((e) => e.toJson()).toList(),
    'lastRun': lastRun?.toJson(),
    'weeklyRunCount': weeklyRunCount,
    'avgRunDistanceMeters': avgRunDistanceMeters,
    'avgRunPaceMinPerKm': avgRunPaceMinPerKm,
    'confidence': confidence,
  };

  factory UserFitnessProfile.fromJson(Map<String, dynamic> json) {
    return UserFitnessProfile(
      baseline: HealthBaseline.fromJson(json['baseline'] as Map<String, dynamic>),
      state: FitnessStateX.fromKey(json['state'] as String?),
      overlays: (json['overlays'] as List<dynamic>? ?? []).cast<String>(),
      workouts30d: (json['workouts30d'] as List<dynamic>? ?? [])
          .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastRun: json['lastRun'] != null
          ? WorkoutSession.fromJson(json['lastRun'] as Map<String, dynamic>)
          : null,
      weeklyRunCount: json['weeklyRunCount'] as int? ?? 0,
      avgRunDistanceMeters: (json['avgRunDistanceMeters'] as num?)?.toDouble(),
      avgRunPaceMinPerKm: (json['avgRunPaceMinPerKm'] as num?)?.toDouble(),
      confidence: json['confidence'] as int? ?? 50,
    );
  }
}
