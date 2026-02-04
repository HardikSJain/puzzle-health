import 'dart:math';
import 'package:logger/logger.dart';
import '../models/health_baseline.dart';
import '../models/health_target.dart';
import 'health_service.dart';

/// Service for analyzing health data and generating personalized targets
class HealthAnalyzer {
  static final _logger = Logger();

  /// Calculate baseline from step data
  static HealthBaseline calculateBaseline(List<StepData> stepData) {
    if (stepData.isEmpty) {
      _logger.w('No step data available, using default baseline');
      return _getDefaultBaseline();
    }

    // Filter out days with 0 steps (likely data gaps)
    final validDays = stepData.where((d) => d.steps > 0).toList();

    if (validDays.isEmpty) {
      return _getDefaultBaseline();
    }

    // Calculate average steps
    final totalSteps = validDays.fold<int>(0, (sum, d) => sum + d.steps);
    final avgSteps = totalSteps / validDays.length;

    // Calculate step variance (standard deviation)
    final variance = _calculateStdDev(validDays.map((d) => d.steps.toDouble()).toList());

    // Calculate weekday vs weekend patterns
    final weekdayData = validDays.where((d) => d.isWeekday).toList();
    final weekendData = validDays.where((d) => d.isWeekend).toList();

    final weekdayAvg = weekdayData.isEmpty
        ? avgSteps
        : weekdayData.fold<int>(0, (sum, d) => sum + d.steps) / weekdayData.length;
    final weekendAvg = weekendData.isEmpty
        ? avgSteps
        : weekendData.fold<int>(0, (sum, d) => sum + d.steps) / weekendData.length;

    final weekdayWeekendRatio = weekendAvg == 0 ? 1.0 : weekdayAvg / weekendAvg;

    // Count active days (days with significant movement, e.g., >2000 steps)
    final activeDays = validDays.where((d) => d.steps > 2000).length;
    final activeDaysPerWeek = (activeDays / validDays.length * 7).round();

    // Determine pattern type
    final patternType = _determinePatternType(
      avgSteps: avgSteps,
      variance: variance,
      weekdayWeekendRatio: weekdayWeekendRatio,
      activeDaysPerWeek: activeDaysPerWeek,
    );

    // Estimate active minutes (rough calculation: 100 steps ≈ 1 minute)
    final avgActiveMinutes = (avgSteps / 100).round();

    _logger.i('Calculated baseline: $avgSteps steps, $activeDaysPerWeek days/week, pattern: $patternType');

    return HealthBaseline(
      avgSteps: avgSteps,
      avgActiveMinutes: avgActiveMinutes,
      activeDays: activeDaysPerWeek,
      totalDays: validDays.length,
      stepVariance: variance,
      weekdayWeekendRatio: weekdayWeekendRatio,
      patternType: patternType,
    );
  }

  /// Generate personalized target based on baseline
  static HealthTarget generateTarget(HealthBaseline baseline) {
    final baselineSteps = baseline.avgSteps.round();
    int targetSteps;
    String description;

    // Adaptive targeting based on baseline and pattern
    if (baselineSteps < 2000) {
      // Very low baseline: +50% increase (but at least +500 steps)
      targetSteps = max((baselineSteps * 1.5).round(), baselineSteps + 500);
      description = 'Build the foundation';
    } else if (baselineSteps < 3000) {
      // Low baseline: +40% increase
      targetSteps = (baselineSteps * 1.4).round();
      description = 'Build momentum';
    } else if (baselineSteps < 5000) {
      // Moderate-low baseline: +25% increase
      targetSteps = (baselineSteps * 1.25).round();
      description = 'Increase consistency';
    } else if (baselineSteps < 7000) {
      // Moderate baseline: +15% increase
      targetSteps = (baselineSteps * 1.15).round();
      description = 'Level up your movement';
    } else if (baselineSteps < 10000) {
      // Good baseline: +10% increase
      targetSteps = (baselineSteps * 1.1).round();
      description = 'Push a bit further';
    } else {
      // High baseline: +5-8% increase or focus on consistency
      if (baseline.isSporadic) {
        targetSteps = (baselineSteps * 1.05).round();
        description = 'Make it consistent';
      } else {
        targetSteps = (baselineSteps * 1.08).round();
        description = 'Maintain excellence';
      }
    }

    // For sporadic patterns, be more conservative
    if (baseline.isSporadic && baselineSteps > 3000) {
      targetSteps = min(targetSteps, (baselineSteps * 1.15).round());
      description = 'Build consistency first';
    }

    final incrementSteps = targetSteps - baselineSteps;
    final now = DateTime.now();
    final startDate = now;
    final endDate = now.add(const Duration(days: 7));

    _logger.i('Generated target: $targetSteps steps (+$incrementSteps from baseline)');

    return HealthTarget(
      targetSteps: targetSteps,
      incrementSteps: incrementSteps,
      baselineSteps: baselineSteps,
      targetType: 'steps',
      startDate: startDate,
      endDate: endDate,
      description: description,
    );
  }

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

    // Default fallback
    return "You have a solid baseline. Let's keep building.";
  }

  /// Determine activity pattern type
  static String _determinePatternType({
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
    if (isWeekendWarrior) {
      return 'weekend_warrior';
    }

    if (isWeekdayOnly) {
      return 'weekday_only';
    }

    if (isSporadic) {
      return 'sporadic';
    }

    if (isConsistent && activeDaysPerWeek >= 5) {
      return 'consistent';
    }

    return 'building';
  }

  /// Calculate standard deviation
  static double _calculateStdDev(List<double> values) {
    if (values.isEmpty) return 0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2)).toList();
    final variance = squaredDiffs.reduce((a, b) => a + b) / values.length;
    return sqrt(variance);
  }

  /// Get default baseline for users with no data
  static HealthBaseline _getDefaultBaseline() {
    return const HealthBaseline(
      avgSteps: 2000,
      avgActiveMinutes: 20,
      activeDays: 3,
      totalDays: 30,
      stepVariance: 1000,
      weekdayWeekendRatio: 1.0,
      patternType: 'building',
    );
  }
}
