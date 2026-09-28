import 'package:flutter/material.dart';

import 'app_palette.dart';

/// The two colour palettes used by the app.
///
/// The `static const` fields are the light palette and remain the source of
/// truth for the brand colours. Prefer `context.colors.*` in widgets so the
/// value follows the active light/dark theme; the bare constants are kept for
/// the handful of places that genuinely need a fixed colour (e.g. the
/// notification icon on a coloured splash screen).
class AppColors {
  AppColors._();

  // Primary

  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryLight = Color(0xFF818CF8); // Light Indigo
  static const Color primaryDark = Color(0xFF3730A3); // Dark Indigo

  // Background

  static const Color background = Color(0xFFFFFFFF); // Pure white
  static const Color surface = Color(0xFFF9FAFB); // off_white cards
  static const Color surfaceAlt = Color(0xFFEEF2FF); // Indigo tint (chips, tags)

  // Text

  static const Color textPrimary = Color(0xFF111827); // Almost black
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textHint = Color(0xFF9CA3AF); // Light gray

  // Status

  static const Color success = Color(0xFF10B981); // Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Orange
  static const Color info = Color(0xFF3B82F6); // Blue

  // Border and Divider

  static const Color border = Color(0xFFE5E7EB); // Light gray
  static const Color divider = Color(0xFFF3F4F6); // Slightly darker gray

  /// Light palette — the constants above.
  static const AppPalette light = AppPalette(
    primary: primary,
    primaryLight: primaryLight,
    primaryDark: primaryDark,
    background: background,
    surface: surface,
    surfaceAlt: surfaceAlt,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textHint: textHint,
    success: success,
    error: error,
    warning: warning,
    info: info,
    border: border,
    divider: divider,
    onPrimary: background,
  );

  /// Dark palette. The brand indigo is lightened for contrast on a dark
  /// surface, and the status colours are tinted to stay legible.
  static const AppPalette dark = AppPalette(
    primary: Color(0xFF818CF8),
    primaryLight: Color(0xFFA5B4FC),
    primaryDark: Color(0xFF4F46E5),
    background: Color(0xFF0F1117),
    surface: Color(0xFF171A21),
    surfaceAlt: Color(0xFF1E2230),
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFF9CA3AF),
    textHint: Color(0xFF6B7280),
    success: Color(0xFF34D399),
    error: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF60A5FA),
    border: Color(0xFF272B36),
    divider: Color(0xFF1F232C),
    onPrimary: Color(0xFF0F1117),
  );
}
