/// Model representing user's comprehensive health baseline
/// Includes activity, vitals, sleep, body measurements, and pattern analysis
class HealthBaseline {
  // ============================================================
  // ACTIVITY METRICS
  // ============================================================

  /// Average daily steps over the analysis period
  final double avgSteps;

  /// Average daily calories burned (active)
  final double? avgCaloriesBurned;

  /// Average daily distance in meters
  final double? avgDistance;

  /// Average daily floors climbed
  final double? avgFloorsClimbed;

  /// Number of workouts per week
  final double? workoutsPerWeek;

  // ============================================================
  // VITALS METRICS
  // ============================================================

  /// Average heart rate (bpm)
  final double? avgHeartRate;

  /// Average resting heart rate (bpm)
  final double? avgRestingHeartRate;

  /// Average heart rate variability (ms)
  final double? avgHrv;

  /// Average blood oxygen saturation (%)
  final double? avgSpO2;

  /// Average respiratory rate (breaths per minute)
  final double? avgRespiratoryRate;

  /// Average systolic blood pressure (mmHg)
  final double? avgSystolicBP;

  /// Average diastolic blood pressure (mmHg)
  final double? avgDiastolicBP;

  // ============================================================
  // SLEEP METRICS
  // ============================================================

  /// Average sleep duration in hours
  final double? avgSleepDuration;

  /// Average deep sleep percentage
  final double? avgDeepSleepPercent;

  /// Average light sleep percentage
  final double? avgLightSleepPercent;

  /// Average REM sleep percentage
  final double? avgRemSleepPercent;

  /// Sleep consistency score (0-100)
  final double? sleepConsistencyScore;

  // ============================================================
  // BODY METRICS
  // ============================================================

  /// Latest weight in kg
  final double? latestWeight;

  /// Latest height in meters
  final double? latestHeight;

  /// Latest BMI
  final double? latestBmi;

  /// Latest body fat percentage
  final double? latestBodyFat;

  // ============================================================
  // PATTERN ANALYSIS
  // ============================================================

  /// Total days analyzed
  final int totalDays;

  /// Number of days per week with significant activity
  final int activeDaysPerWeek;

  /// Standard deviation of daily steps (measure of consistency)
  final double stepVariance;

  /// Weekday average vs weekend average ratio
  final double weekdayWeekendRatio;

  /// Activity pattern type: consistent, sporadic, weekend_warrior, weekday_only, building
  final String activityPattern;

  /// Sleep pattern type: consistent, irregular, night_owl, early_bird
  final String? sleepPattern;

  /// Data completeness score (0-100) - how much health data is available
  final int dataCompletenessScore;

  const HealthBaseline({
    // Activity
    required this.avgSteps,
    this.avgCaloriesBurned,
    this.avgDistance,
    this.avgFloorsClimbed,
    this.workoutsPerWeek,
    // Vitals
    this.avgHeartRate,
    this.avgRestingHeartRate,
    this.avgHrv,
    this.avgSpO2,
    this.avgRespiratoryRate,
    this.avgSystolicBP,
    this.avgDiastolicBP,
    // Sleep
    this.avgSleepDuration,
    this.avgDeepSleepPercent,
    this.avgLightSleepPercent,
    this.avgRemSleepPercent,
    this.sleepConsistencyScore,
    // Body
    this.latestWeight,
    this.latestHeight,
    this.latestBmi,
    this.latestBodyFat,
    // Pattern analysis
    required this.totalDays,
    required this.activeDaysPerWeek,
    required this.stepVariance,
    required this.weekdayWeekendRatio,
    required this.activityPattern,
    this.sleepPattern,
    required this.dataCompletenessScore,
  });

  // ============================================================
  // COMPUTED PROPERTIES - ACTIVITY
  // ============================================================

  /// Check if user has low activity baseline
  bool get isLowBaseline => avgSteps < 3000;

  /// Check if user has moderate activity baseline
  bool get isModerateBaseline => avgSteps >= 3000 && avgSteps < 7000;

  /// Check if user has high activity baseline
  bool get isHighBaseline => avgSteps >= 7000;

  /// Check if user is consistent (low variance)
  bool get isConsistent => stepVariance < (avgSteps * 0.3);

  /// Check if user is sporadic (high variance)
  bool get isSporadic => stepVariance > (avgSteps * 0.5);

  /// Check if user is a weekend warrior
  bool get isWeekendWarrior =>
      activityPattern == 'weekend_warrior' || weekdayWeekendRatio < 0.7;

  /// Check if user is weekday-only active
  bool get isWeekdayOnly =>
      activityPattern == 'weekday_only' || weekdayWeekendRatio > 1.4;

  // ============================================================
  // COMPUTED PROPERTIES - VITALS
  // ============================================================

