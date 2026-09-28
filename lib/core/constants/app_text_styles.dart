import 'package:flutter/material.dart';

/// Type scale for the app.
///
/// These styles deliberately carry **no colour** — colour comes from the active
/// theme (see `AppTheme.textTheme`, which maps each style to the matching
/// `AppPalette` entry). That is what lets the same styles work in light and
/// dark mode.
///
/// To override a colour at a call site, use
/// `AppTextStyles.h2.copyWith(color: context.colors.textPrimary)`.
class AppTextStyles {
  AppTextStyles._();

  // Font Families

  static const String _heading = 'PlusJakartaSans';
  static const String _body = 'Inter';
  static const String _label = 'DMSans';

  // Display

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _heading,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _heading,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  // Headings

  static const TextStyle h1 = TextStyle(
    fontFamily: _heading,
    fontSize: 23,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _heading,
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _heading,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _body,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _body,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _body,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // Labels and Buttons

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _label,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _label,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _label,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.4,
  );

  static const TextStyle chip = TextStyle(
    fontFamily: _label,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // Hints and Captions

  static const TextStyle hint = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
  );
}
