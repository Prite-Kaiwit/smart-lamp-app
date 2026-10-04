import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

class LampControlCard extends StatefulWidget {
  final SensorData data;
  final Function(bool) onToggleLamp;
  final Function(String) onSelectMode;
  final Function(int) onChangeBrightness;

  const LampControlCard({
    super.key,
    required this.data,
    required this.onToggleLamp,
    required this.onSelectMode,
    required this.onChangeBrightness,
  });

  @override
  State<LampControlCard> createState() => _LampControlCardState();
}

class _LampControlCardState extends State<LampControlCard> {
  double? _tempBrightness;
  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    final isLampOn = widget.data.isLampOn;
    final currentBrightness = _tempBrightness ?? widget.data.brightness.toDouble();
    final mode = widget.data.mode;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slate 800
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLampOn
              ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
              : const Color(0xFF334155),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isLampOn
                ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Lamp Icon + Title + Status Badge + Toggle Switch
          Row(
            children: [
              // Glowing Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLampOn
                      ? const Color(0xFFFEF3C7).withValues(alpha: 0.15)
                      : const Color(0xFF0F172A),
                  border: Border.all(
                    color: isLampOn ? const Color(0xFFF59E0B) : const Color(0xFF475569),
                    width: 2,
                  ),
                  boxShadow: isLampOn
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isLampOn ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                  color: isLampOn ? const Color(0xFFFBBF24) : const Color(0xFF64748B),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Title & State Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'สมาร์ทแลมป์ (Smart Lamp)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLampOn
                                ? const Color(0xFF065F46).withValues(alpha: 0.6)
                                : const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isLampOn ? const Color(0xFF10B981) : const Color(0xFF475569),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isLampOn ? 'กำลังเปิด (ON)' : 'ปิดการทำงาน (OFF)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isLampOn ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          mode,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Power Switch
              Transform.scale(
                scale: 1.15,
                child: Switch(
                  value: isLampOn,
                  activeThumbColor: const Color(0xFFF59E0B),
                  activeTrackColor: const Color(0xFF78350F),
                  inactiveThumbColor: const Color(0xFF94A3B8),
                  inactiveTrackColor: const Color(0xFF334155),
                  onChanged: (val) => widget.onToggleLamp(val),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 16),

          // Brightness Control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.brightness_6_rounded, size: 18, color: Color(0xFF94A3B8)),
                  SizedBox(width: 8),
                  Text(
                    'ความสว่าง (Brightness)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
              Text(
                '${currentBrightness.round()}%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFBBF24),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFF59E0B),
              inactiveTrackColor: const Color(0xFF334155),
              thumbColor: const Color(0xFFFBBF24),
              overlayColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
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

          const SizedBox(height: 8),

          // Mode Selection Header
          const Text(
            'โหมดการทำงาน (Operation Mode)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 10),

          // Mode Buttons: AUTO, FORCE ON, FORCE OFF
          Row(
            children: [
              Expanded(
                child: _buildModeButton(
                  title: 'AUTO',
                  subtitle: 'ตรวจจับคน+แสง',
                  icon: Icons.auto_mode_rounded,
                  activeColor: const Color(0xFF10B981),
                  isSelected: mode == 'AUTO',
                  onTap: () => widget.onSelectMode('AUTO'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModeButton(
                  title: 'FORCE ON',
                  subtitle: 'เปิดตลอด',
                  icon: Icons.flash_on_rounded,
                  activeColor: const Color(0xFFF59E0B),
                  isSelected: mode == 'FORCE ON',
                  onTap: () => widget.onSelectMode('FORCE ON'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModeButton(
                  title: 'FORCE OFF',
                  subtitle: 'ปิดตลอด',
                  icon: Icons.power_settings_new_rounded,
                  activeColor: const Color(0xFFEF4444),
                  isSelected: mode == 'FORCE OFF',
                  onTap: () => widget.onSelectMode('FORCE OFF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.18) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFF334155),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? activeColor : const Color(0xFF64748B),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
