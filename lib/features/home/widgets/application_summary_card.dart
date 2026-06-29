import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplicationSummaryCard extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final IconData icon;

  const ApplicationSummaryCard({
    super.key,
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Icon
          Container(
            width: 36.w,
              height: 36.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: color,
                size: 20.w,
            ),
          ),
          SizedBox(height: 12.h),

          // Count
          Text(
            count,
            style: AppTextStyles.displayMedium.copyWith(
              color: color,
              fontSize: 28,
            ),
          ),
          SizedBox(height: 4.h),

          // Label
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
