import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/application_model.dart';

class ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onTap;


  const ApplicationCard({
    super.key,
  required this.application,
  required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted': return 'Accepted';
      case 'rejected': return 'Rejected';
      case 'under_review': return 'Under Review';
      default:
        return 'Pending';
    }
  }

  String _getStatusLabel (String status) {
    switch (status) {
      case 'accepted': return 'Accepted';
      case 'rejected': return 'Rejected';
      case 'under_review': return 'Under Review';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
