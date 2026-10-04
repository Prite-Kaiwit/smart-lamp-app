import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ThemeSettingsPage extends StatefulWidget {
  final bool isLightMode;
  final ValueChanged<bool> onThemeChanged;

  const ThemeSettingsPage({
    super.key,
    required this.isLightMode,
    required this.onThemeChanged,
  });

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  late bool _selectedLightMode;

  @override
  void initState() {
    super.initState();
    _selectedLightMode = widget.isLightMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        title: const Text('ธีมและการแสดงผล'),
        leading: IconButton(
          tooltip: 'ย้อนกลับ',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Text(
                'เลือกบรรยากาศที่เหมาะกับคุณ',
                style: TextStyle(
                  color: AppColors.warmText,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'การเปลี่ยนธีมจะมีผลกับหน้า Dashboard และหน้าตั้งค่าทั้งหมด',
                style: TextStyle(color: AppColors.mutedText, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _ThemeChoiceCard(
                isLight: true,
                selected: _selectedLightMode,
                onTap: () => setState(() => _selectedLightMode = true),
              ),
              const SizedBox(height: 14),
              _ThemeChoiceCard(
                isLight: false,
                selected: !_selectedLightMode,
                onTap: () => setState(() => _selectedLightMode = false),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () {
                  widget.onThemeChanged(_selectedLightMode);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('ใช้ธีมนี้'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.amber500,
                  foregroundColor: const Color(0xFF34291F),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeChoiceCard extends StatelessWidget {
  final bool isLight;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoiceCard({
    required this.isLight,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isLight
        ? const Color(0xFFF2EEE7)
        : const Color(0xFF141210);
    final surface = isLight ? Colors.white : const Color(0xFF1D1916);
    final ink = isLight ? const Color(0xFF34291F) : const Color(0xFFF5EDE4);
    final muted = isLight ? const Color(0xFF66574A) : const Color(0xFF9E8E80);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.amber500 : AppColors.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 190,
              height: 112,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    height: 13,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.lightbulb_rounded,
                                color: AppColors.amber500,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: surface,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '24°',
                                      style: TextStyle(
                                        color: ink,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: surface,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLight ? 'โทนสว่างอบอุ่น' : 'โทนมืดอบอุ่น',
                    style: TextStyle(
                      color: AppColors.warmText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isLight
                        ? 'พื้นสีครีม การ์ดสีขาว และ Amber แบบเว็บไซต์'
                        : 'พื้นเข้ม ลดความสว่าง เหมาะกับพื้นที่แสงน้อย',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selected ? 'เลือกอยู่' : 'แตะเพื่อเลือก',
                    style: TextStyle(
                      color: selected ? AppColors.amber400 : muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.amber500),
          ],
        ),
      ),
    );
  }
}
