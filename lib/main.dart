import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/sensor_data.dart';
import 'models/system_status.dart';
import 'services/api_service.dart';
import 'theme/app_colors.dart';
import 'widgets/hero_status_bar.dart';
import 'widgets/lamp_controller.dart';
import 'widgets/sensor_metrics.dart';
import 'widgets/serial_console.dart';
import 'widgets/telemetry_chart.dart';
import 'widgets/sensor_simulator.dart';
import 'widgets/settings_dialog.dart';
import 'widgets/dashboard_extras.dart';
import 'widgets/welcome_screen.dart';
import 'widgets/theme_settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  await apiService.init();

  runApp(SmartLampApp(apiService: apiService));
}

class SmartLampApp extends StatefulWidget {
  final ApiService apiService;

  const SmartLampApp({super.key, required this.apiService});

  @override
  State<SmartLampApp> createState() => _SmartLampAppState();
}

class _SmartLampAppState extends State<SmartLampApp> {
  static const _themePrefKey = 'lumitrack_light_theme';
  bool _isLightTheme = true;

  @override
  void initState() {
    super.initState();
    _restoreTheme();
  }

  Future<void> _restoreTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final lightTheme = prefs.getBool(_themePrefKey) ?? true;
    if (!mounted) return;
    setState(() {
      _isLightTheme = lightTheme;
      AppColors.lightMode = lightTheme;
    });
  }

  Future<void> _setTheme(bool lightTheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, lightTheme);
    if (!mounted) return;
    setState(() {
      _isLightTheme = lightTheme;
      AppColors.lightMode = lightTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Classroom | Smart Lamp Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _isLightTheme ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        primaryColor: AppColors.amber500,
        colorScheme: ColorScheme(
          brightness: _isLightTheme ? Brightness.light : Brightness.dark,
          primary: AppColors.amber500,
          secondary: AppColors.emerald,
          surface: AppColors.card,
          error: AppColors.red,
          onPrimary: const Color(0xFF34291F),
          onSecondary: AppColors.warmText,
          onSurface: AppColors.warmText,
          onError: Colors.white,
        ),
        fontFamily: 'sans-serif',
        useMaterial3: true,
      ),
      home: WelcomeScreen(
        dashboard: DashboardScreen(
          apiService: widget.apiService,
          isLightTheme: _isLightTheme,
          onThemeChanged: _setTheme,
        ),
        isLightTheme: _isLightTheme,
        onThemeChanged: _setTheme,
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final ApiService apiService;
  final bool isLightTheme;
  final ValueChanged<bool> onThemeChanged;

  const DashboardScreen({
    super.key,
    required this.apiService,
    required this.isLightTheme,
    required this.onThemeChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _eventsPrefKey = 'dashboard_control_events';
  static const _temperatureAlertPrefKey = 'dashboard_alert_temperature_limit';
  static const _emptyRoomAlertPrefKey = 'dashboard_alert_empty_room';
  static const _offlineAlertPrefKey = 'dashboard_alert_offline';

  SensorData _currentData = SensorData(
    temperature: 24.2,
    humidity: 70.2,
    lightLevel: 21,
    lightRaw: 3149,
    peopleDetected: true,
    lampStatus: 'ON',
    mode: 'FORCE ON',
    brightness: 100,
  );
  List<SensorData> _history = [];
  SystemStatus _systemStatus = SystemStatus();
  bool _isOnline = false;
  bool _isLoading = false;
  DateTime _lastSync = DateTime.now();
  double _temperatureAlertLimit = 30;
  bool _alertOnEmptyRoom = true;
  bool _alertOnOffline = true;
  List<Map<String, String>> _events = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _restoreDashboardSettings();
    _fetchFullData();
    // Poll every 2 seconds matching the website
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _pollLiveData();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchFullData() async {
    setState(() => _isLoading = true);
    await Future.wait([_pollLiveData(), _loadHistory(), _checkSystemStatus()]);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pollLiveData() async {
    final data = await widget.apiService.getLatestSensors();
    if (mounted) {
      if (data != null) {
        final previousData = _currentData;
        setState(() {
          _currentData = data;
          _isOnline = true;
          _lastSync = DateTime.now();
          if (_history.isEmpty || _history.first.updatedAt != data.updatedAt) {
            _history.insert(0, data);
            if (_history.length > 500) {
              _history.removeLast();
            }
          }
        });
        if (previousData.lampStatus != data.lampStatus ||
            previousData.mode != data.mode) {
          final changes = <String>[
            if (previousData.lampStatus != data.lampStatus)
              'ไฟ ${data.isLampOn ? 'เปิด' : 'ปิด'}',
            if (previousData.mode != data.mode) 'โหมด ${data.mode}',
          ];
          _recordEvent('สถานะจากอุปกรณ์: ${changes.join(' · ')}');
        }
      } else {
        setState(() => _isOnline = false);
      }
    }
  }

  Future<void> _loadHistory() async {
    final historyList = await widget.apiService.getSensorHistory(limit: 500);
    if (mounted && historyList.isNotEmpty) {
      setState(() {
        _history = historyList;
      });
    }
  }

  Future<void> _checkSystemStatus() async {
    final status = await widget.apiService.getSystemStatus();
    if (mounted && status != null) {
      setState(() {
        _systemStatus = status;
      });
    }
  }

  Future<void> _handleToggleLamp(bool turnOn) async {
    setState(() {
      _currentData = _currentData.copyWith(
        lampStatus: turnOn ? 'ON' : 'OFF',
        mode: turnOn ? 'FORCE ON' : 'FORCE OFF',
      );
    });

    final success = await widget.apiService.setLampStatus(turnOn);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ ไม่สามารถส่งคำสั่งสวิตช์ไฟได้'),
          backgroundColor: AppColors.red,
        ),
      );
      _pollLiveData();
    } else if (success) {
      await _recordEvent(turnOn ? 'สั่งเปิดไฟด้วยตนเอง' : 'สั่งปิดไฟด้วยตนเอง');
    }
  }

  Future<void> _handleSelectMode(String mode) async {
    setState(() {
      _currentData = _currentData.copyWith(
        mode: mode,
        lampStatus: mode == 'FORCE ON'
            ? 'ON'
            : (mode == 'FORCE OFF' ? 'OFF' : _currentData.lampStatus),
      );
    });

    final success = await widget.apiService.setMode(mode);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ ไม่สามารถเปลี่ยนโหมดได้'),
          backgroundColor: AppColors.red,
        ),
      );
      _pollLiveData();
    } else if (success) {
      await _recordEvent('เปลี่ยนโหมดเป็น $mode');
    }
  }

  Future<void> _handleChangeBrightness(int brightness) async {
    setState(() {
      _currentData = _currentData.copyWith(brightness: brightness);
    });

    final success = await widget.apiService.setBrightness(brightness);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ ไม่สามารถปรับความสว่างได้'),
          backgroundColor: AppColors.red,
        ),
      );
    } else if (success) {
      await _recordEvent('ปรับความสว่างเป็น $brightness%');
    }
  }

  Future<void> _restoreDashboardSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final rawEvents = prefs.getString(_eventsPrefKey);
    List<Map<String, String>> events = [];
    if (rawEvents != null) {
      final decoded = jsonDecode(rawEvents);
      if (decoded is List) {
        events = decoded
            .whereType<Map>()
            .map(
              (event) => event.map(
                (key, value) => MapEntry(key.toString(), value.toString()),
              ),
            )
            .where(
              (event) =>
                  event.containsKey('message') && event.containsKey('time'),
            )
            .toList();
      }
    }
    if (!mounted) return;
    setState(() {
      _temperatureAlertLimit =
          prefs.getDouble(_temperatureAlertPrefKey) ?? _temperatureAlertLimit;
      _alertOnEmptyRoom =
          prefs.getBool(_emptyRoomAlertPrefKey) ?? _alertOnEmptyRoom;
      _alertOnOffline = prefs.getBool(_offlineAlertPrefKey) ?? _alertOnOffline;
      _events = events;
    });
  }

  Future<void> _saveTemperatureAlertLimit(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_temperatureAlertPrefKey, value);
    if (mounted) setState(() => _temperatureAlertLimit = value);
  }

  Future<void> _saveEmptyRoomAlert(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emptyRoomAlertPrefKey, value);
    if (mounted) setState(() => _alertOnEmptyRoom = value);
  }

  Future<void> _saveOfflineAlert(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineAlertPrefKey, value);
    if (mounted) setState(() => _alertOnOffline = value);
  }

  Future<void> _recordEvent(String message) async {
    final event = <String, String>{
      'message': message,
      'time': DateTime.now().toIso8601String(),
    };
    final events = [event, ..._events].take(100).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_eventsPrefKey, jsonEncode(events));
    if (mounted) setState(() => _events = events);
  }

  Future<void> _clearEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsPrefKey);
    if (mounted) setState(() => _events = []);
  }

  Future<void> _applyScene(String name, String mode, int brightness) async {
    final modeSuccess = await widget.apiService.setMode(mode);
    if (!modeSuccess) {
      _showActionError('ไม่สามารถเปลี่ยนโหมดสำหรับฉาก "$name" ได้');
      return;
    }
    if (mounted) {
      setState(() {
        _currentData = _currentData.copyWith(
          mode: mode,
          lampStatus: mode == 'FORCE OFF'
              ? 'OFF'
              : (mode == 'FORCE ON' ? 'ON' : _currentData.lampStatus),
        );
      });
    }
    final brightnessSuccess = await widget.apiService.setBrightness(brightness);
    if (!brightnessSuccess) {
      _showActionError(
        'เปลี่ยนโหมดแล้ว แต่ปรับความสว่างสำหรับฉาก "$name" ไม่สำเร็จ',
      );
      _pollLiveData();
      return;
    }
    if (mounted) {
      setState(() {
        _currentData = _currentData.copyWith(brightness: brightness);
      });
    }
    await _recordEvent('ใช้ฉาก "$name" · $mode · ความสว่าง $brightness%');
  }

  void _showActionError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  void _openAlertSettings() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertRulesDialog(
        temperatureLimit: _temperatureAlertLimit,
        alertOnEmptyRoom: _alertOnEmptyRoom,
        alertOnOffline: _alertOnOffline,
        onSave: _saveTemperatureAlertLimit,
        onEmptyRoomChanged: _saveEmptyRoomAlert,
        onOfflineChanged: _saveOfflineAlert,
      ),
    );
  }

  void _openThemeSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThemeSettingsPage(
          isLightMode: widget.isLightTheme,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => WelcomeScreen(
          dashboard: DashboardScreen(
            apiService: widget.apiService,
            isLightTheme: widget.isLightTheme,
            onThemeChanged: widget.onThemeChanged,
          ),
          isLightTheme: widget.isLightTheme,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
      (_) => false,
    );
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        apiService: widget.apiService,
        onSaved: () {
          _fetchFullData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncTimeStr = DateFormat('HH:mm:ss').format(_lastSync);
    final isCompact = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark.withValues(alpha: 0.96),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: isCompact ? 16 : 24,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cardBorder.withValues(alpha: 0.15),
                  AppColors.amber700.withValues(alpha: 0.55),
                  AppColors.cardBorder.withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Tooltip(
              message: 'กลับไปหน้าแรก',
              child: InkWell(
                onTap: _goHome,
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.amber500, AppColors.amber700],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.amber500.withValues(alpha: 0.3),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.amber100,
                          size: 22,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: _isOnline ? AppColors.emerald : AppColors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.bgDark,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Smart Classroom',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isCompact ? 15 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warmText,
                          ),
                        ),
                      ),
                      if (!isCompact) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.amber950.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.amber600.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            'IoT v1.0',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.amber400,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!isCompact)
                    Text(
                      'ESP32 Node · 192.168.1.105  •  อัปเดต $syncTimeStr',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedText,
                        fontFamily: 'monospace',
                      ),
                    )
                  else
                    Text(
                      _isOnline
                          ? 'ระบบออนไลน์ · อัปเดต $syncTimeStr'
                          : 'กำลังเชื่อมต่ออุปกรณ์...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedText,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.home_outlined,
              color: AppColors.warmText,
              size: 20,
            ),
            tooltip: 'กลับไปหน้าแรก',
            onPressed: _goHome,
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 7 : 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _systemStatus.mongoConnected
                    ? AppColors.emerald950.withValues(alpha: 0.42)
                    : AppColors.amber950.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _systemStatus.mongoConnected
                      ? AppColors.emerald.withValues(alpha: 0.28)
                      : AppColors.amber700.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_done_rounded,
                    size: 13,
                    color: _systemStatus.mongoConnected
                        ? AppColors.emeraldLight
                        : AppColors.amber400,
                  ),
                  if (!isCompact) ...[
                    const SizedBox(width: 6),
                    Text(
                      _systemStatus.mongoConnected
                          ? 'MongoDB พร้อมใช้งาน'
                          : 'MongoDB รอเชื่อมต่อ',
                      style: TextStyle(
                        fontSize: 10,
                        color: _systemStatus.mongoConnected
                            ? AppColors.emeraldLight
                            : AppColors.amber300,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            icon: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.amber400,
                    ),
                  )
                : Icon(
                    Icons.refresh_rounded,
                    color: AppColors.warmText,
                    size: 20,
                  ),
            tooltip: 'รีเฟรชข้อมูล',
            onPressed: _isLoading ? null : _fetchFullData,
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded, color: AppColors.warmText, size: 20),
            tooltip: 'ตั้งค่าการเชื่อมต่อ',
            onPressed: _openSettings,
          ),
          IconButton(
            icon: Icon(
              widget.isLightTheme
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: AppColors.warmText,
              size: 20,
            ),
            tooltip: 'เปลี่ยนธีม',
            onPressed: _openThemeSettings,
          ),
          SizedBox(width: isCompact ? 2 : 12),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.95, -0.9),
            radius: 1.35,
            colors: [Color(0xFFFFF8EC), AppColors.bgDark],
          ),
        ),
        child: RefreshIndicator(
          color: AppColors.amber500,
          backgroundColor: AppColors.card,
          onRefresh: _fetchFullData,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1480),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 16 : 28,
                  vertical: isCompact ? 18 : 26,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDashboardIntro(isCompact, syncTimeStr),
                    const SizedBox(height: 20),
                    HeroStatusBar(data: _currentData),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 960) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 11,
                                child: LampController(
                                  data: _currentData,
                                  onToggleLamp: _handleToggleLamp,
                                  onSelectMode: _handleSelectMode,
                                  onChangeBrightness: _handleChangeBrightness,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                flex: 10,
                                child: SensorMetrics(data: _currentData),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                flex: 9,
                                child: SerialConsole(logs: _history),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            LampController(
                              data: _currentData,
                              onToggleLamp: _handleToggleLamp,
                              onSelectMode: _handleSelectMode,
                              onChangeBrightness: _handleChangeBrightness,
                            ),
                            const SizedBox(height: 18),
                            SensorMetrics(data: _currentData),
                            const SizedBox(height: 18),
                            SerialConsole(logs: _history),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    QuickScenes(onApply: _applyScene),
                    const SizedBox(height: 16),
                    DashboardInsights(
                      data: _currentData,
                      history: _history,
                      isOnline: _isOnline,
                      offlineDuration: DateTime.now().difference(_lastSync),
                      temperatureLimit: _temperatureAlertLimit,
                      alertOnEmptyRoom: _alertOnEmptyRoom,
                      alertOnOffline: _alertOnOffline,
                      onConfigureAlerts: _openAlertSettings,
                    ),
                    const SizedBox(height: 16),
                    EventHistory(events: _events, onClear: _clearEvents),
                    const SizedBox(height: 20),
                    TelemetryChart(history: _history.reversed.toList()),
                    const SizedBox(height: 20),
                    SensorSimulator(
                      apiService: widget.apiService,
                      onDataSent: _pollLiveData,
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Smart Classroom  •  LumiTrack IoT Ambience System v1.0',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Backend  ${widget.apiService.baseUrl}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: AppColors.dimText,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardIntro(bool isCompact, String syncTimeStr) {
    final offlineDuration = DateTime.now().difference(_lastSync);
    final offlineText = offlineDuration.inMinutes > 0
        ? 'ออฟไลน์ ${offlineDuration.inMinutes} นาที'
        : 'ออฟไลน์ ${offlineDuration.inSeconds} วินาที';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.amber400,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.amber400.withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ภาพรวมระบบ',
                    style: TextStyle(
                      fontSize: isCompact ? 21 : 25,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warmText,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 13),
                child: Text(
                  !_isOnline
                      ? offlineText
                      : (isCompact
                            ? 'สถานะและสภาพแวดล้อมภายในห้องเรียน'
                            : 'ติดตามการทำงานของโคมไฟและสภาพแวดล้อมภายในห้องเรียน'),
                  style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 10 : 13,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: _isOnline
                ? AppColors.emerald950.withValues(alpha: 0.46)
                : const Color(0xFF351917).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isOnline
                  ? AppColors.emerald.withValues(alpha: 0.32)
                  : AppColors.red.withValues(alpha: 0.32),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                size: 15,
                color: _isOnline ? AppColors.emeraldLight : AppColors.red,
              ),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: _isOnline ? AppColors.emeraldLight : AppColors.red,
                    ),
                  ),
                  Text(
                    _isOnline ? 'ซิงก์ล่าสุด $syncTimeStr' : offlineText,
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.mutedText,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
