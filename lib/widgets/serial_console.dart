import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/sensor_data.dart';
import '../theme/app_colors.dart';

class SerialConsole extends StatefulWidget {
  final List<SensorData> logs;

  const SerialConsole({super.key, required this.logs});

  @override
  State<SerialConsole> createState() => _SerialConsoleState();
}

class _SerialConsoleState extends State<SerialConsole> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  final List<String> _customTerminalLines = [];

  @override
  void didUpdateWidget(covariant SerialConsole oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _clearLogs() {
    setState(() {
      _customTerminalLines.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ล้างหน้าจอ Terminal เรียบร้อย'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _copyLogs(List<String> lines) {
    final allText = lines.join('\n');
    Clipboard.setData(ClipboardData(text: allText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอก Logs ลงในคลิปบอร์ดแล้ว'),
        backgroundColor: AppColors.emerald,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> lines = [];

    // Prepopulate from logs
    for (final item in widget.logs.reversed) {
      final d = item.createdAt ?? item.updatedAt ?? DateTime.now();
      final timeStr = DateFormat('HH:mm:ss').format(d);
      final temp = item.temperature != null ? '${item.temperature!.toStringAsFixed(1)}°C' : '--';
      final hum = item.humidity != null ? '${item.humidity!.toStringAsFixed(1)}%' : '--';
      final light = item.lightLevel != null ? '${item.lightLevel}%' : '--';
      final people = item.peopleDetected ? 'YES' : 'NO';
      lines.add('[$timeStr] ESP32 -> T:$temp | H:$hum | L:$light | People:$people | Lamp:${item.lampStatus} | Mode:${item.mode}');
    }

    if (lines.isEmpty) {
      lines.add('[--:--:--] รอการเชื่อมต่อ ESP32 Node 192.168.1.105...');
      lines.add('[--:--:--] เริ่มต้นสตรีมข้อมูลผ่าน REST API & WebSocket...');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(18),
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
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF26211C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Icon(Icons.terminal_rounded, color: AppColors.amber400, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Serial Monitor Console',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warmText,
                        ),
                      ),
                      Text(
                        'เหมือนหน้าจอ Arduino IDE 100%',
                        style: TextStyle(fontSize: 10, color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ],
              ),

              // Controls: Clear, Copy, AutoScroll
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, size: 17, color: AppColors.mutedText),
                    tooltip: 'ล้างหน้าจอ',
                    onPressed: _clearLogs,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: Icon(Icons.copy_rounded, size: 17, color: AppColors.mutedText),
                    tooltip: 'คัดลอก Logs',
                    onPressed: () => _copyLogs(lines),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_circle_down_rounded,
                      size: 19,
                      color: _autoScroll ? AppColors.amber400 : AppColors.mutedText,
                    ),
                    tooltip: 'เลื่อนลงล่างสุดอัตโนมัติ',
                    onPressed: () => setState(() => _autoScroll = !_autoScroll),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Terminal Window
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.terminalBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.terminalBorder),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Terminal Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.emerald,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'COM4 (115200 baud)',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.mutedText,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Timestamp -> Payload',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF57534E),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),

                Divider(color: AppColors.terminalBorder, height: 14),

                // Terminal Lines
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      final line = lines[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Text(
                          line,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFD6D3D1),
                            fontFamily: 'monospace',
                            height: 1.3,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.amber400,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'บันทึกแล้ว ${lines.length} รายการ',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.mutedText,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _copyLogs(lines),
                child: Row(
                  children: [
                    Icon(Icons.download_rounded, size: 14, color: AppColors.amber400),
                    SizedBox(width: 4),
                    Text(
                      'คัดลอกทั้งหมด',
                      style: TextStyle(fontSize: 10.5, color: AppColors.amber400, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
