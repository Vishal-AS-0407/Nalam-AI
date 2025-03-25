import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  final Health _health = Health();
  static final HealthService _instance = HealthService._internal();

  factory HealthService() {
    return _instance;
  }

  HealthService._internal();

  final List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_IN_BED
  ];

  Future<bool> requestPermissions() async {
    final permissions = [
      Permission.activityRecognition,
      Permission.location,
      Permission.sensors,
    ];

    bool allGranted = true;
    for (var permission in permissions) {
      final status = await permission.request();
      if (!status.isGranted) {
        allGranted = false;
      }
    }

    return allGranted;
  }

  Future<bool> requestHealthAuthorization() async {
    try {
      return await _health.requestAuthorization(_types);
    } catch (e) {
      print("Error requesting health authorization: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchLatestHealthData() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      Map<String, dynamic> healthData = {
        'heartRate': await _getLatestMeasurement(HealthDataType.HEART_RATE),
        'bloodPressure': await _getBloodPressure(),
        'steps': await _getAggregatedData(HealthDataType.STEPS, midnight, now),
        'distance': await _getAggregatedData(
            HealthDataType.DISTANCE_WALKING_RUNNING, midnight, now),
        'calories': await _getAggregatedData(
            HealthDataType.ACTIVE_ENERGY_BURNED, midnight, now),
        'sleep': await _getSleepData(midnight, now),
      };
      return healthData;
    } catch (e) {
      print("Error fetching health data: $e");
      return {};
    }
  }

  Future<Map<String, List<HealthDataPoint>>> fetchHistoricalData(
      DateTime startDate) async {
    final now = DateTime.now();
    Map<String, List<HealthDataPoint>> historicalData = {};

    try {
      for (HealthDataType type in _types) {
        List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
          startTime: startDate,
          endTime: now,
          types: [type],
        );
        historicalData[type.name] = data;
      }
      return historicalData;
    } catch (e) {
      print("Error fetching historical data: $e");
      return {};
    }
  }

  Future<double?> _getLatestMeasurement(HealthDataType type) async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(minutes: 30));

      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: now,
        types: [type],
      );

      if (data.isNotEmpty && data.last.value is num) {
        return (data.last.value as num).toDouble();
      }

      return null;
    } catch (e) {
      print("Error getting latest measurement for $type: $e");
      return null;
    }
  }

  Future<Map<String, double>> _getBloodPressure() async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(minutes: 30));

      double? systolic =
          await _getLatestMeasurement(HealthDataType.BLOOD_PRESSURE_SYSTOLIC);
      double? diastolic =
          await _getLatestMeasurement(HealthDataType.BLOOD_PRESSURE_DIASTOLIC);

      return {
        'systolic': systolic ?? 0,
        'diastolic': diastolic ?? 0,
      };
    } catch (e) {
      print("Error getting blood pressure: $e");
      return {'systolic': 0, 'diastolic': 0};
    }
  }

  Future<double> _getAggregatedData(
      HealthDataType type, DateTime start, DateTime end) async {
    try {
      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [type],
      );

      if (data.isEmpty) return 0.0; // Return 0 if no data

      double sum = 0.0;
      for (var point in data) {
        if (point.value is num) {
          sum += (point.value as num).toDouble(); // Ensure numeric type
        } else {
          print("Invalid value for ${point.type}: ${point.value}");
        }
      }

      return sum;
    } catch (e) {
      print("Error getting aggregated data for $type: $e");
      return 0.0;
    }
  }

  Future<Map<String, double>> _getSleepData(
      DateTime start, DateTime end) async {
    try {
      double asleepTime =
          await _getAggregatedData(HealthDataType.SLEEP_ASLEEP, start, end);
      double awakeTime =
          await _getAggregatedData(HealthDataType.SLEEP_AWAKE, start, end);
      double inBedTime =
          await _getAggregatedData(HealthDataType.SLEEP_IN_BED, start, end);

      return {
        'asleep': asleepTime / 3600, // Convert to hours
        'awake': awakeTime / 3600,
        'inBed': inBedTime / 3600,
      };
    } catch (e) {
      print("Error getting sleep data: $e");
      return {'asleep': 0, 'awake': 0, 'inBed': 0};
    }
  }
}
