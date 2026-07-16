import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/application_model.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'under_review':
        return AppColors.warning;
      default:
        return AppColors.info;
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
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final application =
        ModalRoute.of(context)!.settings.arguments as ApplicationModel;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text('Application Details', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _getStatusColor(application.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _getStatusColor(application.status).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _getStatusLabel(application.status),
                    style: AppTextStyles.h2.copyWith(
                      color: _getStatusColor(application.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Application submitted to ${application.schoolName}',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // School Info
            _buildSection(
              title: 'School Information',
              children: [
                _buildDetailRow('School', application.schoolName),
                _buildDetailRow('Country', application.schoolCountry),
              ],
            ),

            SizedBox(height: 20.h),

            // Personal Details
            _buildSection(
              title: 'Personal Details',
              children: [
                _buildDetailRow('Full Name', application.fullName),
                _buildDetailRow('Date of Birth', application.dateOfBirth),
                _buildDetailRow('Gender', application.gender),
                _buildDetailRow('Nationality', application.nationality),
              ],
            ),

            SizedBox(height: 20.h),

            // Academic Details
            _buildSection(
              title: 'Academic Details',
              children: [
                _buildDetailRow('Qualification', application.qualification),
                _buildDetailRow('Grade/Result', application.grade),
                _buildDetailRow('Graduation Year', application.graduationYear),
              ],
            ),

            SizedBox(height: 20.h),

            // Programme Details
            _buildSection(
              title: 'Programme Details',
              children: [
                _buildDetailRow('Course of Study', application.courseOfStudy),
                _buildDetailRow('Entry Level', application.entryLevel),
                _buildDetailRow('Session', application.session),
              ],
            ),

            SizedBox(height: 20.h),

            // Submission Info
            _buildSection(
              title: 'Submission Information',
              children: [
                _buildDetailRow(
                  'Date Submitted',
                  application.createdAt != null
                      ? _formatDate(application.createdAt!)
                      : 'Recently',
                ),
                _buildDetailRow('Status', _getStatusLabel(application.status)),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h3,
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
