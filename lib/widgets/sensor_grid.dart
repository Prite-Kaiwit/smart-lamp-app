import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

class SensorGrid extends StatelessWidget {
  final SensorData data;

  const SensorGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final childAspectRatio = constraints.maxWidth > 600 ? 1.35 : 0.88;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _buildTempCard(),
            _buildHumidityCard(),
            _buildLightCard(),
            _buildPeopleCard(),
          ],
        );
      },
    );
  }

  Widget _buildTempCard() {
    final temp = data.temperature;
    final tempVal = temp != null ? '${temp.toStringAsFixed(1)}°C' : '--';
    final progress = temp != null ? ((temp - 15) / (45 - 15)).clamp(0.0, 1.0) : 0.0;

    String statusText = 'รอข้อมูล';
    Color statusColor = const Color(0xFF94A3B8);
    if (temp != null) {
      if (temp < 24) {
        statusText = 'อากาศเย็น';
        statusColor = const Color(0xFF38BDF8);
      } else if (temp <= 32) {
        statusText = 'อุณหภูมิปกติ';
        statusColor = const Color(0xFF10B981);
      } else {
        statusText = 'อากาศร้อน';
        statusColor = const Color(0xFFEF4444);
      }
    }

    return _buildSensorCard(
      title: 'อุณหภูมิ (Temp)',
      value: tempVal,
      badgeText: statusText,
      badgeColor: statusColor,
      icon: Icons.thermostat_rounded,
      iconColor: const Color(0xFFF97316),
      progress: progress,
      progressBarColor: const Color(0xFFF97316),
      footerText: 'ช่วง 15°C - 45°C',
    );
  }

  Widget _buildHumidityCard() {
    final hum = data.humidity;
    final humVal = hum != null ? '${hum.toStringAsFixed(1)}%' : '--';
    final progress = hum != null ? (hum / 100.0).clamp(0.0, 1.0) : 0.0;

    String statusText = 'รอข้อมูล';
    Color statusColor = const Color(0xFF94A3B8);
    if (hum != null) {
      if (hum < 40) {
        statusText = 'อากาศแห้ง';
        statusColor = const Color(0xFFF59E0B);
      } else if (hum <= 70) {
        statusText = 'ความชื้นพอเหมาะ';
        statusColor = const Color(0xFF10B981);
      } else {
        statusText = 'ความชื้นสูง';
        statusColor = const Color(0xFF06B6D4);
      }
    }

    return _buildSensorCard(
      title: 'ความชื้น (Humidity)',
      value: humVal,
      badgeText: statusText,
      badgeColor: statusColor,
      icon: Icons.water_drop_rounded,
      iconColor: const Color(0xFF0284C7),
      progress: progress,
      progressBarColor: const Color(0xFF38BDF8),
      footerText: 'ช่วง 0% - 100% RH',
    );
  }

  Widget _buildLightCard() {
    final lightPct = data.lightLevel;
    final valText = lightPct != null ? '$lightPct%' : '--';
    final progress = lightPct != null ? (lightPct / 100.0).clamp(0.0, 1.0) : 0.0;
    final isBright = (lightPct ?? 0) >= 30;

    return _buildSensorCard(
      title: 'ระดับแสง (Light)',
      value: valText,
      badgeText: isBright ? 'สว่าง (BRIGHT)' : 'มืด (DARK)',
      badgeColor: isBright ? const Color(0xFFF59E0B) : const Color(0xFF6366F1),
      icon: Icons.wb_sunny_rounded,
      iconColor: const Color(0xFFFBBF24),
      progress: progress,
      progressBarColor: const Color(0xFFFBBF24),
      footerText: data.lightRaw != null ? 'Raw: ${data.lightRaw}' : 'LDR Photoresistor',
    );
  }

  Widget _buildPeopleCard() {
    final hasPeople = data.peopleDetected;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasPeople
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : const Color(0xFF334155),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: hasPeople
                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: hasPeople
                      ? const Color(0xFF065F46).withValues(alpha: 0.6)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_pin_circle_rounded,
                  color: hasPeople ? const Color(0xFF10B981) : const Color(0xFF64748B),
                  size: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (hasPeople ? const Color(0xFF10B981) : const Color(0xFF64748B))
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasPeople ? 'ตรวจพบคน' : 'ไม่มีคน',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: hasPeople ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),

          // Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ตรวจจับการเคลื่อนไหว',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 2),
              Text(
                hasPeople ? 'DETECTED' : 'CLEAR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: hasPeople ? const Color(0xFF34D399) : const Color(0xFF64748B),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),

          // Footer
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasPeople ? const Color(0xFF10B981) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 5),
              const Expanded(
                child: Text(
                  'เรดาร์ LD2420 / PIR',
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required Color iconColor,
    required double progress,
    required Color progressBarColor,
    required String footerText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),

          // Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),

          // Progress Bar & Footer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: const Color(0xFF0F172A),
                  valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                footerText,
                style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
