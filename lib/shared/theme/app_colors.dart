import 'package:flutter/material.dart';

/// Palet warna konsisten dengan tema web (Tailwind Mint/Teal & Dark Brutal).
class AppColors {
  // Brand Primary (Teal Mint)
  static const Color primary = Color(0xFF14B8A6);
  static const Color primaryHover = Color(0xFF0D9488);
  static const Color primarySoft = Color(0xFFCCFBF1);
  static const Color primaryContrast = Color(0xFF06221F);

  // Secondary Accent (Warm Amber/Orange - khas Kasir POS)
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentOrangeSoft = Color(0xFFFFF7ED);

  // Background & Surface
  static const Color background = Color(0xFFF7FAF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color borderSoft = Color(0xFFE2E8F0);

  // Dark Brutal (Sidebar & Accent Text)
  static const Color darkBrutal = Color(0xFF0B1220);

  // Typography
  static const Color textInk = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Status Feedback
  static const Color success = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3C7);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0xFFDBEAFE);
}
