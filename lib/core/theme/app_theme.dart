import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'app_palette.dart';

/// Light and dark [ThemeData] for the app.
///
/// Both are built from an [AppPalette] so the two modes cannot drift apart —
/// every colour in a widget comes from the palette carried in
/// `ThemeData.extensions`.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.surfaceAlt,
      onPrimaryContainer: palette.textPrimary,
      secondary: palette.primaryLight,
      onSecondary: palette.onPrimary,
      error: palette.error,
      onError: brightness == Brightness.light ? Colors.white : palette.background,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.border,
      outlineVariant: palette.divider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      // Lets `AppTextStyles.X` resolve to the right colour without hardcoding
      // one: a Text with one of these styles inherits its colour from the
      // enclosing DefaultTextStyle, which Material builds from this theme.
      textTheme: _textTheme(palette),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h2.copyWith(color: palette.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: palette.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        hintStyle: AppTextStyles.hint.copyWith(color: palette.textHint),
        labelStyle: AppTextStyles.label.copyWith(color: palette.textSecondary),
        prefixIconColor: palette.textHint,
        suffixIconColor: palette.textHint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: _inputBorder(palette.border),
        enabledBorder: _inputBorder(palette.border),
        focusedBorder: _inputBorder(palette.primary, width: 1.5),
        errorBorder: _inputBorder(palette.error),
        focusedErrorBorder: _inputBorder(palette.error, width: 1.5),
      ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium
            .copyWith(color: palette.background),
        actionTextColor: palette.primary,
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.onPrimary
              : palette.textHint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.primary
              : palette.surfaceAlt,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.primary),
      extensions: <ThemeExtension<dynamic>>[palette],
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// Maps the app's type scale onto the Material text theme, applying the
  /// palette colours. Without this, a `Text` using an `AppTextStyles` constant
  /// would inherit Material's default (near-black) colour in dark mode.
  static TextTheme _textTheme(AppPalette palette) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge
          .copyWith(color: palette.textPrimary),
      displayMedium: AppTextStyles.displayMedium
          .copyWith(color: palette.textPrimary),
      headlineLarge: AppTextStyles.h1.copyWith(color: palette.textPrimary),
      headlineMedium: AppTextStyles.h2.copyWith(color: palette.textPrimary),
      headlineSmall: AppTextStyles.h3.copyWith(color: palette.textPrimary),
      titleLarge: AppTextStyles.h2.copyWith(color: palette.textPrimary),
      titleMedium: AppTextStyles.h3.copyWith(color: palette.textPrimary),
      titleSmall: AppTextStyles.label.copyWith(color: palette.textSecondary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: palette.textPrimary),
      bodyMedium: AppTextStyles.bodyMedium
          .copyWith(color: palette.textSecondary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: palette.textSecondary),
      labelLarge: AppTextStyles.buttonLarge.copyWith(color: palette.onPrimary),
      labelMedium: AppTextStyles.label.copyWith(color: palette.textSecondary),
      labelSmall: AppTextStyles.caption.copyWith(color: palette.textHint),
    );
  }
}
