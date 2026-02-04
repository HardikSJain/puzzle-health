/// Model representing user's baseline health activity patterns
class HealthBaseline {
  /// Average daily steps over the analysis period
  final double avgSteps;

  /// Average active minutes per day
  final int avgActiveMinutes;

  /// Number of days per week with significant activity
  final int activeDays;

  /// Total days analyzed
  final int totalDays;

  /// Standard deviation of daily steps (measure of consistency)
  final double stepVariance;

  /// Weekday average vs weekend average ratio
  final double weekdayWeekendRatio;

  /// Pattern type: consistent, sporadic, weekend_warrior, weekday_only
  final String patternType;

  const HealthBaseline({
    required this.avgSteps,
    required this.avgActiveMinutes,
    required this.activeDays,
    required this.totalDays,
    required this.stepVariance,
    required this.weekdayWeekendRatio,
    required this.patternType,
  });

  /// Check if user has low activity baseline
  bool get isLowBaseline => avgSteps < 3000;

  /// Check if user is consistent (low variance)
  bool get isConsistent => stepVariance < (avgSteps * 0.3);

  /// Check if user is sporadic (high variance)
  bool get isSporadic => stepVariance > (avgSteps * 0.5);

  /// Check if user is a weekend warrior
  bool get isWeekendWarrior =>
      patternType == 'weekend_warrior' || weekdayWeekendRatio < 0.7;

  /// Check if user is weekday-only active
  bool get isWeekdayOnly =>
      patternType == 'weekday_only' || weekdayWeekendRatio > 1.4;

  Map<String, dynamic> toJson() {
    return {
      'avgSteps': avgSteps,
      'avgActiveMinutes': avgActiveMinutes,
      'activeDays': activeDays,
      'totalDays': totalDays,
      'stepVariance': stepVariance,
      'weekdayWeekendRatio': weekdayWeekendRatio,
      'patternType': patternType,
    };
  }

  factory HealthBaseline.fromJson(Map<String, dynamic> json) {
    return HealthBaseline(
      avgSteps: (json['avgSteps'] as num).toDouble(),
      avgActiveMinutes: json['avgActiveMinutes'] as int,
      activeDays: json['activeDays'] as int,
      totalDays: json['totalDays'] as int,
      stepVariance: (json['stepVariance'] as num).toDouble(),
      weekdayWeekendRatio: (json['weekdayWeekendRatio'] as num).toDouble(),
      patternType: json['patternType'] as String,
    );
  }
}