  /// Check if heart rate data is available
  bool get hasHeartRateData =>
      avgHeartRate != null || avgRestingHeartRate != null;

  /// Check if blood pressure data is available
  bool get hasBloodPressureData =>
      avgSystolicBP != null && avgDiastolicBP != null;

  /// Check if resting heart rate is in healthy range (60-100 bpm for adults)
  bool get isRestingHRHealthy =>
      avgRestingHeartRate != null &&
      avgRestingHeartRate! >= 40 &&
      avgRestingHeartRate! <= 100;

  // ============================================================
  // COMPUTED PROPERTIES - SLEEP
  // ============================================================

  /// Check if sleep data is available
  bool get hasSleepData => avgSleepDuration != null;

  /// Check if getting recommended sleep (7-9 hours for adults)
  bool get isGettingEnoughSleep =>
      avgSleepDuration != null &&
      avgSleepDuration! >= 7 &&
      avgSleepDuration! <= 9;

  /// Check if sleep duration is too short
  bool get isSleepDeprived => avgSleepDuration != null && avgSleepDuration! < 6;

  // ============================================================
  // COMPUTED PROPERTIES - BODY
  // ============================================================

  /// Check if body data is available
  bool get hasBodyData => latestWeight != null || latestHeight != null;

  /// Check if BMI is in healthy range (18.5-24.9)
  bool get isBmiHealthy =>
      latestBmi != null && latestBmi! >= 18.5 && latestBmi! <= 24.9;

  // ============================================================
  // COMPUTED PROPERTIES - DATA QUALITY
  // ============================================================

  /// Check if we have comprehensive data
  bool get hasComprehensiveData => dataCompletenessScore >= 70;

  /// Check if we have minimal data
  bool get hasMinimalData => dataCompletenessScore < 30;

  /// Check if vitals data is available
  bool get hasVitalsData =>
      avgHeartRate != null ||
      avgRestingHeartRate != null ||
      avgSpO2 != null ||
      avgRespiratoryRate != null;

