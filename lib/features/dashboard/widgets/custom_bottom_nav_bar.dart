import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                index: 0,
                outlineIcon: Icons.home_outlined,
                filledIcon: Icons.home,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                outlineIcon: Icons.school_outlined,
                filledIcon: Icons.school,
                label: 'Schools',
              ),
              _buildNavItem(
                index: 2,
                outlineIcon: Icons.assignment_outlined,
                filledIcon: Icons.assignment,
                label: 'Applications',
              ),
              _buildNavItem(
                index: 3,
                outlineIcon: Icons.person_outline,
                filledIcon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData outlineIcon,
    required IconData filledIcon,
    required String label,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? filledIcon : outlineIcon,
            color: isActive ? AppColors.primary : AppColors.textHint,
            size: 24.w,
          ),
          SizedBox(height: 4.h),

          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppColors.primary : AppColors.textHint,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
