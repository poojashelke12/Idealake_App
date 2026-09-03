import 'package:flutter/material.dart';

/// Centralized Color Palette for Idealake & LTFS App
class AppColors {
  AppColors._();

  // Primary Brand Colors (LTFS / Idealake Blue Palette)
  static const Color primary = Color(0xFF00529B); // Classic LTFS Corporate Navy
  static const Color primaryDark = Color(0xFF00386B);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color primaryContainer = Color(0xFFE3F2FD);

  // Secondary & Accent Colors
  static const Color secondary = Color(0xFFF39200); // Vibrant Accent Gold/Orange
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFC66900);
  static const Color accent = Color(0xFF00A3E0); // Electric Cyan/Blue

  // Neutral Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E1);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // Shimmer / Placeholder Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00529B), Color(0xFF0077CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF00386B), Color(0xFF00529B), Color(0xFF0077CC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF39200), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