  // ============================================================
  // SERIALIZATION
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      // Activity
      'avgSteps': avgSteps,
      'avgCaloriesBurned': avgCaloriesBurned,
      'avgDistance': avgDistance,
      'avgFloorsClimbed': avgFloorsClimbed,
      'workoutsPerWeek': workoutsPerWeek,
      // Vitals
      'avgHeartRate': avgHeartRate,
      'avgRestingHeartRate': avgRestingHeartRate,
      'avgHrv': avgHrv,
      'avgSpO2': avgSpO2,
      'avgRespiratoryRate': avgRespiratoryRate,
      'avgSystolicBP': avgSystolicBP,
      'avgDiastolicBP': avgDiastolicBP,
      // Sleep
      'avgSleepDuration': avgSleepDuration,
      'avgDeepSleepPercent': avgDeepSleepPercent,
      'avgLightSleepPercent': avgLightSleepPercent,
      'avgRemSleepPercent': avgRemSleepPercent,
      'sleepConsistencyScore': sleepConsistencyScore,
      // Body
      'latestWeight': latestWeight,
      'latestHeight': latestHeight,
      'latestBmi': latestBmi,
      'latestBodyFat': latestBodyFat,
      // Pattern analysis
      'totalDays': totalDays,
      'activeDaysPerWeek': activeDaysPerWeek,
      'stepVariance': stepVariance,
      'weekdayWeekendRatio': weekdayWeekendRatio,
      'activityPattern': activityPattern,
      'sleepPattern': sleepPattern,
      'dataCompletenessScore': dataCompletenessScore,
    };
  }

  factory HealthBaseline.fromJson(Map<String, dynamic> json) {
    return HealthBaseline(
      // Activity
      avgSteps: (json['avgSteps'] as num).toDouble(),
      avgCaloriesBurned: (json['avgCaloriesBurned'] as num?)?.toDouble(),
      avgDistance: (json['avgDistance'] as num?)?.toDouble(),
      avgFloorsClimbed: (json['avgFloorsClimbed'] as num?)?.toDouble(),
      workoutsPerWeek: (json['workoutsPerWeek'] as num?)?.toDouble(),
      // Vitals
      avgHeartRate: (json['avgHeartRate'] as num?)?.toDouble(),
      avgRestingHeartRate: (json['avgRestingHeartRate'] as num?)?.toDouble(),
      avgHrv: (json['avgHrv'] as num?)?.toDouble(),
      avgSpO2: (json['avgSpO2'] as num?)?.toDouble(),
      avgRespiratoryRate: (json['avgRespiratoryRate'] as num?)?.toDouble(),
      avgSystolicBP: (json['avgSystolicBP'] as num?)?.toDouble(),
      avgDiastolicBP: (json['avgDiastolicBP'] as num?)?.toDouble(),
      // Sleep
      avgSleepDuration: (json['avgSleepDuration'] as num?)?.toDouble(),
      avgDeepSleepPercent: (json['avgDeepSleepPercent'] as num?)?.toDouble(),
      avgLightSleepPercent: (json['avgLightSleepPercent'] as num?)?.toDouble(),
      avgRemSleepPercent: (json['avgRemSleepPercent'] as num?)?.toDouble(),
      sleepConsistencyScore: (json['sleepConsistencyScore'] as num?)
          ?.toDouble(),
      // Body
      latestWeight: (json['latestWeight'] as num?)?.toDouble(),
      latestHeight: (json['latestHeight'] as num?)?.toDouble(),
      latestBmi: (json['latestBmi'] as num?)?.toDouble(),
      latestBodyFat: (json['latestBodyFat'] as num?)?.toDouble(),
      // Pattern analysis
      totalDays: json['totalDays'] as int,
      activeDaysPerWeek: json['activeDaysPerWeek'] as int,
      stepVariance: (json['stepVariance'] as num).toDouble(),
      weekdayWeekendRatio: (json['weekdayWeekendRatio'] as num).toDouble(),
      activityPattern: json['activityPattern'] as String,
      sleepPattern: json['sleepPattern'] as String?,
      dataCompletenessScore: json['dataCompletenessScore'] as int,
    );
  }

  /// Create a default baseline for users with no data
  factory HealthBaseline.defaultBaseline() {
    return const HealthBaseline(
      avgSteps: 2000,
      totalDays: 0,
      activeDaysPerWeek: 3,
      stepVariance: 1000,
      weekdayWeekendRatio: 1.0,
      activityPattern: 'building',
      dataCompletenessScore: 0,
    );
  }

  /// Create a copy with updated fields
  HealthBaseline copyWith({
    double? avgSteps,
    double? avgCaloriesBurned,
    double? avgDistance,
    double? avgFloorsClimbed,
    double? workoutsPerWeek,
    double? avgHeartRate,
    double? avgRestingHeartRate,
    double? avgHrv,
    double? avgSpO2,
    double? avgRespiratoryRate,
    double? avgSystolicBP,
    double? avgDiastolicBP,
    double? avgSleepDuration,
    double? avgDeepSleepPercent,
    double? avgLightSleepPercent,
    double? avgRemSleepPercent,
    double? sleepConsistencyScore,
    double? latestWeight,
    double? latestHeight,
    double? latestBmi,
    double? latestBodyFat,
    int? totalDays,
    int? activeDaysPerWeek,
    double? stepVariance,
    double? weekdayWeekendRatio,
    String? activityPattern,
    String? sleepPattern,
    int? dataCompletenessScore,
  }) {
    return HealthBaseline(
      avgSteps: avgSteps ?? this.avgSteps,
      avgCaloriesBurned: avgCaloriesBurned ?? this.avgCaloriesBurned,
      avgDistance: avgDistance ?? this.avgDistance,
      avgFloorsClimbed: avgFloorsClimbed ?? this.avgFloorsClimbed,
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      avgRestingHeartRate: avgRestingHeartRate ?? this.avgRestingHeartRate,
      avgHrv: avgHrv ?? this.avgHrv,
      avgSpO2: avgSpO2 ?? this.avgSpO2,
      avgRespiratoryRate: avgRespiratoryRate ?? this.avgRespiratoryRate,
      avgSystolicBP: avgSystolicBP ?? this.avgSystolicBP,
      avgDiastolicBP: avgDiastolicBP ?? this.avgDiastolicBP,
      avgSleepDuration: avgSleepDuration ?? this.avgSleepDuration,
      avgDeepSleepPercent: avgDeepSleepPercent ?? this.avgDeepSleepPercent,
      avgLightSleepPercent: avgLightSleepPercent ?? this.avgLightSleepPercent,
      avgRemSleepPercent: avgRemSleepPercent ?? this.avgRemSleepPercent,
      sleepConsistencyScore:
          sleepConsistencyScore ?? this.sleepConsistencyScore,
      latestWeight: latestWeight ?? this.latestWeight,
      latestHeight: latestHeight ?? this.latestHeight,
      latestBmi: latestBmi ?? this.latestBmi,
      latestBodyFat: latestBodyFat ?? this.latestBodyFat,
      totalDays: totalDays ?? this.totalDays,
      activeDaysPerWeek: activeDaysPerWeek ?? this.activeDaysPerWeek,
      stepVariance: stepVariance ?? this.stepVariance,
      weekdayWeekendRatio: weekdayWeekendRatio ?? this.weekdayWeekendRatio,
      activityPattern: activityPattern ?? this.activityPattern,
      sleepPattern: sleepPattern ?? this.sleepPattern,
      dataCompletenessScore:
          dataCompletenessScore ?? this.dataCompletenessScore,
    );
  }
}
