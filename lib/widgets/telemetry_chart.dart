import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sensor_data.dart';
import '../theme/app_colors.dart';

class TelemetryChart extends StatefulWidget {
  final List<SensorData> history;

  const TelemetryChart({super.key, required this.history});

  @override
  State<TelemetryChart> createState() => _TelemetryChartState();
}

class _TelemetryChartState extends State<TelemetryChart> {
  String _activeTab = 'all'; // 'all', 'tempHum', 'light'
  Duration? _range = const Duration(hours: 1);

  List<SensorData> get _filteredHistory {
    final range = _range;
    if (range == null) return widget.history;
    final now = DateTime.now();
    final filtered = widget.history.where((item) {
      final timestamp = item.createdAt ?? item.updatedAt;
      return timestamp == null || now.difference(timestamp) <= range;
    }).toList();
    return filtered;
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
          // Header Row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.amber950.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.amber600.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.show_chart_rounded,
                            color: AppColors.amber400,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'กราฟแนวโน้มข้อมูลสภาพแวดล้อม',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warmText,
                                ),
                              ),
                              Text(
                                'Telemetry Real-time Charts',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.innerCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.innerBorder),
                    ),
                    child: Text(
                      '${_filteredHistory.length} จุด',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.amber400,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Tab Switcher
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.innerCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.innerBorder),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildTabBtn('all', 'ภาพรวมทั้งหมด')),
                    Expanded(
                      child: _buildTabBtn('tempHum', 'อุณหภูมิ & ความชื้น'),
                    ),
                    Expanded(child: _buildTabBtn('light', 'ระดับแสง (Light)')),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      children: [
                        _buildRangeBtn('1 ชม.', const Duration(hours: 1)),
                        _buildRangeBtn('24 ชม.', const Duration(hours: 24)),
                        _buildRangeBtn('7 วัน', const Duration(days: 7)),
                        _buildRangeBtn('ทั้งหมด', null),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart Canvas
          SizedBox(
            height: 210,
            child: _filteredHistory.isEmpty
                ? Center(
                    child: Text(
                      'กำลังรอรับข้อมูล Telemetry...',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  )
                : LineChart(_buildChartData()),
          ),

          const SizedBox(height: 12),
          _buildStatistics(),
          const SizedBox(height: 14),

          // Legend and Footer
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.innerBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (_activeTab == 'all' || _activeTab == 'tempHum') ...[
                      _buildLegendItem('อุณหภูมิ (°C)', AppColors.amber400),
                      const SizedBox(width: 10),
                      _buildLegendItem('ความชื้น (%)', AppColors.cyan),
                      const SizedBox(width: 10),
                    ],
                    if (_activeTab == 'all' || _activeTab == 'light')
                      _buildLegendItem('ระดับแสง (%)', AppColors.orange),
                  ],
                ),
                Text(
                  'อัปเดตสดทุก 2 วิ',
                  style: TextStyle(fontSize: 10, color: AppColors.dimText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBtn(String key, String title) {
    final isSelected = _activeTab == key;
    return InkWell(
      onTap: () => setState(() => _activeTab = key),
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.amber500 : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF141210) : AppColors.mutedText,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: Color(0xFFA89A8E)),
        ),
      ],
    );
  }

  Widget _buildRangeBtn(String label, Duration? range) {
    final selected = _range == range;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _range = range),
      labelStyle: TextStyle(
        color: selected ? AppColors.bgDark : AppColors.mutedText,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: AppColors.innerCard,
      selectedColor: AppColors.amber400,
      side: BorderSide(
        color: selected ? AppColors.amber400 : AppColors.innerBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      showCheckmark: false,
    );
  }

  Widget _buildStatistics() {
    final history = _filteredHistory;
    final series = <(String, Color, List<double>)>[
      (
        'อุณหภูมิ',
        AppColors.amber400,
        history.map((item) => item.temperature).whereType<double>().toList(),
      ),
      (
        'ความชื้น',
        AppColors.cyan,
        history.map((item) => item.humidity).whereType<double>().toList(),
      ),
      (
        'แสง',
        AppColors.orange,
        history
            .map((item) => item.lightLevel?.toDouble())
            .whereType<double>()
            .toList(),
      ),
    ];
    final visible = series.where((item) {
      if (_activeTab == 'light') return item.$1 == 'แสง';
      if (_activeTab == 'tempHum') return item.$1 != 'แสง';
      return true;
    });

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: visible.map((item) {
        final values = item.$3;
        if (values.isEmpty) return const SizedBox.shrink();
        final min = values.reduce((a, b) => a < b ? a : b);
        final max = values.reduce((a, b) => a > b ? a : b);
        final average = values.reduce((a, b) => a + b) / values.length;
        final suffix = item.$1 == 'อุณหภูมิ' ? '°C' : '%';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.innerCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.innerBorder),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${item.$1}  ',
                  style: TextStyle(color: item.$2, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'min ${min.toStringAsFixed(1)} · avg ${average.toStringAsFixed(1)} · max ${max.toStringAsFixed(1)} $suffix',
                  style: TextStyle(color: AppColors.mutedText),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 9.5),
          ),
        );
      }).toList(),
    );
  }

  LineChartData _buildChartData() {
    final history = _filteredHistory;
    final spotsTemp = <FlSpot>[];
    final spotsHum = <FlSpot>[];
    final spotsLight = <FlSpot>[];

    for (int i = 0; i < history.length; i++) {
      final item = history[i];
      final x = i.toDouble();
      if (item.temperature != null) {
        spotsTemp.add(FlSpot(x, item.temperature!));
      }
      if (item.humidity != null) {
        spotsHum.add(FlSpot(x, item.humidity!));
      }
      if (item.lightLevel != null) {
        spotsLight.add(FlSpot(x, item.lightLevel!.toDouble()));
      }
    }

    final barDataList = <LineChartBarData>[];

    // Temperature (Warm Amber)
    if ((_activeTab == 'all' || _activeTab == 'tempHum') &&
        spotsTemp.isNotEmpty) {
      barDataList.add(
        LineChartBarData(
          spots: spotsTemp,
          isCurved: true,
          color: AppColors.amber400,
          barWidth: 2.2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.amber400.withValues(alpha: 0.08),
          ),
        ),
      );
    }

    // Humidity (Cyan)
    if ((_activeTab == 'all' || _activeTab == 'tempHum') &&
        spotsHum.isNotEmpty) {
      barDataList.add(
        LineChartBarData(
          spots: spotsHum,
          isCurved: true,
          color: AppColors.cyan,
          barWidth: 2.2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.cyan.withValues(alpha: 0.08),
          ),
        ),
      );
    }

    // Light (Orange)
    if ((_activeTab == 'all' || _activeTab == 'light') &&
        spotsLight.isNotEmpty) {
      barDataList.add(
        LineChartBarData(
          spots: spotsLight,
          isCurved: true,
          color: AppColors.orange,
          barWidth: 2.2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.orange.withValues(alpha: 0.08),
          ),
        ),
      );
    }

    return LineChartData(
      lineBarsData: barDataList,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.cardBorder.withValues(alpha: 0.6),
          strokeWidth: 0.8,
          dashArray: [4, 4],
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 25,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.dimText,
                  fontFamily: 'monospace',
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 20,
            interval: (history.length / 4).clamp(1.0, 10.0),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < history.length) {
                final d = history[index].createdAt ?? history[index].updatedAt;
                final text = d != null
                    ? DateFormat('HH:mm').format(d)
                    : '#$index';
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 8.5,
                      color: AppColors.dimText,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: 100,
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.innerCard,
          tooltipBorder: BorderSide(color: AppColors.cardBorder),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
        ),
      ),
    );
  }
}
