class SensorData {
  final double? temperature;
  final double? humidity;
  final bool peopleDetected;
  final int? lightRaw;
  final int? lightLevel;
  final String lightStatus;
  final String lampStatus;
  final String mode;
  final int brightness;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final String? source;

  SensorData({
    this.temperature,
    this.humidity,
    this.peopleDetected = false,
    this.lightRaw,
    this.lightLevel,
    this.lightStatus = 'DARK (มืด)',
    this.lampStatus = 'OFF',
    this.mode = 'AUTO',
    this.brightness = 100,
    this.updatedAt,
    this.createdAt,
    this.source,
  });

  bool get isLampOn => lampStatus.toUpperCase() == 'ON';

  factory SensorData.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString());
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val)?.toLocal();
      return null;
    }

    return SensorData(
      temperature: parseDouble(json['temperature']),
      humidity: parseDouble(json['humidity']),
      peopleDetected: json['peopleDetected'] == true ||
          json['peopleDetected'] == 1 ||
          json['peopleDetected'] == 'true',
      lightRaw: parseInt(json['lightRaw']),
      lightLevel: parseInt(json['lightLevel']),
      lightStatus: json['lightStatus']?.toString() ??
          ((parseInt(json['lightLevel']) ?? 0) < 30 ? 'DARK (มืด)' : 'BRIGHT (สว่าง)'),
      lampStatus: (json['lampStatus']?.toString() ?? 'OFF').toUpperCase(),
      mode: (json['mode']?.toString() ?? 'AUTO').toUpperCase(),
      brightness: parseInt(json['brightness']) ?? 100,
      updatedAt: parseDate(json['updatedAt']),
      createdAt: parseDate(json['createdAt']),
      source: json['source']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'peopleDetected': peopleDetected,
      'lightRaw': lightRaw,
      'lightLevel': lightLevel,
      'lightStatus': lightStatus,
      'lampStatus': lampStatus,
      'mode': mode,
      'brightness': brightness,
      'updatedAt': updatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'source': source,
    };
  }

  SensorData copyWith({
    double? temperature,
    double? humidity,
    bool? peopleDetected,
    int? lightRaw,
    int? lightLevel,
    String? lightStatus,
    String? lampStatus,
    String? mode,
    int? brightness,
    DateTime? updatedAt,
    DateTime? createdAt,
    String? source,
  }) {
    return SensorData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      peopleDetected: peopleDetected ?? this.peopleDetected,
      lightRaw: lightRaw ?? this.lightRaw,
      lightLevel: lightLevel ?? this.lightLevel,
      lightStatus: lightStatus ?? this.lightStatus,
      lampStatus: lampStatus ?? this.lampStatus,
      mode: mode ?? this.mode,
      brightness: brightness ?? this.brightness,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
    );
  }
}
