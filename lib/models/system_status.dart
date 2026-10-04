class SystemStatus {
  final bool success;
  final String server;
  final bool mongoConnected;
  final String mongoDatabase;
  final double uptime;
  final DateTime? latestUpdate;

  SystemStatus({
    this.success = false,
    this.server = 'unknown',
    this.mongoConnected = false,
    this.mongoDatabase = 'smart_lamp',
    this.uptime = 0,
    this.latestUpdate,
  });

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      success: json['success'] == true,
      server: json['server']?.toString() ?? 'unknown',
      mongoConnected: json['mongoConnected'] == true,
      mongoDatabase: json['mongoDatabase']?.toString() ?? 'smart_lamp',
      uptime: (json['uptime'] is num) ? (json['uptime'] as num).toDouble() : 0.0,
      latestUpdate: json['latestUpdate'] != null
          ? DateTime.tryParse(json['latestUpdate'].toString())?.toLocal()
          : null,
    );
  }
}
