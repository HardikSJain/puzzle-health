import 'dart:math';
import 'package:health/health.dart';
import 'package:logger/logger.dart';
import '../models/health_baseline.dart';

/// Service for analyzing health data and generating comprehensive baselines
/// Processes List<HealthDataPoint> from HealthService
class HealthAnalyzer {
  static final Logger _logger = Logger();

  // ============================================================
  // MAIN ANALYSIS METHOD
  // ============================================================

  /// Analyze raw health data and create comprehensive baseline
  static HealthBaseline analyzeHealthData(
    List<HealthDataPoint> data, {
    int days = 30,
  }) {
    if (data.isEmpty) {
      _logger.w('No health data available, returning default baseline');
      return HealthBaseline.defaultBaseline();
    }

    _logger.i('Analyzing ${data.length} health data points over $days days');

    // Activity analysis
    final activityMetrics = _analyzeActivity(data, days);

    // Vitals analysis
    final vitalsMetrics = _analyzeVitals(data);

    // Sleep analysis
    final sleepMetrics = _analyzeSleep(data, days);

    // Body measurements
    final bodyMetrics = _analyzeBody(data);

    // Pattern analysis
    final patterns = _analyzePatterns(data, days);

    // Data completeness
    final completenessScore = _calculateDataCompleteness(data);

    return HealthBaseline(
      // Activity
      avgSteps: activityMetrics['avgSteps'] ?? 0,
      avgCaloriesBurned: activityMetrics['avgCaloriesBurned'],
      avgDistance: activityMetrics['avgDistance'],
      avgFloorsClimbed: activityMetrics['avgFloorsClimbed'],
      workoutsPerWeek: activityMetrics['workoutsPerWeek'],
      // Vitals
      avgHeartRate: vitalsMetrics['avgHeartRate'],
      avgRestingHeartRate: vitalsMetrics['avgRestingHeartRate'],
      avgHrv: vitalsMetrics['avgHrv'],
      avgSpO2: vitalsMetrics['avgSpO2'],
      avgRespiratoryRate: vitalsMetrics['avgRespiratoryRate'],
      avgSystolicBP: vitalsMetrics['avgSystolicBP'],
      avgDiastolicBP: vitalsMetrics['avgDiastolicBP'],
      // Sleep
      avgSleepDuration: sleepMetrics['avgSleepDuration'],
      avgDeepSleepPercent: sleepMetrics['avgDeepSleepPercent'],
      avgLightSleepPercent: sleepMetrics['avgLightSleepPercent'],
      avgRemSleepPercent: sleepMetrics['avgRemSleepPercent'],
      sleepConsistencyScore: sleepMetrics['sleepConsistencyScore'],
      // Body
      latestWeight: bodyMetrics['latestWeight'],
      latestHeight: bodyMetrics['latestHeight'],
      latestBmi: bodyMetrics['latestBmi'],
      latestBodyFat: bodyMetrics['latestBodyFat'],
      // Patterns
      totalDays: days,
      activeDaysPerWeek: patterns['activeDaysPerWeek'] ?? 0,
      stepVariance: patterns['stepVariance'] ?? 0,
      weekdayWeekendRatio: patterns['weekdayWeekendRatio'] ?? 1.0,
      activityPattern: patterns['activityPattern'] ?? 'building',
      sleepPattern: patterns['sleepPattern'],
      dataCompletenessScore: completenessScore,
    );
  }

  // ============================================================
  // ACTIVITY ANALYSIS
  // ============================================================

