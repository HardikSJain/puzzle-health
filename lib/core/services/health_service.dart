import 'dart:io';
import 'package:health/health.dart';
import 'package:logger/logger.dart';

/// Service for interacting with device health data (Apple Health / Health Connect)
/// Uses the Health() pattern from the health package.
class HealthService {
  static final Logger _logger = Logger();
  static final Health _health = Health();
  static bool _configured = false;

  // ============================================================
  // HEALTH DATA TYPES
  // ============================================================

  /// Activity data types
  static List<HealthDataType> get activityTypes => [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.WORKOUT,
  ];

  /// Vitals data types
  static List<HealthDataType> get vitalsTypes => [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.BLOOD_GLUCOSE,
  ];

  /// Body measurement data types
  static List<HealthDataType> get bodyTypes => [
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.LEAN_BODY_MASS,
  ];

  /// Sleep data types
  static List<HealthDataType> get sleepTypes => [
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
  ];

  /// Nutrition data types
  static List<HealthDataType> get nutritionTypes => [
    HealthDataType.WATER,
    HealthDataType.NUTRITION,
  ];

  /// All supported health data types for reading
  static List<HealthDataType> get allTypes => [
    ...activityTypes,
    ...vitalsTypes,
    ...bodyTypes,
    ...sleepTypes,
    ...nutritionTypes,
  ];

  // ============================================================
  // CONFIGURATION
  // ============================================================

