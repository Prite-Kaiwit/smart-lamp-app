import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'theme_settings_page.dart';

class WelcomeScreen extends StatelessWidget {
  final Widget dashboard;
  final bool isLightTheme;
  final ValueChanged<bool> onThemeChanged;

  const WelcomeScreen({
    super.key,
    required this.dashboard,
    required this.isLightTheme,
    required this.onThemeChanged,
  });

  void _start(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => dashboard));
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 900;
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.88, -0.8),
            radius: 1.2,
            colors: [Color(0xFFFFF8EC), AppColors.bgDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 22 : 56,
                vertical: isCompact ? 24 : 40,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBrand(context),
                    SizedBox(height: isCompact ? 42 : 64),
                    if (isCompact)
                      Column(
                        children: [
                          _buildIllustration(),
                          const SizedBox(height: 28),
                          _buildWelcomeCopy(context, isCompact),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _buildWelcomeCopy(context, isCompact),
                          ),
                          const SizedBox(width: 48),
                          Expanded(child: _buildIllustration()),
                        ],
                      ),
                    SizedBox(height: isCompact ? 38 : 58),
                    _buildHighlights(isCompact),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        'ระบบควบคุมแสงสว่างและติดตามสภาพแวดล้อมอัจฉริยะ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.mutedText.withValues(alpha: 0.82),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.amber500, AppColors.amber700],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber500.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.lightbulb_rounded,
            color: AppColors.amber100,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Classroom',
              style: TextStyle(
                color: AppColors.warmText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'LumiTrack IoT  ·  v1.0',
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          tooltip: 'เปลี่ยนธีม',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ThemeSettingsPage(
                  isLightMode: isLightTheme,
                  onThemeChanged: onThemeChanged,
                ),
              ),
            );
          },
          icon: Icon(
            isLightTheme ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: AppColors.amber400,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny_rounded, color: AppColors.amber400, size: 15),
              SizedBox(width: 6),
              Text(
                isLightTheme ? 'Warm light theme' : 'Warm dark theme',
                style: TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCopy(BuildContext context, bool isCompact) {
    return Column(
      crossAxisAlignment: isCompact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3DE),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEBD2A9)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: AppColors.amber400,
              ),
              SizedBox(width: 6),
              Text(
                isCompact
                    ? 'SMART CLASSROOM LIGHTING'
                    : 'SMART LIGHTING · BETTER CLASSROOM',
                style: TextStyle(
                  color: AppColors.amber800,
                  fontSize: isCompact ? 8 : 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: isCompact ? 0.4 : 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'แสงที่พอดี\nเพื่อห้องเรียนที่ดีกว่า',
          textAlign: isCompact ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: AppColors.warmText,
            fontSize: isCompact ? 36 : 52,
            height: 1.18,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'ควบคุมโคมไฟอัจฉริยะ พร้อมติดตามอุณหภูมิ ความชื้น และแสงภายในห้องได้จากที่เดียว',
          textAlign: isCompact ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: AppColors.mutedText,
            height: 1.7,
            fontSize: isCompact ? 14 : 15,
          ),
        ),
        const SizedBox(height: 26),
        FilledButton.icon(
          onPressed: () => _start(context),
          icon: const Icon(Icons.arrow_forward_rounded, size: 19),
          label: const Text(
            'เริ่มต้นการใช้งาน',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.amber500,
            foregroundColor: const Color(0xFF34291F),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
            elevation: 4,
            shadowColor: AppColors.amber500.withValues(alpha: 0.32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 13),
        Row(
          mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 13,
              color: AppColors.emeraldLight,
            ),
            const SizedBox(width: 6),
            Text(
              isCompact
                  ? 'เรียลไทม์ · เชื่อมต่อ ESP32'
                  : 'แดชบอร์ดเรียลไทม์ · เชื่อมต่อ ESP32',
              style: TextStyle(color: AppColors.mutedText, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460, minHeight: 310),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF63471F).withValues(alpha: 0.08),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: _floatingMetric(
              Icons.thermostat_rounded,
              '24.2°C',
              'อุณหภูมิ',
              AppColors.orange,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            child: _floatingMetric(
              Icons.water_drop_rounded,
              '56%',
              'ความชื้น',
              AppColors.sky,
            ),
          ),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.amber300.withValues(alpha: 0.2),
                  AppColors.amber500.withValues(alpha: 0.09),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2,
                height: 43,
                decoration: BoxDecoration(
                  color: AppColors.amber700.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 56,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.amber800,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
              ),
              Container(
                width: 134,
                height: 134,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.25, -0.35),
                    colors: [
                      Color(0xFFFFFBEF),
                      Color(0xFFFFD981),
                      Color(0xFFF59E0B),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFFF5B844), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber500.withValues(alpha: 0.38),
                      blurRadius: 42,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  size: 64,
                  color: AppColors.amber800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 100,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.amber500.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber500.withValues(alpha: 0.2),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 15,
            left: 4,
            child: _floatingMetric(
              Icons.wb_sunny_outlined,
              'AUTO',
              'โหมดทำงาน',
              AppColors.amber400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingMetric(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34291F).withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.warmText,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(color: AppColors.mutedText, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights(bool isCompact) {
    final items = [
      (
        Icons.lightbulb_outline_rounded,
        'ควบคุมไฟ',
        'ปรับโหมดและความสว่าง',
        AppColors.amber400,
      ),
      (
        Icons.sensors_rounded,
        'ดูข้อมูลเซ็นเซอร์',
        'อุณหภูมิ ความชื้น และแสง',
        AppColors.sky,
      ),
      (
        Icons.show_chart_rounded,
        'ติดตามแนวโน้ม',
        'ดูข้อมูลย้อนหลังแบบกราฟ',
        AppColors.emeraldLight,
      ),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return SizedBox(
          width: isCompact ? double.infinity : 280,
          child: _FeatureCard(
            icon: item.$1,
            title: item.$2,
            detail: item.$3,
            color: item.$4,
          ),
        );
      }).toList(),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.78),
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _dashboardIconBox(icon, color),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.warmText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: TextStyle(color: AppColors.mutedText, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _dashboardIconBox(IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 18, color: color),
  );
}
