import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../theme/app_colors.dart';

class SensorMetrics extends StatelessWidget {
  final SensorData data;

  const SensorMetrics({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildClimateCard(),
        const SizedBox(height: 14),
        _buildLightCard(),
        const SizedBox(height: 14),
        _buildPeopleCard(),
      ],
    );
  }

  // 1. Climate Card: Temp & Humidity (DHT22)
  Widget _buildClimateCard() {
    final temp = data.temperature;
    final hum = data.humidity;

    final tempVal = temp != null ? temp.toStringAsFixed(1) : '--';
    final humVal = hum != null ? hum.toStringAsFixed(1) : '--';

    final tempProgress = temp != null ? ((temp - 15) / (45 - 15)).clamp(0.0, 1.0) : 0.0;
    final humProgress = hum != null ? (hum / 100.0).clamp(0.0, 1.0) : 0.0;

    String tempDesc = 'รอข้อมูลเซ็นเซอร์';
    Color tempDescColor = AppColors.mutedText;
    if (temp != null) {
      if (temp < 24) {
        tempDesc = 'อยู่ในเกณฑ์เย็นสบาย';
        tempDescColor = AppColors.sky;
      } else if (temp <= 32) {
        tempDesc = 'อุณหภูมิปกติ';
        tempDescColor = AppColors.emeraldLight;
      } else {
        tempDesc = 'อากาศค่อนข้างร้อน';
        tempDescColor = AppColors.orange;
      }
    }

    String humDesc = 'รอข้อมูลเซ็นเซอร์';
    Color humDescColor = AppColors.mutedText;
    if (hum != null) {
      if (hum < 40) {
        humDesc = 'อากาศแห้ง';
        humDescColor = AppColors.amber400;
      } else if (hum <= 70) {
        humDesc = 'ความชื้นพอเหมาะ';
        humDescColor = AppColors.emeraldLight;
      } else {
        humDesc = 'ความชื้นค่อนข้างสูง';
        humDescColor = AppColors.cyan;
      }
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
                      color: AppColors.amber950,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.amber700.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.device_thermostat_rounded, color: AppColors.orange, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'สภาพอากาศ & อุณหภูมิ (Climate)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmText,
                    ),
                  ),
                ],
              ),
              Text(
                'เซ็นเซอร์ DHT22',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedText,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Two subcards: Temp & Humidity
          Row(
            children: [
              // Temperature Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.innerCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.innerBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'อุณหภูมิ (Temp)',
                            style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                          ),
                          Icon(Icons.local_fire_department_rounded, color: AppColors.orange, size: 15),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            tempVal,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.amber300,
                              fontFamily: 'monospace',
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '°C',
                            style: TextStyle(fontSize: 14, color: AppColors.mutedText, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tempDesc,
                        style: TextStyle(fontSize: 10, color: tempDescColor, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Mini Bar Gauge
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 5,
                          color: AppColors.innerBorder,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: tempProgress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.sky, AppColors.amber400, AppColors.orange],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Humidity Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.innerCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.innerBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ความชื้น (Humidity)',
                            style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                          ),
                          Icon(Icons.water_drop_rounded, color: AppColors.amber400, size: 15),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            humVal,
                            style:                             TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.amber200,
                              fontFamily: 'monospace',
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '%',
                            style: TextStyle(fontSize: 14, color: AppColors.mutedText, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        humDesc,
                        style: TextStyle(fontSize: 10, color: humDescColor, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Mini Bar Gauge
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 5,
                          color: AppColors.innerBorder,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: humProgress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.amber400, AppColors.amber600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Light Sensor Card (LDR / ADC)
  Widget _buildLightCard() {
    final lightLevel = data.lightLevel ?? 0;
    final isDark = lightLevel < 30;
    final lightProgress = (lightLevel / 100.0).clamp(0.0, 1.0);

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
                      color: AppColors.amber950.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.amber600.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.wb_sunny_rounded, color: AppColors.amber400, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ระดับแสงแวดล้อม (Light Sensor)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmText,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.innerCard : AppColors.amber950,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF44372D) : AppColors.amber500,
                  ),
                ),
                child: Text(
                  isDark ? 'DARK (มืด)' : 'BRIGHT (สว่าง)',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.amber300 : AppColors.amber400,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Inner Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.innerCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.innerBorder),
            ),
            child: Column(
              children: [
                // Numbers Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Light Level (เปอร์เซ็นต์)',
                          style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$lightLevel',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.amber400,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ 100',
                              style: TextStyle(fontSize: 13, color: AppColors.mutedText, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Light Raw (ค่าดิบ ADC)',
                          style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              data.lightRaw != null ? '${data.lightRaw}' : '--',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.amber200,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ 4095',
                              style: TextStyle(fontSize: 12, color: AppColors.dimText, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 3-Stage Progress Visualizer
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 10,
                    color: AppColors.innerBorder,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: lightProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF57534E), AppColors.amber600, AppColors.amber400],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0% (มืดสนิท)', style: TextStyle(fontSize: 9.5, color: AppColors.amber400, fontFamily: 'monospace')),
                    Text('50% (แสงพอดี)', style: TextStyle(fontSize: 9.5, color: AppColors.dimText, fontFamily: 'monospace')),
                    Text('100% (สว่างจ้า)', style: TextStyle(fontSize: 9.5, color: AppColors.dimText, fontFamily: 'monospace')),
                  ],
                ),

                Divider(color: AppColors.innerBorder, height: 16),

                // Threshold hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('เกณฑ์เปิดไฟอัตโนมัติ:', style: TextStyle(fontSize: 10.5, color: AppColors.mutedText)),
                    Text('< 30% (มืดเข้าเกณฑ์)', style: TextStyle(fontSize: 10.5, color: AppColors.amber300, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. People Detection Card (Proximity Sensor)
  Widget _buildPeopleCard() {
    final hasPeople = data.peopleDetected;

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
                      color: AppColors.amber950,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.amber700.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.radar_rounded, color: AppColors.orange, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'การตรวจจับคน (Proximity Sensor)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmText,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2.5),
                decoration: BoxDecoration(
                  color: hasPeople
                      ? AppColors.emerald950
                      : AppColors.innerCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasPeople
                        ? AppColors.emerald.withValues(alpha: 0.6)
                        : AppColors.innerBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasPeople ? AppColors.emeraldLight : AppColors.dimText,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      hasPeople ? 'YES (ตรวจพบคน)' : 'NO (ไม่มีคน)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: hasPeople ? AppColors.emeraldLight : AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Inner Container with Radar Effect
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.innerCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.innerBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สถานะเซ็นเซอร์ (Detection Status)',
                        style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasPeople ? 'DETECTED' : 'CLEAR',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: hasPeople ? AppColors.emeraldLight : const Color(0xFF786C62),
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasPeople
                            ? 'เซ็นเซอร์ Proximity ยืนยันพบคนในพื้นที่'
                            : 'ไม่มีการเคลื่อนไหวหรือบุคคลในพื้นที่',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: hasPeople ? AppColors.orange : AppColors.dimText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Radar Icon Graphic
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasPeople
                        ? LinearGradient(
                            colors: [AppColors.amber500, AppColors.orange],
                          )
                        : LinearGradient(
                            colors: [AppColors.innerCard, AppColors.innerBorder],
                          ),
                    boxShadow: hasPeople
                        ? [
                            BoxShadow(
                              color: AppColors.amber500.withValues(alpha: 0.4),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                    border: Border.all(
                      color: hasPeople ? AppColors.amber400 : AppColors.innerBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.person_pin_circle_rounded,
                    color: hasPeople ? AppColors.warmText : AppColors.dimText,
                    size: 28,
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
