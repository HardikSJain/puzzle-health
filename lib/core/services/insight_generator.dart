import 'package:flutter/material.dart';
import '../models/health_baseline.dart';
import '../models/health_insight.dart';

/// Service for generating smart, honest insights from health data.
/// Designed with a clean interface for easy migration to backend later.
class InsightGenerator {
  /// Generate a list of insights from the health baseline.
  /// Returns 1-2 insights: step baseline + pattern insight.
  static List<HealthInsight> generateInsights(HealthBaseline baseline) {
    final insights = <HealthInsight>[];

    // Always add step insight (primary metric)
    insights.add(_generateStepInsight(baseline));

    // Add one pattern insight to justify the first focus
    insights.add(_generatePatternInsight(baseline));

    return insights;
  }

  /// Generate the primary step insight
  static HealthInsight _generateStepInsight(HealthBaseline baseline) {
    final steps = baseline.avgSteps.round();

    return HealthInsight.steps(
      avgSteps: steps,
      subtitle: "Average daily movement over ${baseline.totalDays} days.",
      type: InsightType.neutral,
    );
  }

  /// Generate sleep insight
  static HealthInsight _generateSleepInsight(HealthBaseline baseline) {
    final hours = baseline.avgSleepDuration!;

    if (hours < 5) {
      return HealthInsight.sleep(
        avgHours: hours,
        subtitle: "That's concerning. Your body needs more.",
        type: InsightType.honest,
      );
    } else if (hours < 6) {
      return HealthInsight.sleep(
        avgHours: hours,
        subtitle: "Running on fumes. We see you.",
        type: InsightType.honest,
      );
    } else if (hours < 7) {
      return HealthInsight.sleep(
        avgHours: hours,
        subtitle: "A bit under. Most adults need 7-9 hours.",
        type: InsightType.neutral,
      );
    } else if (hours <= 9) {
      return HealthInsight.sleep(
        avgHours: hours,
        subtitle: "Right in the sweet spot. Your body thanks you.",
        type: InsightType.positive,
      );
    } else {
      return HealthInsight.sleep(
        avgHours: hours,
        subtitle: "Plenty of rest. Quality matters too.",
        type: InsightType.neutral,
      );
    }
  }

  /// Generate heart rate insight
  static HealthInsight? _generateHeartRateInsight(HealthBaseline baseline) {
    // Prefer resting heart rate as it's more meaningful
    if (baseline.avgRestingHeartRate != null) {
      final rhr = baseline.avgRestingHeartRate!.round();

      if (rhr < 50) {
        return HealthInsight.heartRate(
          avgBpm: rhr,
          subtitle: "Athletic territory. That's a well-trained heart.",
          type: InsightType.positive,
        );
      } else if (rhr < 60) {
        return HealthInsight.heartRate(
          avgBpm: rhr,
          subtitle: "Excellent resting rate. Your heart's efficient.",
          type: InsightType.positive,
        );
      } else if (rhr < 80) {
        return HealthInsight.heartRate(
          avgBpm: rhr,
          subtitle: "Normal range. Steady and reliable.",
          type: InsightType.neutral,
        );
      } else {
        return HealthInsight.heartRate(
          avgBpm: rhr,
          subtitle: "On the higher side. Worth keeping an eye on.",
          type: InsightType.honest,
        );
      }
    }

    // Fall back to average heart rate
    if (baseline.avgHeartRate != null) {
      final hr = baseline.avgHeartRate!.round();
      return HealthInsight(
        title: '$hr bpm average',
        subtitle: "Your heart's been busy. We're tracking it.",
        type: InsightType.neutral,
        category: InsightCategory.heartRate,
        icon: Icons.favorite_rounded,
        numericValue: hr.toDouble(),
        unit: 'bpm',
      );
    }

    return null;
  }

  /// Generate weight insight
  static HealthInsight _generateWeightInsight(HealthBaseline baseline) {
    final weight = baseline.latestWeight!;

    // If we have BMI, use it for context
    if (baseline.latestBmi != null) {
      final bmi = baseline.latestBmi!;
      String subtitle;
      InsightType type;

      if (bmi < 18.5) {
        subtitle =
            "BMI suggests underweight. Talk to your doctor if concerned.";
        type = InsightType.neutral;
      } else if (bmi < 25) {
        subtitle = "Healthy BMI range. Keep it up.";
        type = InsightType.positive;
      } else if (bmi < 30) {
        subtitle = "BMI in overweight range. Movement helps.";
        type = InsightType.honest;
      } else {
        subtitle = "BMI suggests obesity. Small steps matter.";
        type = InsightType.honest;
      }

      return HealthInsight.weight(
        weightKg: weight,
        subtitle: subtitle,
        type: type,
      );
    }

    // Without BMI, just report the weight
    return HealthInsight.weight(
      weightKg: weight,
      subtitle: "Your latest reading. We'll track changes.",
      type: InsightType.neutral,
    );
  }

  /// Generate pattern insight based on activity patterns
  static HealthInsight _generatePatternInsight(HealthBaseline baseline) {
    // Check for weekend warrior pattern - constraint
    if (baseline.isWeekendWarrior) {
      return HealthInsight.pattern(
        title: "Weekend spike",
        subtitle:
            "Activity increases ${((1 / baseline.weekdayWeekendRatio - 1) * 100).round()}% on weekends. Weekday baseline remains low.",
        type: InsightType.honest,
        icon: Icons.weekend_rounded,
      );
    }

    // Check for weekday-only pattern - constraint
    if (baseline.isWeekdayOnly) {
      return HealthInsight.pattern(
        title: "Weekday pattern",
        subtitle:
            "Weekend activity drops sharply. This limits weekly consistency.",
        type: InsightType.honest,
        icon: Icons.work_rounded,
      );
    }

    // Check for sporadic pattern - constraint
    if (baseline.isSporadic) {
      return HealthInsight.pattern(
        title: "High variance",
        subtitle:
            "Daily activity fluctuates significantly. Pattern shows inconsistent movement.",
        type: InsightType.honest,
        icon: Icons.show_chart_rounded,
      );
    }

    // Check for consistent pattern - no constraint
    if (baseline.isConsistent) {
      return HealthInsight.pattern(
        title: "Stable pattern",
        subtitle: "Daily activity remains within consistent range.",
        type: InsightType.neutral,
        icon: Icons.check_circle_rounded,
      );
    }

    // Default pattern insight - neutral
    return HealthInsight.pattern(
      title: "Establishing baseline",
      subtitle: "Initial activity pattern captured.",
      type: InsightType.neutral,
      icon: Icons.flag_rounded,
    );
  }
}
