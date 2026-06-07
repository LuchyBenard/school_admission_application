import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Font Families

  static const String _heading = 'PlusJakartaSans';
  static const String _body = 'Inter';
  static const String _label = 'DMSans';

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _heading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _heading,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Headings

  static const TextStyle h1 = TextStyle(
    fontFamily: _heading,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _heading,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _heading,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Labels and Buttons

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _label,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.background,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _label,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.background,
    height: 1.2,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _label,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
    letterSpacing: 0.4,
  );

  static const TextStyle chip = TextStyle(
    fontFamily: _label,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.2,
  );

  // Hints and Captions

  static const TextStyle hint = TextStyle(
    fontFamily: _body,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _body,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.4,
    letterSpacing: 0.2,
  );
}
