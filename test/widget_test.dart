import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_lamp_dashboard_app/models/sensor_data.dart';
import 'package:smart_lamp_dashboard_app/widgets/hero_status_bar.dart';
import 'package:smart_lamp_dashboard_app/widgets/lamp_controller.dart';
import 'package:smart_lamp_dashboard_app/widgets/sensor_metrics.dart';
import 'package:smart_lamp_dashboard_app/widgets/telemetry_chart.dart';
import 'package:smart_lamp_dashboard_app/widgets/dashboard_extras.dart';
import 'package:smart_lamp_dashboard_app/widgets/theme_settings_page.dart';
import 'package:smart_lamp_dashboard_app/widgets/welcome_screen.dart';

void main() {
  testWidgets('HeroStatusBar renders 4 status metrics', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final testData = SensorData(
      mode: 'FORCE ON',
      lampStatus: 'ON',
      lightLevel: 21,
      peopleDetected: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HeroStatusBar(data: testData)),
      ),
    );

    expect(find.text('FORCE ON'), findsOneWidget);
    expect(find.text('ON (เปิด)'), findsOneWidget);
    expect(find.text('DARK (มืด)'), findsOneWidget);
    expect(find.text('YES (มีคน)'), findsOneWidget);
  });

  testWidgets('LampController renders lamp visualizer & controls', (
    WidgetTester tester,
  ) async {
    final testData = SensorData(
      lampStatus: 'ON',
      mode: 'AUTO',
      brightness: 100,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LampController(
              data: testData,
              onToggleLamp: (_) {},
              onSelectMode: (_) {},
              onChangeBrightness: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('แผงควบคุมไฟอัจฉริยะ'), findsOneWidget);
    expect(find.text('AUTO'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('หลอดไฟเปิดทำงาน (Warm White 2700K)'), findsOneWidget);
  });

  testWidgets('SensorMetrics renders Climate, Light, and Proximity', (
    WidgetTester tester,
  ) async {
    final testData = SensorData(
      temperature: 24.2,
      humidity: 70.2,
      lightLevel: 21,
      lightRaw: 3149,
      peopleDetected: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: SensorMetrics(data: testData)),
        ),
      ),
    );

    expect(find.text('24.2'), findsOneWidget);
    expect(find.text('70.2'), findsOneWidget);
    expect(find.text('21'), findsOneWidget);
    expect(find.text('3149'), findsOneWidget);
    expect(find.text('DETECTED'), findsOneWidget);
  });

  testWidgets('DashboardInsights shows configured alerts and recommendations', (
    WidgetTester tester,
  ) async {
    final testData = SensorData(
      temperature: 34,
      peopleDetected: false,
      lampStatus: 'ON',
      mode: 'AUTO',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DashboardInsights(
              data: testData,
              history: const [],
              isOnline: false,
              offlineDuration: const Duration(minutes: 8),
              temperatureLimit: 30,
              alertOnEmptyRoom: true,
              alertOnOffline: true,
              onConfigureAlerts: _noop,
            ),
          ),
        ),
      ),
    );

    expect(find.text('อุณหภูมิสูงกว่าค่าที่ตั้งไว้'), findsOneWidget);
    expect(find.text('ห้องว่างแต่ไฟยังเปิดอยู่'), findsOneWidget);
    expect(find.text('อุปกรณ์ออฟไลน์'), findsOneWidget);
    expect(find.text('คำแนะนำ'), findsOneWidget);
  });

  testWidgets('TelemetryChart provides selectable time ranges and statistics', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final history = [
      SensorData(
        temperature: 25,
        humidity: 50,
        lightLevel: 35,
        updatedAt: now.subtract(const Duration(minutes: 10)),
      ),
      SensorData(temperature: 27, humidity: 60, lightLevel: 45, updatedAt: now),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: TelemetryChart(history: history)),
        ),
      ),
    );

    expect(find.text('1 ชม.'), findsOneWidget);
    expect(find.text('24 ชม.'), findsOneWidget);
    expect(find.text('7 วัน'), findsOneWidget);
    expect(find.text('ทั้งหมด'), findsOneWidget);

    await tester.tap(find.text('24 ชม.'));
    await tester.pump();
    expect(find.text('24 ชม.'), findsOneWidget);
  });

  testWidgets('EventHistory displays persisted control event details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventHistory(
            events: [
              {
                'message': 'สั่งเปิดไฟด้วยตนเอง',
                'time': DateTime(2026, 10, 4, 12).toIso8601String(),
              },
            ],
            onClear: _noop,
          ),
        ),
      ),
    );

    expect(find.text('ประวัติการทำงาน'), findsOneWidget);
    expect(find.text('สั่งเปิดไฟด้วยตนเอง'), findsOneWidget);
    expect(find.text('ล้างประวัติ'), findsOneWidget);
  });

  testWidgets('WelcomeScreen opens the dashboard from its start button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(
          dashboard: const Scaffold(body: Text('dashboard-ready')),
          isLightTheme: true,
          onThemeChanged: (_) {},
        ),
      ),
    );

    expect(find.text('แสงที่พอดี\nเพื่อห้องเรียนที่ดีกว่า'), findsOneWidget);
    await tester.ensureVisible(find.text('เริ่มต้นการใช้งาน'));
    await tester.tap(find.text('เริ่มต้นการใช้งาน'));
    await tester.pumpAndSettle();
    expect(find.text('dashboard-ready'), findsOneWidget);
  });

  testWidgets('ThemeSettingsPage applies the selected dark theme', (
    WidgetTester tester,
  ) async {
    bool? appliedTheme;
    await tester.pumpWidget(
      MaterialApp(
        home: ThemeSettingsPage(
          isLightMode: true,
          onThemeChanged: (isLight) => appliedTheme = isLight,
        ),
      ),
    );

    await tester.tap(find.text('โทนมืดอบอุ่น'));
    await tester.pump();
    await tester.tap(find.text('ใช้ธีมนี้'));
    await tester.pumpAndSettle();
    expect(appliedTheme, isFalse);
  });
}

void _noop() {}
