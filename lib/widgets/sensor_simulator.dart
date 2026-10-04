import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class SensorSimulator extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback onDataSent;

  const SensorSimulator({
    super.key,
    required this.apiService,
    required this.onDataSent,
  });

  @override
  State<SensorSimulator> createState() => _SensorSimulatorState();
}

class _SensorSimulatorState extends State<SensorSimulator> {
  double _temp = 24.2;
  double _hum = 70.2;
  int _light = 21;
  bool _people = true;
  bool _isSending = false;

  void _resetDefaults() {
    setState(() {
      _temp = 24.2;
      _hum = 70.2;
      _light = 21;
      _people = true;
    });
    _sendTelemetry();
  }

  Future<void> _sendTelemetry() async {
    setState(() => _isSending = true);
    try {
      final rawAdc = (4095 - (_light / 100.0 * 4095)).round();
      final url = '${widget.apiService.baseUrl}/api/sensors/data';
      await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'temperature': _temp,
          'humidity': _hum,
          'peopleDetected': _people,
          'lightRaw': rawAdc,
          'lightLevel': _light,
          'deviceId': 'ESP32-SmartClassRoom-App',
          'source': 'Live App Bench Simulator',
        }),
      );
      widget.onDataSent();
    } catch (_) {}
    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.amber950.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.amber600.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.memory_rounded, color: AppColors.amber400, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เครื่องมือจำลองเซ็นเซอร์สด',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warmText,
                        ),
                      ),
                      Text(
                        'Live Sensor Control Bench',
                        style: TextStyle(fontSize: 10, color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: _resetDefaults,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber950.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.amber700.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.restart_alt_rounded, size: 13, color: AppColors.amber400),
                      SizedBox(width: 4),
                      Text(
                        'คืนค่าเป๊ะ',
                        style: TextStyle(fontSize: 10, color: AppColors.amber400, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4 Simulators Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isWide ? 1.4 : 1.25,
                children: [
                  _buildTempSlider(),
                  _buildHumSlider(),
                  _buildLightSlider(),
                  _buildPeopleToggle(),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Send button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _sendTelemetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber500,
                foregroundColor: const Color(0xFF141210),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: _isSending
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF141210)),
                    )
                  : const Icon(Icons.send_rounded, size: 16),
              label: const Text(
                'ส่งข้อมูลจำลองไปยังเซิร์ฟเวอร์ (Push Live Data)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempSlider() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.innerCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.innerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('อุณหภูมิ', style: TextStyle(fontSize: 11, color: AppColors.mutedText)),
              Text(
                '${_temp.toStringAsFixed(1)}°C',
                style: TextStyle(fontSize: 11.5, color: AppColors.amber400, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.amber500,
              inactiveTrackColor: AppColors.innerBorder,
              thumbColor: AppColors.amber400,
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _temp,
              min: 15.0,
              max: 42.0,
              onChanged: (val) => setState(() => _temp = val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('15°C', style: TextStyle(fontSize: 8.5, color: AppColors.dimText, fontFamily: 'monospace')),
              Text('42°C', style: TextStyle(fontSize: 8.5, color: AppColors.dimText, fontFamily: 'monospace')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHumSlider() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.innerCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.innerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ความชื้น', style: TextStyle(fontSize: 11, color: AppColors.mutedText)),
              Text(
                '${_hum.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 11.5, color: AppColors.amber200, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.cyan,
              inactiveTrackColor: AppColors.innerBorder,
              thumbColor: AppColors.cyan,
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _hum,
              min: 20.0,
              max: 95.0,
              onChanged: (val) => setState(() => _hum = val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('20%', style: TextStyle(fontSize: 8.5, color: AppColors.dimText, fontFamily: 'monospace')),
              Text('95%', style: TextStyle(fontSize: 8.5, color: AppColors.dimText, fontFamily: 'monospace')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLightSlider() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.innerCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.innerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ระดับแสง', style: TextStyle(fontSize: 11, color: AppColors.mutedText)),
              Text(
                '$_light%',
                style: TextStyle(fontSize: 11.5, color: AppColors.orange, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.orange,
              inactiveTrackColor: AppColors.innerBorder,
              thumbColor: AppColors.orange,
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _light.toDouble(),
              min: 0,
              max: 100,
              onChanged: (val) => setState(() => _light = val.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: TextStyle(fontSize: 8.5, color: AppColors.dimText, fontFamily: 'monospace')),
              Text('100%', style: TextStyle(fontSize: 8.5, color: AppColors.dimText, fontFamily: 'monospace')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleToggle() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.innerCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.innerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('ตรวจจับคน', style: TextStyle(fontSize: 11, color: AppColors.mutedText)),
          Center(
            child: Text(
              _people ? 'DETECTED' : 'CLEAR',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _people ? AppColors.emeraldLight : AppColors.dimText,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Center(
            child: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _people,
                activeThumbColor: AppColors.emeraldLight,
                activeTrackColor: AppColors.emerald950,
                inactiveThumbColor: AppColors.dimText,
                inactiveTrackColor: AppColors.innerBorder,
                onChanged: (val) => setState(() => _people = val),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