  static Map<String, double?> _analyzeActivity(
    List<HealthDataPoint> data,
    int days,
  ) {
    final Map<String, double?> metrics = {};

    // Steps
    final stepData = _filterByType(data, HealthDataType.STEPS);
    if (stepData.isNotEmpty) {
      final dailySteps = _aggregateByDay(stepData);
      final totalSteps = dailySteps.values.fold<double>(0, (a, b) => a + b);
      final daysWithData = dailySteps.length;
      metrics['avgSteps'] = daysWithData > 0 ? totalSteps / daysWithData : 0;
    } else {
      metrics['avgSteps'] = 0;
    }

    // Active calories
    final calorieData = _filterByType(
      data,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    );
    if (calorieData.isNotEmpty) {
      final dailyCalories = _aggregateByDay(calorieData);
      final totalCalories = dailyCalories.values.fold<double>(
        0,
        (a, b) => a + b,
      );
      final daysWithData = dailyCalories.length;
      metrics['avgCaloriesBurned'] = daysWithData > 0
          ? totalCalories / daysWithData
          : null;
    }

    // Distance
    final distanceData = _filterByType(data, HealthDataType.DISTANCE_DELTA);
    if (distanceData.isNotEmpty) {
      final dailyDistance = _aggregateByDay(distanceData);
      final totalDistance = dailyDistance.values.fold<double>(
        0,
        (a, b) => a + b,
      );
      final daysWithData = dailyDistance.length;
      metrics['avgDistance'] = daysWithData > 0
          ? totalDistance / daysWithData
          : null;
    }

    // Floors climbed
    final floorData = _filterByType(data, HealthDataType.FLIGHTS_CLIMBED);
    if (floorData.isNotEmpty) {
      final dailyFloors = _aggregateByDay(floorData);
      final totalFloors = dailyFloors.values.fold<double>(0, (a, b) => a + b);
      final daysWithData = dailyFloors.length;
      metrics['avgFloorsClimbed'] = daysWithData > 0
          ? totalFloors / daysWithData
          : null;
    }

    // Workouts per week
    final workoutData = _filterByType(data, HealthDataType.WORKOUT);
    if (workoutData.isNotEmpty) {
      final weeksInPeriod = days / 7;
      metrics['workoutsPerWeek'] = weeksInPeriod > 0
          ? workoutData.length / weeksInPeriod
          : null;
    }

    return metrics;
  }

  // ============================================================
  // VITALS ANALYSIS
  // ============================================================

  static Map<String, double?> _analyzeVitals(List<HealthDataPoint> data) {
    final Map<String, double?> metrics = {};

    // Heart rate
    final hrData = _filterByType(data, HealthDataType.HEART_RATE);
    if (hrData.isNotEmpty) {
      metrics['avgHeartRate'] = _calculateAverage(hrData);
    }

    // Resting heart rate
    final restingHrData = _filterByType(
      data,
      HealthDataType.RESTING_HEART_RATE,
    );
    if (restingHrData.isNotEmpty) {
      metrics['avgRestingHeartRate'] = _calculateAverage(restingHrData);
    }

    // Heart rate variability
    final hrvData = _filterByType(
      data,
      HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    );
    if (hrvData.isNotEmpty) {
      metrics['avgHrv'] = _calculateAverage(hrvData);
    }

    // Blood oxygen
    final spo2Data = _filterByType(data, HealthDataType.BLOOD_OXYGEN);
    if (spo2Data.isNotEmpty) {
      metrics['avgSpO2'] = _calculateAverage(spo2Data);
    }

    // Respiratory rate
    final respData = _filterByType(data, HealthDataType.RESPIRATORY_RATE);
    if (respData.isNotEmpty) {
      metrics['avgRespiratoryRate'] = _calculateAverage(respData);
    }

    // Blood pressure
    final systolicData = _filterByType(
      data,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    );
    final diastolicData = _filterByType(
      data,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    );
    if (systolicData.isNotEmpty) {
      metrics['avgSystolicBP'] = _calculateAverage(systolicData);
    }
    if (diastolicData.isNotEmpty) {
      metrics['avgDiastolicBP'] = _calculateAverage(diastolicData);
    }

    return metrics;
  }

  // ============================================================
  // SLEEP ANALYSIS
  // ============================================================

