import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../theme/app_colors.dart';

class HeroStatusBar extends StatelessWidget {
  final SensorData data;

  const HeroStatusBar({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final crossAxisCount = isWide ? 4 : 2;
        final childAspectRatio = isWide ? 1.6 : 1.35;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _buildModeCard(),
            _buildLampCard(),
            _buildLightCard(),
            _buildPeopleCard(),
          ],
        );
      },
    );
  }

  Widget _buildModeCard() {
    String desc = 'เปิดหลอดไฟตลอดเวลา';
    if (data.mode == 'AUTO') desc = 'ตรวจจับแสงและคน';
    if (data.mode == 'FORCE OFF') desc = 'ปิดหลอดไฟตลอดเวลา';

    return _buildStatusItem(
      label: 'โหมดการทำงาน (Mode)',
      value: data.mode,
      valueColor: AppColors.amber400,
      subText: desc,
      icon: Icons.flash_on_rounded,
      iconColor: AppColors.amber400,
      iconBg: AppColors.amber950.withValues(alpha: 0.6),
      iconBorder: AppColors.amber600.withValues(alpha: 0.3),
    );
  }

  Widget _buildLampCard() {
    final isLampOn = data.isLampOn;
    final value = isLampOn ? 'ON (เปิด)' : 'OFF (ปิด)';
    final valueColor = isLampOn ? AppColors.emeraldLight : AppColors.mutedText;
    final desc = isLampOn
        ? 'สว่าง ${data.brightness}%'
        : 'หลอดไฟปิดการทำงาน';

    return _buildStatusItem(
      label: 'สถานะหลอดไฟ (Lamp)',
      value: value,
      valueColor: valueColor,
      subText: desc,
      icon: isLampOn ? Icons.wb_sunny_rounded : Icons.nightlight_round,
      iconColor: isLampOn ? AppColors.emeraldLight : AppColors.mutedText,
      iconBg: isLampOn
          ? AppColors.emerald950.withValues(alpha: 0.6)
          : AppColors.innerCard,
      iconBorder: isLampOn
          ? AppColors.emerald.withValues(alpha: 0.4)
          : AppColors.cardBorder,
      hasGlow: isLampOn,
    );
  }

  Widget _buildLightCard() {
    final isDark = (data.lightLevel ?? 0) < 30;
    final value = isDark ? 'DARK (มืด)' : 'BRIGHT (สว่าง)';
    final rawText = data.lightRaw != null ? ' (ดิบ: ${data.lightRaw})' : '';
    final desc = 'ระดับแสง ${data.lightLevel ?? 0} / 100$rawText';

    return _buildStatusItem(
      label: 'สภาพแสงแวดล้อม (Light)',
      value: value,
      valueColor: AppColors.amber400,
      subText: desc,
      icon: Icons.nightlight_round,
      iconColor: AppColors.amber400,
      iconBg: AppColors.amber950.withValues(alpha: 0.6),
      iconBorder: AppColors.amber700.withValues(alpha: 0.3),
    );
  }

  Widget _buildPeopleCard() {
    final hasPeople = data.peopleDetected;
    final value = hasPeople ? 'YES (มีคน)' : 'NO (ว่าง)';
    final valueColor = hasPeople ? AppColors.orange : AppColors.mutedText;
    final desc = hasPeople
        ? 'สถานะ: DETECTED'
        : 'สถานะ: CLEAR';

    return _buildStatusItem(
      label: 'การตรวจจับคน (People)',
      value: value,
      valueColor: valueColor,
      subText: desc,
      icon: Icons.how_to_reg_rounded,
      iconColor: hasPeople ? AppColors.orange : AppColors.mutedText,
      iconBg: AppColors.amber950,
      iconBorder: AppColors.amber700.withValues(alpha: 0.4),
    );
  }

  Widget _buildStatusItem({
    required String label,
    required String value,
    required Color valueColor,
    required String subText,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color iconBorder,
    bool hasGlow = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: AppColors.amber500.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subText,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.mutedText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconBorder),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }
}
