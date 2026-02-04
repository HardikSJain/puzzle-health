/// Model representing the user's personalized health target
class HealthTarget {
  /// Target steps per day for this period
  final int targetSteps;

  /// Increment from baseline
  final int incrementSteps;

  /// Baseline steps per day
  final int baselineSteps;

  /// Target type: steps, consistency, pace, etc.
  final String targetType;

  /// Start date of this target period
  final DateTime startDate;

  /// End date of this target period (typically 7 days)
  final DateTime endDate;

  /// Human-readable description of the target
  final String description;

  const HealthTarget({
    required this.targetSteps,
    required this.incrementSteps,
    required this.baselineSteps,
    required this.targetType,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  /// Get the percentage increase from baseline
  double get percentIncrease =>
      ((incrementSteps / baselineSteps) * 100).roundToDouble();

  /// Check if target is achievable (reasonable increase)
  bool get isAchievable => percentIncrease <= 30;

  /// Get duration in days
  int get durationDays => endDate.difference(startDate).inDays;

  Map<String, dynamic> toJson() {
    return {
      'targetSteps': targetSteps,
      'incrementSteps': incrementSteps,
      'baselineSteps': baselineSteps,
      'targetType': targetType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
    };
  }

  factory HealthTarget.fromJson(Map<String, dynamic> json) {
    return HealthTarget(
      targetSteps: json['targetSteps'] as int,
      incrementSteps: json['incrementSteps'] as int,
      baselineSteps: json['baselineSteps'] as int,
      targetType: json['targetType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      description: json['description'] as String,
    );
  }
}