  static Map<String, double?> _analyzeSleep(
    List<HealthDataPoint> data,
    int days,
  ) {
    final Map<String, double?> metrics = {};

    // Sleep session data
    final sleepSessionData = _filterByType(data, HealthDataType.SLEEP_SESSION);
    final sleepAsleepData = _filterByType(data, HealthDataType.SLEEP_ASLEEP);

    // Combine sleep data
    final allSleepData = [...sleepSessionData, ...sleepAsleepData];

    if (allSleepData.isNotEmpty) {
      // Calculate average sleep duration in hours
      final sleepDurations = allSleepData.map((point) {
        // Duration is the difference between dateTo and dateFrom in hours
        return point.dateTo.difference(point.dateFrom).inMinutes / 60.0;
      }).toList();

      final totalSleepHours = sleepDurations.fold<double>(0, (a, b) => a + b);
      final sleepSessions = sleepDurations.length;
      metrics['avgSleepDuration'] = sleepSessions > 0
          ? totalSleepHours / sleepSessions
          : null;

      // Calculate sleep consistency (based on variance in sleep duration)
      if (sleepDurations.length >= 3) {
        final stdDev = _calculateStdDev(sleepDurations);
        final avgDuration = totalSleepHours / sleepSessions;
        // Lower variance = higher consistency score
        final varianceRatio = avgDuration > 0 ? stdDev / avgDuration : 1.0;
        metrics['sleepConsistencyScore'] = max(
          0,
          min(100, (1 - varianceRatio) * 100),
        );
      }
    }

    // Sleep stages
    final deepSleepData = _filterByType(data, HealthDataType.SLEEP_DEEP);
    final lightSleepData = _filterByType(data, HealthDataType.SLEEP_LIGHT);
    final remSleepData = _filterByType(data, HealthDataType.SLEEP_REM);

    // Calculate stage percentages if we have stage data
    final totalDeepMinutes = _sumDurations(deepSleepData);
    final totalLightMinutes = _sumDurations(lightSleepData);
    final totalRemMinutes = _sumDurations(remSleepData);
    final totalSleepMinutes =
        totalDeepMinutes + totalLightMinutes + totalRemMinutes;

    if (totalSleepMinutes > 0) {
      metrics['avgDeepSleepPercent'] =
          (totalDeepMinutes / totalSleepMinutes) * 100;
      metrics['avgLightSleepPercent'] =
          (totalLightMinutes / totalSleepMinutes) * 100;
      metrics['avgRemSleepPercent'] =
          (totalRemMinutes / totalSleepMinutes) * 100;
    }

    return metrics;
  }

  // ============================================================
  // BODY MEASUREMENTS ANALYSIS
  // ============================================================

  static Map<String, double?> _analyzeBody(List<HealthDataPoint> data) {
    final Map<String, double?> metrics = {};

    // Weight (get most recent)
    final weightData = _filterByType(data, HealthDataType.WEIGHT);
    if (weightData.isNotEmpty) {
      weightData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      metrics['latestWeight'] = _getNumericValue(weightData.first);
    }

    // Height (get most recent)
    final heightData = _filterByType(data, HealthDataType.HEIGHT);
    if (heightData.isNotEmpty) {
      heightData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      metrics['latestHeight'] = _getNumericValue(heightData.first);
    }

    // BMI (get most recent)
    final bmiData = _filterByType(data, HealthDataType.BODY_MASS_INDEX);
    if (bmiData.isNotEmpty) {
      bmiData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      metrics['latestBmi'] = _getNumericValue(bmiData.first);
    } else if (metrics['latestWeight'] != null &&
        metrics['latestHeight'] != null) {
      // Calculate BMI if we have weight and height
      final weight = metrics['latestWeight']!;
      final height = metrics['latestHeight']!;
      if (height > 0) {
        metrics['latestBmi'] = weight / (height * height);
      }
    }

    // Body fat percentage (get most recent)
    final bodyFatData = _filterByType(data, HealthDataType.BODY_FAT_PERCENTAGE);
    if (bodyFatData.isNotEmpty) {
      bodyFatData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      metrics['latestBodyFat'] = _getNumericValue(bodyFatData.first);
    }

    return metrics;
  }

  // ============================================================
  // PATTERN ANALYSIS
  // ============================================================