  /// Configure health plugin (must call before any operation)
  static Future<void> configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
    _logger.i('Health plugin configured');
  }

  /// Check if Health Connect is available (Android only)
  static Future<HealthConnectSdkStatus?> getHealthConnectSdkStatus() async {
    if (!Platform.isAndroid) return null;
    await configure();
    return await _health.getHealthConnectSdkStatus();
  }

  /// Check if Health Connect is available and ready
  static Future<bool> isHealthConnectAvailable() async {
    if (!Platform.isAndroid) return true; // iOS uses HealthKit
    final status = await getHealthConnectSdkStatus();
    return status == HealthConnectSdkStatus.sdkAvailable;
  }

  /// Install or open Health Connect (Android only)
  static Future<void> installHealthConnect() async {
    if (!Platform.isAndroid) return;
    await configure();
    await _health.installHealthConnect();
  }

  // ============================================================
  // PERMISSIONS
  // ============================================================

  /// Request authorization for all health types
  static Future<bool> requestAllPermissions() async {
    await configure();
    try {
      final result = await _health.requestAuthorization(allTypes);
      _logger.i('Requested all permissions: $result');
      return result;
    } catch (e) {
      _logger.e('Error requesting all permissions: $e');
      return false;
    }
  }

  /// Request authorization for specific health types
  static Future<bool> requestPermissions(List<HealthDataType> types) async {
    await configure();
    try {
      final result = await _health.requestAuthorization(types);
      _logger.i('Requested permissions for ${types.length} types: $result');
      return result;
    } catch (e) {
      _logger.e('Error requesting permissions: $e');
      return false;
    }
  }

  /// Request authorization for activity types only
  static Future<bool> requestActivityPermissions() async {
    return await requestPermissions(activityTypes);
  }

  /// Request authorization for vitals types only
  static Future<bool> requestVitalsPermissions() async {
    return await requestPermissions(vitalsTypes);
  }

  /// Request authorization for body types only
  static Future<bool> requestBodyPermissions() async {
    return await requestPermissions(bodyTypes);
  }

  /// Request authorization for sleep types only
  static Future<bool> requestSleepPermissions() async {
    return await requestPermissions(sleepTypes);
  }

  /// Request authorization for nutrition types only
  static Future<bool> requestNutritionPermissions() async {
    return await requestPermissions(nutritionTypes);
  }

  /// Check if we have permissions for specific types
  static Future<bool> hasPermissions(List<HealthDataType> types) async {
    await configure();
    try {
      final result = await _health.hasPermissions(types);
      return result ?? false;
    } catch (e) {
      _logger.e('Error checking permissions: $e');
      return false;
    }
  }

  // ============================================================
  // DATA FETCHING
  // ============================================================

  /// Fetch all health data for given time range
  static Future<List<HealthDataPoint>> fetchAllData({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await configure();
    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: allTypes,
      );
      _logger.i('Fetched ${data.length} health data points');
      return data;
    } catch (e) {
      _logger.e('Error fetching all health data: $e');
      return [];
    }
  }

  /// Fetch specific types of health data
  static Future<List<HealthDataPoint>> fetchData({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await configure();
    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: types,
      );
      _logger.i('Fetched ${data.length} data points for ${types.length} types');
      return data;
    } catch (e) {
      _logger.e('Error fetching health data: $e');
      return [];
    }
  }

  /// Fetch activity data for given time range
  static Future<List<HealthDataPoint>> fetchActivityData({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    return await fetchData(
      types: activityTypes,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Fetch vitals data for given time range
  static Future<List<HealthDataPoint>> fetchVitalsData({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    return await fetchData(
      types: vitalsTypes,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Fetch body measurement data for given time range
  static Future<List<HealthDataPoint>> fetchBodyData({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    return await fetchData(
      types: bodyTypes,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Fetch sleep data for given time range
  static Future<List<HealthDataPoint>> fetchSleepData({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    return await fetchData(
      types: sleepTypes,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Fetch nutrition data for given time range
  static Future<List<HealthDataPoint>> fetchNutritionData({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    return await fetchData(
      types: nutritionTypes,
      startTime: startTime,
      endTime: endTime,
    );
  }

  // ============================================================
  // CONVENIENCE METHODS
  // ============================================================

  /// Get total steps in interval (convenience method)
  static Future<int?> getTotalSteps({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await configure();
    try {
      final steps = await _health.getTotalStepsInInterval(startTime, endTime);
      _logger.i('Total steps: $steps');
      return steps;
    } catch (e) {
      _logger.e('Error fetching total steps: $e');
      return null;
    }
  }

  /// Fetch health data for the last N days
  static Future<List<HealthDataPoint>> fetchLastNDays({
    int days = 30,
    List<HealthDataType>? types,
  }) async {
    final now = DateTime.now();
    final startTime = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days));
    final endTime = now;

    if (types != null) {
      return await fetchData(
        types: types,
        startTime: startTime,
        endTime: endTime,
      );
    }
    return await fetchAllData(startTime: startTime, endTime: endTime);
  }

  /// Fetch today's health data
  static Future<List<HealthDataPoint>> fetchTodayData({
    List<HealthDataType>? types,
  }) async {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day);
    final endTime = now;

    if (types != null) {
      return await fetchData(
        types: types,
        startTime: startTime,
        endTime: endTime,
      );
    }
    return await fetchAllData(startTime: startTime, endTime: endTime);
  }

  /// Remove duplicate data points
  static List<HealthDataPoint> removeDuplicates(List<HealthDataPoint> data) {
    return _health.removeDuplicates(data);
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Filter data points by type
  static List<HealthDataPoint> filterByType(
    List<HealthDataPoint> data,
    HealthDataType type,
  ) {
    return data.where((point) => point.type == type).toList();
  }

  /// Filter data points by multiple types
  static List<HealthDataPoint> filterByTypes(
    List<HealthDataPoint> data,
    List<HealthDataType> types,
  ) {
    return data.where((point) => types.contains(point.type)).toList();
  }

  /// Get numeric value from health data point
  static double? getNumericValue(HealthDataPoint point) {
    final value = point.value;
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return null;
  }

  /// Group data points by date (YYYY-MM-DD)
  static Map<String, List<HealthDataPoint>> groupByDate(
    List<HealthDataPoint> data,
  ) {
    final Map<String, List<HealthDataPoint>> grouped = {};
    for (final point in data) {
      final dateKey = _formatDateKey(point.dateFrom);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(point);
    }
    return grouped;
  }

  /// Format date as YYYY-MM-DD
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
