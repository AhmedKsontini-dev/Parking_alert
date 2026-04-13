import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  App Colors
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppColors {
  static const primary      = Color(0xFF1565C0);
  static const primaryLight = Color(0xFF42A5F5);
  static const accent       = Color(0xFF0288D1);
  static const accentLight  = Color(0xFF64B5F6); // used in intro pills
  static const bg           = Color(0xFFF0F4FF);
  static const cardBg       = Colors.white;
  static const textDark     = Color(0xFF1A237E);
  static const textMuted    = Color(0xFF78909C);
  static const inputFill    = Color(0xFFF5F8FF);
  static const border       = Color(0xFFDDE3F0);
  static const error        = Color(0xFFEF5350);

  // Intro gradient
  static const gradientTop    = Color(0xFF0D47A1);
  static const gradientBottom = Color(0xFF1976D2);
}

// ─────────────────────────────────────────────────────────────────────────────
//  App Shadows
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withAlpha(15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> button = [
    BoxShadow(
      color: AppColors.primary.withAlpha(102),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> chip = [
    BoxShadow(
      color: Colors.black.withAlpha(10),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> icon = [
    BoxShadow(
      color: AppColors.primary.withAlpha(77),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