  static Map<String, dynamic> _analyzePatterns(
    List<HealthDataPoint> data,
    int days,
  ) {
    final Map<String, dynamic> patterns = {};

    // Analyze step patterns
    final stepData = _filterByType(data, HealthDataType.STEPS);
    final dailySteps = _aggregateByDay(stepData);

    if (dailySteps.isNotEmpty) {
      final stepValues = dailySteps.values.toList();

      // Step variance
      patterns['stepVariance'] = _calculateStdDev(stepValues);

      // Active days per week (days with > 2000 steps)
      final activeDays = stepValues.where((s) => s > 2000).length;
      final weeksInPeriod = max(1, days / 7);
      patterns['activeDaysPerWeek'] = (activeDays / weeksInPeriod)
          .round()
          .clamp(0, 7);

      // Weekday vs weekend pattern
      patterns['weekdayWeekendRatio'] = _calculateWeekdayWeekendRatio(stepData);

      // Determine activity pattern
      patterns['activityPattern'] = _determineActivityPattern(
        avgSteps:
            stepValues.fold<double>(0, (a, b) => a + b) / stepValues.length,
        variance: patterns['stepVariance'],
        weekdayWeekendRatio: patterns['weekdayWeekendRatio'],
        activeDaysPerWeek: patterns['activeDaysPerWeek'],
      );
    } else {
      patterns['stepVariance'] = 0.0;
      patterns['activeDaysPerWeek'] = 0;
      patterns['weekdayWeekendRatio'] = 1.0;
      patterns['activityPattern'] = 'building';
    }

    // Analyze sleep patterns
    final sleepData = [
      ..._filterByType(data, HealthDataType.SLEEP_SESSION),
      ..._filterByType(data, HealthDataType.SLEEP_ASLEEP),
    ];
    if (sleepData.isNotEmpty) {
      patterns['sleepPattern'] = _determineSleepPattern(sleepData);
    }

    return patterns;
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Filter data points by type
  static List<HealthDataPoint> _filterByType(
    List<HealthDataPoint> data,
    HealthDataType type,
  ) {
    return data.where((point) => point.type == type).toList();
  }

  /// Get numeric value from health data point
  static double? _getNumericValue(HealthDataPoint point) {
    final value = point.value;
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return null;
  }

  /// Calculate average of numeric health data points
  static double? _calculateAverage(List<HealthDataPoint> data) {
    if (data.isEmpty) return null;
    double sum = 0;
    int count = 0;
    for (final point in data) {
      final value = _getNumericValue(point);
      if (value != null) {
        sum += value;
        count++;
      }
    }
    return count > 0 ? sum / count : null;
  }

  /// Aggregate data by day (returns map of date string to sum)
  static Map<String, double> _aggregateByDay(List<HealthDataPoint> data) {
    final Map<String, double> daily = {};
    for (final point in data) {
      final dateKey = _formatDateKey(point.dateFrom);
      final value = _getNumericValue(point) ?? 0;
      daily[dateKey] = (daily[dateKey] ?? 0) + value;
    }
    return daily;
  }

  /// Format date as YYYY-MM-DD
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Calculate standard deviation
  static double _calculateStdDev(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2)).toList();
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    return sqrt(variance);
  }

  /// Sum durations of data points in minutes
  static double _sumDurations(List<HealthDataPoint> data) {
    return data.fold<double>(0, (sum, point) {
      return sum + point.dateTo.difference(point.dateFrom).inMinutes;
    });
  }

  /// Calculate weekday vs weekend ratio
  static double _calculateWeekdayWeekendRatio(List<HealthDataPoint> data) {
    final Map<String, double> weekdaySteps = {};
    final Map<String, double> weekendSteps = {};

    for (final point in data) {
      final dateKey = _formatDateKey(point.dateFrom);
      final value = _getNumericValue(point) ?? 0;
      final isWeekend =
          point.dateFrom.weekday == DateTime.saturday ||
          point.dateFrom.weekday == DateTime.sunday;

      if (isWeekend) {
        weekendSteps[dateKey] = (weekendSteps[dateKey] ?? 0) + value;
      } else {
        weekdaySteps[dateKey] = (weekdaySteps[dateKey] ?? 0) + value;
      }
    }

    final weekdayAvg = weekdaySteps.isNotEmpty
        ? weekdaySteps.values.reduce((a, b) => a + b) / weekdaySteps.length
        : 0.0;
    final weekendAvg = weekendSteps.isNotEmpty
        ? weekendSteps.values.reduce((a, b) => a + b) / weekendSteps.length
        : 0.0;

    if (weekendAvg == 0) return 1.0;
    return weekdayAvg / weekendAvg;
  }

  /// Determine activity pattern type
  static String _determineActivityPattern({
    required double avgSteps,
    required double variance,
    required double weekdayWeekendRatio,
    required int activeDaysPerWeek,
  }) {
    // Check consistency first
    final isConsistent = variance < (avgSteps * 0.3);
    final isSporadic = variance > (avgSteps * 0.5);

    // Check weekday/weekend patterns
    final isWeekendWarrior = weekdayWeekendRatio < 0.7;
    final isWeekdayOnly = weekdayWeekendRatio > 1.4;

    // Determine primary pattern
    if (isWeekendWarrior) return 'weekend_warrior';
    if (isWeekdayOnly) return 'weekday_only';
    if (isSporadic) return 'sporadic';
    if (isConsistent && activeDaysPerWeek >= 5) return 'consistent';

    return 'building';
  }

  /// Determine sleep pattern type
  static String _determineSleepPattern(List<HealthDataPoint> sleepData) {
    if (sleepData.isEmpty) return 'unknown';

    // Analyze sleep start times
    final sleepStartHours = sleepData.map((p) => p.dateFrom.hour).toList();
    final avgSleepStartHour =
        sleepStartHours.reduce((a, b) => a + b) / sleepStartHours.length;

    // Calculate variance in sleep times
    final sleepTimeVariance = _calculateStdDev(
      sleepStartHours.map((h) => h.toDouble()).toList(),
    );

    // Determine pattern
    if (sleepTimeVariance < 1.5) {
      // Consistent sleep schedule
      if (avgSleepStartHour < 22) {
        return 'early_bird';
      } else if (avgSleepStartHour > 24) {
        return 'night_owl';
      }
      return 'consistent';
    }
    return 'irregular';
  }

  /// Calculate data completeness score (0-100)
  static int _calculateDataCompleteness(List<HealthDataPoint> data) {
    int score = 0;
    const int pointsPerCategory = 20;

    // Check each category
    if (_filterByType(data, HealthDataType.STEPS).isNotEmpty) {
      score += pointsPerCategory;
    }
    if (_filterByType(data, HealthDataType.HEART_RATE).isNotEmpty ||
        _filterByType(data, HealthDataType.RESTING_HEART_RATE).isNotEmpty) {
      score += pointsPerCategory;
    }
    if (_filterByType(data, HealthDataType.SLEEP_SESSION).isNotEmpty ||
        _filterByType(data, HealthDataType.SLEEP_ASLEEP).isNotEmpty) {
      score += pointsPerCategory;
    }
    if (_filterByType(data, HealthDataType.WEIGHT).isNotEmpty) {
      score += pointsPerCategory;
    }
    if (_filterByType(data, HealthDataType.ACTIVE_ENERGY_BURNED).isNotEmpty) {
      score += pointsPerCategory;
    }

    return score;
  }

  // ============================================================
  // INSIGHT GENERATION
  // ============================================================

  /// Generate insight message based on baseline pattern
  static String generateInsight(HealthBaseline baseline) {
    final avgSteps = baseline.avgSteps.round();

    // Pattern-based insights
    if (baseline.isConsistent && avgSteps >= 5000) {
      return "You're already moving consistently. Nice.";
    }

    if (baseline.isConsistent && avgSteps < 5000) {
      return "You show up every day. Let's build on that.";
    }

    if (baseline.isSporadic && avgSteps > 5000) {
      return "When you move, you MOVE. Let's make it regular.";
    }

    if (baseline.isSporadic && avgSteps < 5000) {
      return "You move in bursts. Let's make it steadier.";
    }

    if (baseline.isWeekendWarrior) {
      return "Weekends are your time. Let's bring that energy to weekdays.";
    }

    if (baseline.isWeekdayOnly) {
      return "You do great on weekdays. Weekends are lighter.";
    }

    if (avgSteps < 2000) {
      return "You're just getting started. Perfect.";
    }

    if (avgSteps >= 10000) {
      return "You're crushing steps already. Impressive.";
    }

    // Check for sleep insights
    if (baseline.hasSleepData) {
      if (baseline.isSleepDeprived) {
        return "Your sleep could use some love. Let's work on that too.";
      }
    }

    // Default fallback
    return "You have a solid baseline. Let's keep building.";
  }

  /// Generate target steps based on baseline
  static int generateTargetSteps(HealthBaseline baseline) {
    final baselineSteps = baseline.avgSteps.round();

    if (baselineSteps < 2000) {
      // Very low baseline: +50% increase (but at least +500 steps)
      return max((baselineSteps * 1.5).round(), baselineSteps + 500);
    } else if (baselineSteps < 3000) {
      // Low baseline: +40% increase
      return (baselineSteps * 1.4).round();
    } else if (baselineSteps < 5000) {
      // Moderate-low baseline: +25% increase
      return (baselineSteps * 1.25).round();
    } else if (baselineSteps < 7000) {
      // Moderate baseline: +15% increase
      return (baselineSteps * 1.15).round();
    } else if (baselineSteps < 10000) {
      // Good baseline: +10% increase
      return (baselineSteps * 1.1).round();
    } else {
      // High baseline: +5-8% increase
      if (baseline.isSporadic) {
        return (baselineSteps * 1.05).round();
      }
      return (baselineSteps * 1.08).round();
    }
  }
}
