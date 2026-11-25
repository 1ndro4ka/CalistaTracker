import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceElevated = Color(0xFF1C1C1E);
  static const Color surfaceMuted = Color(0xFF222225);

  // Borders & Dividers (Hairline 0.5 - 1.0 px)
  static const Color border = Color(0xFF27272A);
  static const Color borderSubtle = Color(0xFF1C1C1F);
  static const Color borderHighlight = Color(0xFF3F3F46);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFF4F4F5);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
  static const Color textDisabled = Color(0xFF52525B);

  // Monochromatic Accent
  static const Color accent = Color(0xFFF4F4F5);
  static const Color accentSubtle = Color(0xFF27272A);

  // Status & Feature Badges
  static const Color freezeActive = Color(0xFFE4E4E7);
  static const Color freezeBackground = Color(0xFF1F2428);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSubtle = Color(0xFF2B1212);
}
