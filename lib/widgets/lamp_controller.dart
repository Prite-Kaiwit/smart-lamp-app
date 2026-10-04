import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../theme/app_colors.dart';

class LampController extends StatefulWidget {
  final SensorData data;
  final Function(bool) onToggleLamp;
  final Function(String) onSelectMode;
  final Function(int) onChangeBrightness;

  const LampController({
    super.key,
    required this.data,
    required this.onToggleLamp,
    required this.onSelectMode,
    required this.onChangeBrightness,
  });

  @override
  State<LampController> createState() => _LampControllerState();
}

class _LampControllerState extends State<LampController> {
  double? _tempBrightness;
  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    final isLampOn = widget.data.isLampOn;
    final currentBrightness = _tempBrightness ?? widget.data.brightness.toDouble();
    final mode = widget.data.mode;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: isLampOn
                ? AppColors.amber500.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: Icon(Icons.tune_rounded, color: AppColors.amber400, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'แผงควบคุมไฟอัจฉริยะ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warmText,
                        ),
                      ),
                      Text(
                        'ควบคุม Relay / หลอดไฟ & โหมด',
                        style: TextStyle(fontSize: 10.5, color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isLampOn
                      ? AppColors.emerald950.withValues(alpha: 0.8)
                      : const Color(0xFF26211C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLampOn
                        ? AppColors.emerald.withValues(alpha: 0.5)
                        : const Color(0xFF44372D),
                    width: 1,
                  ),
                ),
                child: Text(
                  isLampOn ? 'กำลังสว่าง (ON)' : 'ปิดการทำงาน (OFF)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isLampOn ? AppColors.emeraldLight : const Color(0xFFA89A8E),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Realistic Hanging Lamp Visualizer
          GestureDetector(
            onTap: () => widget.onToggleLamp(!isLampOn),
            child: Column(
              children: [
                // Hanging Wire
                Container(
                  width: 3,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF57534E), Color(0xFFB45309)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Socket Cap
                Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF44403C), Color(0xFF92400E), Color(0xFF44403C)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    border: Border.all(color: AppColors.amber700.withValues(alpha: 0.4)),
                  ),
                ),
                // Bulb Body
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isLampOn
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.amber400,
                              AppColors.amber300,
                              Color(0xFFFEF9C3),
                            ],
                          )
                        : const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF26211C), Color(0xFF1D1916)],
                          ),
                    border: Border.all(
                      color: isLampOn ? AppColors.amber300 : const Color(0xFF44372D),
                      width: 2,
                    ),
                    boxShadow: isLampOn
                        ? [
                            BoxShadow(
                              color: AppColors.amber500.withValues(alpha: 0.55),
                              blurRadius: 36,
                              spreadRadius: 6,
                            ),
                            BoxShadow(
                              color: AppColors.amber300.withValues(alpha: 0.35),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lightbulb_rounded,
                      size: 54,
                      color: isLampOn ? AppColors.amber900 : const Color(0xFF57534E),
                    ),
                  ),
                ),
                // Floor / Table reflection glow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.only(top: 10),
                  width: 120,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isLampOn
                        ? AppColors.amber500.withValues(alpha: 0.35)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isLampOn
                        ? [
                            BoxShadow(
                              color: AppColors.amber500.withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  isLampOn
                      ? 'หลอดไฟเปิดทำงาน (Warm White 2700K)'
                      : 'หลอดไฟปิดการทำงาน',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isLampOn ? AppColors.amber200 : AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'แตะที่รูปหลอดไฟเพื่อสลับ เปิด/ปิด ได้ทันที',
                  style: TextStyle(fontSize: 10, color: AppColors.dimText),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Quick Toggle Switch & Dimmer Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.innerCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.innerBorder),
            ),
            child: Column(
              children: [
                // Power Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.power_settings_new_rounded, size: 16, color: AppColors.amber400),
                        SizedBox(width: 8),
                        Text(
                          'สวิตช์ไฟหลัก',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warmText,
                          ),
                        ),
                      ],
                    ),
                    Transform.scale(
                      scale: 0.9,
                      child: Switch(
                        value: isLampOn,
                        activeThumbColor: AppColors.amber400,
                        activeTrackColor: AppColors.amber800,
                        inactiveThumbColor: const Color(0xFF786C62),
                        inactiveTrackColor: const Color(0xFF26211C),
                        onChanged: (val) => widget.onToggleLamp(val),
                      ),
                    ),
                  ],
                ),

                const Divider(color: Color(0xFF2B221B), height: 16),

                // Brightness Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.brightness_medium_rounded, size: 15, color: AppColors.amber400),
                        SizedBox(width: 6),
                        Text(
                          'ความสว่าง (PWM Dimmer)',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFFA89A8E)),
                        ),
                      ],
                    ),
                    Text(
                      '${currentBrightness.round()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.amber300,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.amber500,
                    inactiveTrackColor: const Color(0xFF2D231B),
                    thumbColor: AppColors.amber400,
                    overlayColor: AppColors.amber500.withValues(alpha: 0.2),
                    trackHeight: 4.5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.5),
                  ),
                  child: Slider(
                    value: currentBrightness.clamp(10.0, 100.0),
                    min: 10,
                    max: 100,
                    divisions: 18,
                    onChanged: (val) {
                      setState(() => _tempBrightness = val);
                      _debounceTimer?.cancel();
                      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                        widget.onChangeBrightness(val.round());
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Mode Selection Header
          Text(
            'เลือกโหมดการควบคุม (OPERATING MODE)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),

          // 3 Mode Buttons: FORCE ON, AUTO, FORCE OFF
          Row(
            children: [
              Expanded(
                child: _buildModeBtn(
                  title: 'FORCE ON',
                  subtitle: 'เปิดตลอด',
                  icon: Icons.lock_outline_rounded,
                  isSelected: mode == 'FORCE ON',
                  selectedColor: AppColors.amber500,
                  onTap: () => widget.onSelectMode('FORCE ON'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModeBtn(
                  title: 'AUTO',
                  subtitle: 'ตามแสง/คน',
                  icon: Icons.auto_awesome_rounded,
                  isSelected: mode == 'AUTO',
                  selectedColor: AppColors.emerald,
                  onTap: () => widget.onSelectMode('AUTO'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModeBtn(
                  title: 'FORCE OFF',
                  subtitle: 'ปิดตลอด',
                  icon: Icons.power_settings_new_rounded,
                  isSelected: mode == 'FORCE OFF',
                  selectedColor: AppColors.red,
                  onTap: () => widget.onSelectMode('FORCE OFF'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Automation Rule Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amber950.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.amber900.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.amber400, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เงื่อนไขโหมด AUTO ปัจจุบัน:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.amber300,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'หากแสงต่ำกว่า 30% และมีคนอยู่ (DETECTED) หลอดไฟจะเปิดทำงานอัตโนมัติ',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFFA89A8E),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.18)
              : AppColors.innerCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? selectedColor : const Color(0xFF786C62),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFFA89A8E),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.5,
                color: isSelected ? selectedColor : const Color(0xFF786C62),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
