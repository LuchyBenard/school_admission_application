import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  
  const StatusBadge({
    super.key,
    required this.status,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'under_review':
        return AppColors.warning;
      case 'more_documents':
        return AppColors.info;
      default:
        return AppColors.textHint;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'under_review':
        return 'Under Review';
      case 'more_documents':
        return 'Docs Needed';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _getStatusLabel(status),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
