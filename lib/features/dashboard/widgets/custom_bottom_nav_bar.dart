import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_palette.dart';
import '../../../l10n/generated/app_localizations.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                outlineIcon: Icons.home_outlined,
                filledIcon: Icons.home,
                label: l10n.navHome,
              ),
              _buildNavItem(
                context,
                index: 1,
                outlineIcon: Icons.school_outlined,
                filledIcon: Icons.school,
                label: l10n.navSchools,
              ),
              _buildNavItem(
                context,
                index: 2,
                outlineIcon: Icons.assignment_outlined,
                filledIcon: Icons.assignment,
                label: l10n.navApplications,
              ),
              _buildNavItem(
                context,
                index: 3,
                outlineIcon: Icons.person_outline,
                filledIcon: Icons.person,
                label: l10n.navProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData outlineIcon,
    required IconData filledIcon,
    required String label,
  }) {
    final bool isActive = currentIndex == index;
    final color =
        isActive ? context.colors.primary : context.colors.textHint;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? filledIcon : outlineIcon,
            color: color,
            size: 24.w,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}