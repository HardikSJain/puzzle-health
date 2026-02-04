import 'package:health/health.dart';
import 'package:logger/logger.dart';

/// Service for interacting with device health data (Apple Health / Google Fit)
class HealthService {
  static final _logger = Logger();
  static final _health = Health();

  /// Request permission to access health data
  static Future<bool> requestPermission() async {
    try {
      final types = [
        HealthDataType.STEPS,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.ACTIVITY_INTENSITY,
      ];

      final permissions = types.map((type) => HealthDataAccess.READ).toList();

      // Check if we already have permissions
      bool? hasPermissions = await _health.hasPermissions(
        types,
        permissions: permissions,
      );

      if (hasPermissions == true) {
        _logger.i('Health permissions already granted');
        return true;
      }

      // Request permissions
      bool authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (authorized) {
        _logger.i('Health permissions granted');
      } else {
        _logger.w('Health permissions denied');
      }

      return authorized;
    } catch (e) {
      _logger.e('Error requesting health permissions: $e');
      return false;
    }
  }

  /// Fetch daily step data for the last N days
  static Future<List<StepData>> fetchStepData({int days = 30}) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      // Fetch step data
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startDate,
        endTime: now,
      );

      // Group by day
      final Map<String, int> dailySteps = {};

      for (var point in healthData) {
        if (point.type == HealthDataType.STEPS) {
          final dateKey = _formatDateKey(point.dateFrom);
          final steps = (point.value as num).toInt();
          dailySteps[dateKey] = (dailySteps[dateKey] ?? 0) + steps;
        }
      }

      // Convert to list of StepData
      final List<StepData> stepDataList = [];
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: days - i - 1));
        final dateKey = _formatDateKey(date);
        final steps = dailySteps[dateKey] ?? 0;
        stepDataList.add(StepData(date: date, steps: steps));
      }

      _logger.i('Fetched ${stepDataList.length} days of step data');
      return stepDataList;
    } catch (e) {
      _logger.e('Error fetching step data: $e');
      return [];
    }
  }

  /// Fetch total steps in the last N days
  static Future<int> fetchTotalSteps({int days = 30}) async {
    final stepData = await fetchStepData(days: days);
    return stepData.fold<int>(0, (sum, data) => sum + data.steps);
  }

  /// Fetch average daily steps in the last N days
  static Future<double> fetchAverageSteps({int days = 30}) async {
    final stepData = await fetchStepData(days: days);
    if (stepData.isEmpty) return 0;
    final total = stepData.fold<int>(0, (sum, data) => sum + data.steps);
    return total / stepData.length;
  }

  /// Format date as YYYY-MM-DD for grouping
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if health data is available on this device
  static Future<bool> isHealthDataAvailable() async {
    try {
      // Try to request permissions to check availability
      return await requestPermission();
    } catch (e) {
      _logger.e('Health data not available: $e');
      return false;
    }
  }
}

/// Model for daily step data
class StepData {
  final DateTime date;
  final int steps;

  const StepData({required this.date, required this.steps});

  bool get isWeekday => date.weekday <= 5;
  bool get isWeekend => date.weekday > 5;

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'steps': steps};
  }

  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      date: DateTime.parse(json['date'] as String),
      steps: json['steps'] as int,
    );
  }
}
