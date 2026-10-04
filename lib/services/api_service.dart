import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensor_data.dart';
import '../models/system_status.dart';

class ApiService {
  static const String defaultUrl = 'https://smart-lamp-dashboardv2.onrender.com';
  static const String prefKey = 'lumitrack_backend_url';

  String _baseUrl = defaultUrl;
  String get baseUrl => _baseUrl;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(prefKey);
      if (saved != null && saved.trim().isNotEmpty) {
        _baseUrl = _normalizeUrl(saved.trim());
      }
    } catch (_) {}
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = _normalizeUrl(url);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefKey, _baseUrl);
    } catch (_) {}
  }

  String _normalizeUrl(String url) {
    var trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'http://$trimmed';
    }
    return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }

  // Get Latest Sensor State
  Future<SensorData?> getLatestSensors() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/sensors/latest'))
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          return SensorData.fromJson(json['data']);
        }
      }
    } catch (e) {
      // Return null when server is unreachable
    }
    return null;
  }

  // Get Historical Data
  Future<List<SensorData>> getSensorHistory({int limit = 30}) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/sensors/history?limit=$limit'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] is List) {
          final list = (json['data'] as List)
              .map((item) => SensorData.fromJson(item as Map<String, dynamic>))
              .toList();
          return list;
        }
      }
    } catch (_) {}
    return [];
  }

  // Get System & Mongo Status
  Future<SystemStatus?> getSystemStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/status'))
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return SystemStatus.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  // Control Lamp Status ('ON' or 'OFF')
  Future<bool> setLampStatus(bool turnOn) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/control/lamp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'status': turnOn ? 'ON' : 'OFF'}),
          )
          .timeout(const Duration(seconds: 6));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Control Mode ('AUTO', 'FORCE ON', 'FORCE OFF')
  Future<bool> setMode(String mode) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/control/mode'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'mode': mode}),
          )
          .timeout(const Duration(seconds: 6));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Control Brightness (10 to 100)
  Future<bool> setBrightness(int brightness) async {
    try {
      final clamped = brightness.clamp(10, 100);
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/control/brightness'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'brightness': clamped}),
          )
          .timeout(const Duration(seconds: 6));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Test URL reachability
  Future<bool> testConnection(String candidateUrl) async {
    try {
      final normalized = _normalizeUrl(candidateUrl);
      final response = await http
          .get(Uri.parse('$normalized/api/status'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
