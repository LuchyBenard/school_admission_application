import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_admission_application/core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
  required this.status,
  });

  Color _getColor() {
    switch (status) {
      case 'accepted': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'under_review': return AppColors.warning;
      case 'more_docs': return AppColors.info;
      case 'pending': return AppColors.textHint ;
      default: return AppColors.textHint;
    }
  }

  String _getLabel() {
    switch (status) {
      case 'accepted': return 'Accepted';
      case 'rejected': return 'Rejected';
      case 'under_review': return 'Under Review';
      case 'more_docs': return 'Docs Needed';
      case 'pending': return 'Pending';
      default: return 'Unknown';
    }
  }

  IconData _getIcon () {
    switch (status) {
      case 'accepted': return Icons.check_circle_outline;
      case 'rejected': return Icons.cancel_outlined;
      case 'under_review': return Icons.hourglass_empty_outlined;
      case 'more_docs': return Icons.folder_outlined;
      case 'pending': return Icons.access_time_outlined;
      default: return Icons.help_outline;
    }
  }
  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 12.w,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            _getLabel(),
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
