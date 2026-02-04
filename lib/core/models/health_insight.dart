import 'package:flutter/material.dart';

/// Type of insight - affects visual presentation and tone
enum InsightType {
  /// Honest, direct observation (might be negative)
  honest,

  /// Neutral observation, neither good nor bad
  neutral,

  /// Positive reinforcement
  positive,

  /// Curious/interesting pattern observation
  curious,

  /// Data quality or availability insight
  dataQuality,
}

/// Category of health insight
enum InsightCategory {
  steps,
  sleep,
  heartRate,
  weight,
  activity,
  pattern,
  dataQuality,
}

/// A single health insight to display to the user
class HealthInsight {
  /// Main stat or observation (e.g., "3,241 steps/day")
  final String title;

  /// Supporting text with context (e.g., "That's low. But we're here to help.")
  final String subtitle;

  /// Type affects visual styling
  final InsightType type;

  /// Category for grouping/filtering
  final InsightCategory category;

  /// Optional icon to display
  final IconData? icon;

  /// Optional numeric value for animations
  final double? numericValue;

  /// Optional unit for the numeric value
  final String? unit;

  /// Optional additional context or data
  final Map<String, dynamic>? metadata;

  const HealthInsight({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.category,
    this.icon,
    this.numericValue,
    this.unit,
    this.metadata,
  });

  /// Create a steps insight
  factory HealthInsight.steps({
    required int avgSteps,
    required String subtitle,
    required InsightType type,
  }) {
    return HealthInsight(
      title: '${_formatNumber(avgSteps)} steps/day',
      subtitle: subtitle,
      type: type,
      category: InsightCategory.steps,
      icon: Icons.directions_walk_rounded,
      numericValue: avgSteps.toDouble(),
      unit: 'steps',
    );
  }

  /// Create a sleep insight
  factory HealthInsight.sleep({
    required double avgHours,
    required String subtitle,
    required InsightType type,
  }) {
    return HealthInsight(
      title: '${avgHours.toStringAsFixed(1)} hours sleep',
      subtitle: subtitle,
      type: type,
      category: InsightCategory.sleep,
      icon: Icons.bedtime_rounded,
      numericValue: avgHours,
      unit: 'hours',
    );
  }

  /// Create a heart rate insight
  factory HealthInsight.heartRate({
    required int avgBpm,
    required String subtitle,
    required InsightType type,
  }) {
    return HealthInsight(
      title: '$avgBpm bpm average',
      subtitle: subtitle,
      type: type,
      category: InsightCategory.heartRate,
      icon: Icons.favorite_rounded,
      numericValue: avgBpm.toDouble(),
      unit: 'bpm',
    );
  }

  /// Create a weight insight
  factory HealthInsight.weight({
    required double weightKg,
    required String subtitle,
    required InsightType type,
  }) {
    return HealthInsight(
      title: '${weightKg.toStringAsFixed(1)} kg',
      subtitle: subtitle,
      type: type,
      category: InsightCategory.weight,
      icon: Icons.monitor_weight_rounded,
      numericValue: weightKg,
      unit: 'kg',
    );
  }

  /// Create a pattern insight
  factory HealthInsight.pattern({
    required String title,
    required String subtitle,
    InsightType type = InsightType.curious,
    IconData? icon,
  }) {
    return HealthInsight(
      title: title,
      subtitle: subtitle,
      type: type,
      category: InsightCategory.pattern,
      icon: icon ?? Icons.insights_rounded,
    );
  }

  /// Create a data quality insight
  factory HealthInsight.dataQuality({
    required String title,
    required String subtitle,
    int? dataPoints,
    int? daysAnalyzed,
  }) {
    return HealthInsight(
      title: title,
      subtitle: subtitle,
      type: InsightType.dataQuality,
      category: InsightCategory.dataQuality,
      icon: Icons.analytics_rounded,
      metadata: {
        if (dataPoints != null) 'dataPoints': dataPoints,
        if (daysAnalyzed != null) 'daysAnalyzed': daysAnalyzed,
      },
    );
  }

  /// Format large numbers with commas
  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  String toString() {
    return 'HealthInsight(title: $title, type: $type, category: $category)';
  }
}
