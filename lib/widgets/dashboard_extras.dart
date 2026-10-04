import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../theme/app_colors.dart';

class AlertRulesDialog extends StatefulWidget {
  final double temperatureLimit;
  final bool alertOnEmptyRoom;
  final bool alertOnOffline;
  final ValueChanged<double> onSave;
  final ValueChanged<bool> onEmptyRoomChanged;
  final ValueChanged<bool> onOfflineChanged;

  const AlertRulesDialog({
    super.key,
    required this.temperatureLimit,
    required this.alertOnEmptyRoom,
    required this.alertOnOffline,
    required this.onSave,
    required this.onEmptyRoomChanged,
    required this.onOfflineChanged,
  });

  @override
  State<AlertRulesDialog> createState() => _AlertRulesDialogState();
}

class _AlertRulesDialogState extends State<AlertRulesDialog> {
  late final TextEditingController _temperatureController;
  late bool _emptyRoomEnabled;
  late bool _offlineEnabled;

  @override
  void initState() {
    super.initState();
    _temperatureController = TextEditingController(
      text: widget.temperatureLimit.toStringAsFixed(0),
    );
    _emptyRoomEnabled = widget.alertOnEmptyRoom;
    _offlineEnabled = widget.alertOnOffline;
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  void _save() {
    final limit = double.tryParse(_temperatureController.text);
    if (limit == null || limit < 0 || limit > 80) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกอุณหภูมิระหว่าง 0 ถึง 80 °C'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    widget.onSave(limit);
    widget.onEmptyRoomChanged(_emptyRoomEnabled);
    widget.onOfflineChanged(_offlineEnabled);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(
        'ตั้งค่าการแจ้งเตือน',
        style: TextStyle(
          color: AppColors.warmText,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _temperatureController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(color: AppColors.warmText),
              decoration: InputDecoration(
                labelText: 'แจ้งเตือนเมื่ออุณหภูมิสูงกว่า (°C)',
                labelStyle: TextStyle(color: AppColors.mutedText),
                filled: true,
                fillColor: AppColors.innerCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.innerBorder),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'ห้องว่างแต่ไฟยังเปิด',
                style: TextStyle(color: AppColors.warmText, fontSize: 13),
              ),
              value: _emptyRoomEnabled,
              activeThumbColor: AppColors.amber400,
              onChanged: (value) => setState(() => _emptyRoomEnabled = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'อุปกรณ์ออฟไลน์เกิน 5 นาที',
                style: TextStyle(color: AppColors.warmText, fontSize: 13),
              ),
              value: _offlineEnabled,
              activeThumbColor: AppColors.amber400,
              onChanged: (value) => setState(() => _offlineEnabled = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.amber500,
            foregroundColor: AppColors.bgDark,
          ),
          onPressed: _save,
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}

class DashboardInsights extends StatelessWidget {
  final SensorData data;
  final List<SensorData> history;
  final bool isOnline;
  final Duration offlineDuration;
  final double temperatureLimit;
  final bool alertOnEmptyRoom;
  final bool alertOnOffline;
  final VoidCallback onConfigureAlerts;

  const DashboardInsights({
    super.key,
    required this.data,
    required this.history,
    required this.isOnline,
    required this.offlineDuration,
    required this.temperatureLimit,
    required this.alertOnEmptyRoom,
    required this.alertOnOffline,
    required this.onConfigureAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final alerts = <_Insight>[
      if (data.temperature != null && data.temperature! > temperatureLimit)
        _Insight(
          'อุณหภูมิสูงกว่าค่าที่ตั้งไว้',
          '${data.temperature!.toStringAsFixed(1)} °C · เกณฑ์ ${temperatureLimit.toStringAsFixed(0)} °C',
          Icons.device_thermostat_rounded,
          AppColors.orange,
        ),
      if (alertOnEmptyRoom && !data.peopleDetected && data.isLampOn)
        _Insight(
          'ห้องว่างแต่ไฟยังเปิดอยู่',
          'ตรวจสอบว่าต้องการปิดไฟหรือไม่',
          Icons.lightbulb_circle_rounded,
          AppColors.amber400,
        ),
      if (alertOnOffline && !isOnline && offlineDuration.inMinutes >= 5)
        _Insight(
          'อุปกรณ์ออฟไลน์',
          'ไม่ได้รับข้อมูล ${offlineDuration.inMinutes} นาที',
          Icons.wifi_off_rounded,
          AppColors.red,
        ),
    ];

    final recommendation = _recommendation();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.notifications_active_rounded, AppColors.amber400),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'การแจ้งเตือนและคำแนะนำ',
                      style: TextStyle(
                        color: AppColors.warmText,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'อัปเดตตามข้อมูลเซ็นเซอร์ล่าสุด',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onConfigureAlerts,
                icon: const Icon(Icons.tune_rounded, size: 15),
                label: const Text('ตั้งค่า'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.amber300,
                  side: BorderSide(
                    color: AppColors.amber700.withValues(alpha: 0.55),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (alerts.isEmpty)
            _InsightTile(
              insight: _Insight(
                'ยังไม่พบการแจ้งเตือน',
                isOnline
                    ? 'ระบบและสภาพห้องอยู่ในเกณฑ์ปกติ'
                    : 'กำลังรอการเชื่อมต่อกับอุปกรณ์',
                isOnline
                    ? Icons.check_circle_rounded
                    : Icons.hourglass_top_rounded,
                isOnline ? AppColors.emeraldLight : AppColors.mutedText,
              ),
            )
          else
            ...alerts.map((alert) => _InsightTile(insight: alert)),
          const SizedBox(height: 8),
          _InsightTile(insight: recommendation, isRecommendation: true),
        ],
      ),
    );
  }

  _Insight _recommendation() {
    if (data.isLampOn && !data.peopleDetected) {
      return _Insight(
        'คำแนะนำ',
        'ห้องไม่พบคน ลองใช้ฉาก “ปิดห้อง” เพื่อประหยัดพลังงาน',
        Icons.tips_and_updates_rounded,
        AppColors.amber300,
      );
    }
    if (history.length > 1) {
      final latestTemp = data.temperature;
      final olderTemp = history.last.temperature;
      if (latestTemp != null && olderTemp != null) {
        final change = latestTemp - olderTemp;
        if (change.abs() >= 2) {
          final direction = change > 0 ? 'สูงขึ้น' : 'ลดลง';
          return _Insight(
            'แนวโน้มอุณหภูมิ',
            'อุณหภูมิ$direction ${change.abs().toStringAsFixed(1)} °C จากข้อมูลชุดก่อน',
            Icons.trending_up_rounded,
            AppColors.sky,
          );
        }
      }
    }
    return _Insight(
      'คำแนะนำ',
      'ระบบกำลังติดตามแนวโน้ม เมื่อมีข้อมูลเพิ่มเติมจะแสดงคำแนะนำที่นี่',
      Icons.tips_and_updates_rounded,
      AppColors.sky,
    );
  }
}

class QuickScenes extends StatefulWidget {
  final Future<void> Function(String name, String mode, int brightness) onApply;

  const QuickScenes({super.key, required this.onApply});

  @override
  State<QuickScenes> createState() => _QuickScenesState();
}

class _QuickScenesState extends State<QuickScenes> {
  String? _busyScene;

  Future<void> _apply(String name, String mode, int brightness) async {
    if (_busyScene != null) return;
    setState(() => _busyScene = name);
    try {
      await widget.onApply(name, mode, brightness);
    } finally {
      if (mounted) setState(() => _busyScene = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ฉากใช้งานด่วน',
            style: TextStyle(
              color: AppColors.warmText,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'ปรับโหมดและความสว่างด้วยการแตะครั้งเดียว',
            style: TextStyle(color: AppColors.mutedText, fontSize: 10),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _sceneButton(
                'สอน',
                'เปิดไฟอัตโนมัติ · 100%',
                Icons.co_present_rounded,
                AppColors.amber400,
                () => _apply('สอน', 'AUTO', 100),
              ),
              _sceneButton(
                'พัก',
                'โหมดอัตโนมัติ · 45%',
                Icons.coffee_rounded,
                AppColors.sky,
                () => _apply('พัก', 'AUTO', 45),
              ),
              _sceneButton(
                'ปิดห้อง',
                'ปิดไฟ · 10%',
                Icons.meeting_room_rounded,
                AppColors.mutedText,
                () => _apply('ปิดห้อง', 'FORCE OFF', 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sceneButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final isBusy = _busyScene == title;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 145),
      child: OutlinedButton(
        onPressed: _busyScene == null ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.32)),
          backgroundColor: color.withValues(alpha: 0.06),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBusy)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(icon, size: 18),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EventHistory extends StatelessWidget {
  final List<Map<String, String>> events;
  final VoidCallback onClear;

  const EventHistory({super.key, required this.events, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final visibleEvents = events.take(8).toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.history_rounded, AppColors.sky),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ประวัติการทำงาน',
                  style: TextStyle(
                    color: AppColors.warmText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (events.isNotEmpty)
                TextButton(
                  onPressed: onClear,
                  child: const Text(
                    'ล้างประวัติ',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
          if (visibleEvents.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'ยังไม่มีเหตุการณ์ควบคุมไฟ',
                  style: TextStyle(color: AppColors.mutedText),
                ),
              ),
            )
          else
            ...visibleEvents.map((event) {
              final time = DateTime.tryParse(event['time'] ?? '')?.toLocal();
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.bolt_rounded,
                  color: AppColors.amber400,
                  size: 18,
                ),
                title: Text(
                  event['message'] ?? 'มีการเปลี่ยนแปลง',
                  style: TextStyle(
                    color: AppColors.warmText,
                    fontSize: 12,
                  ),
                ),
                subtitle: Text(
                  time == null
                      ? 'เวลาที่ไม่ทราบ'
                      : '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: AppColors.dimText,
                    fontSize: 10,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _Insight {
  final String title;
  final String detail;
  final IconData icon;
  final Color color;

  const _Insight(this.title, this.detail, this.icon, this.color);
}

class _InsightTile extends StatelessWidget {
  final _Insight insight;
  final bool isRecommendation;

  const _InsightTile({required this.insight, this.isRecommendation = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: insight.color.withValues(alpha: isRecommendation ? 0.07 : 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: insight.color.withValues(alpha: 0.19)),
      ),
      child: Row(
        children: [
          Icon(insight.icon, color: insight.color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    color: insight.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  insight.detail,
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _iconBox(IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.24)),
    ),
    child: Icon(icon, color: color, size: 18),
  );
}
