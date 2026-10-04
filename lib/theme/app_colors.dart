import 'package:flutter/material.dart';

class AppColors {
  static bool lightMode = true;

  static Color get bgDark =>
      lightMode ? const Color(0xFFF2EEE7) : const Color(0xFF141210);
  static Color get card =>
      lightMode ? const Color(0xFFFFFFFF) : const Color(0xFF1D1916);
  static Color get cardBorder =>
      lightMode ? const Color(0xFFDED1C1) : const Color(0xFF3A2F25);
  static Color get cardHover =>
      lightMode ? const Color(0xFFF7F1E8) : const Color(0xFF26211C);
  static Color get innerCard =>
      lightMode ? const Color(0xFFF5EFE6) : const Color(0xFF161311);
  static Color get innerBorder =>
      lightMode ? const Color(0xFFE4D8C9) : const Color(0xFF2D231B);
  static Color get terminalBg =>
      lightMode ? const Color(0xFFFFFCF7) : const Color(0xFF0E1318);
  static Color get terminalBorder =>
      lightMode ? const Color(0xFFDED1C1) : const Color(0xFF202933);

  // Amber Warm Palette
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static Color get amber300 =>
      lightMode ? const Color(0xFFA45A12) : const Color(0xFFFCD34D);
  static Color get amber400 =>
      lightMode ? const Color(0xFF8A4B08) : const Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);
  static Color get amber950 =>
      lightMode ? const Color(0xFFFFF3DE) : const Color(0xFF37180D);

  // Text
  static Color get warmText =>
      lightMode ? const Color(0xFF34291F) : const Color(0xFFF5EDE4);
  static Color get mutedText =>
      lightMode ? const Color(0xFF66574A) : const Color(0xFF9E8E80);
  static Color get dimText =>
      lightMode ? const Color(0xFF857769) : const Color(0xFF786C62);

  // Status accents
  static const Color emerald = Color(0xFF10B981);
  static Color get emeraldLight =>
      lightMode ? const Color(0xFF17633E) : const Color(0xFF34D399);
  static Color get emerald950 =>
      lightMode ? const Color(0xFFE8F5EC) : const Color(0xFF064E3B);
  static Color get cyan =>
      lightMode ? const Color(0xFF087E8B) : const Color(0xFF06B6D4);
  static Color get sky =>
      lightMode ? const Color(0xFF075985) : const Color(0xFF38BDF8);
  static Color get orange =>
      lightMode ? const Color(0xFFA23B1A) : const Color(0xFFF97316);
  static Color get red =>
      lightMode ? const Color(0xFFB42318) : const Color(0xFFEF4444);
}
