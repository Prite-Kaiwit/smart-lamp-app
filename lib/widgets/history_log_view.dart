import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sensor_data.dart';

class HistoryLogView extends StatelessWidget {
  final List<SensorData> logs;

  const HistoryLogView({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Text(
            'ไม่มีประวัติข้อมูล Telemetry หรือกำลังโหลด...',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_rounded, size: 20, color: Color(0xFF38BDF8)),
                  SizedBox(width: 8),
                  Text(
                    'บันทึกข้อมูลย้อนหลัง (Telemetry Logs)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(
                  '${logs.length} รายการ',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Log List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length > 8 ? 8 : logs.length,
            separatorBuilder: (context, index) => const Divider(
              color: Color(0xFF334155),
              height: 12,
              thickness: 0.8,
            ),
            itemBuilder: (context, index) {
              final log = logs[index];
              final d = log.createdAt ?? log.updatedAt ?? DateTime.now();
              final timeStr = DateFormat('HH:mm:ss').format(d);
              final isLampOn = log.isLampOn;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Time Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Lamp Status Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isLampOn ? const Color(0xFF10B981) : const Color(0xFF64748B))
                            .withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isLampOn ? const Color(0xFF10B981) : const Color(0xFF475569),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        log.lampStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isLampOn ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Metrics
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (log.temperature != null)
                            _buildMetricChip(
                              Icons.thermostat_rounded,
                              '${log.temperature!.toStringAsFixed(1)}°C',
                              const Color(0xFFF97316),
                            ),
                          if (log.humidity != null)
                            _buildMetricChip(
                              Icons.water_drop_rounded,
                              '${log.humidity!.toStringAsFixed(1)}%',
                              const Color(0xFF38BDF8),
                            ),
                          if (log.lightLevel != null)
                            _buildMetricChip(
                              Icons.wb_sunny_rounded,
                              '${log.lightLevel}%',
                              const Color(0xFFFBBF24),
                            ),
                          _buildMetricChip(
                            log.peopleDetected
                                ? Icons.person_rounded
                                : Icons.person_outline_rounded,
                            log.peopleDetected ? 'คนอยู่' : 'ว่าง',
                            log.peopleDetected
                                ? const Color(0xFF10B981)
                                : const Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 10.5,
            color: const Color(0xFFCBD5E1),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
