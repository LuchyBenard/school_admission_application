import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Semantic colour set for a brightness, exposed as a [ThemeExtension] so
/// widgets resolve colours from the active theme instead of hardcoding them.
///
/// Reach it with `context.colors` (see [AppColorsX]). The light values live in
/// `AppColors.light`, the dark values in `AppColors.dark`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;

  /// Screen background. Also used as the "ink on primary" colour in light mode.
  final Color background;

  /// Cards, sheets, input fields.
  final Color surface;

  /// Chips, tags, tinted highlights.
  final Color surfaceAlt;

  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  final Color border;
  final Color divider;

  /// Foreground colour for text/icons sitting on [primary] (e.g. buttons).
  final Color onPrimary;

  const AppPalette({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.border,
    required this.divider,
    required this.onPrimary,
  });

  @override
  AppPalette copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    Color? border,
    Color? divider,
    Color? onPrimary,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      onPrimary: onPrimary ?? this.onPrimary,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  /// The [AppPalette] for the active theme.
  ///
  /// Falls back to the light palette so widgets still render (in light mode)
  /// if they are pumped outside a `MaterialApp` carrying the extension.
  AppPalette get colors =>
      Theme.of(this).extension<AppPalette>() ?? AppColors.light;
}
