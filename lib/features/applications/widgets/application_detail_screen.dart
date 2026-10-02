import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/application_model.dart';
import '../../../models/school_model.dart';
import '../../../providers/application_provider.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key});

  Color _getStatusColor(String status, AppPalette colors) {
    switch (status) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'under_review':
        return AppColors.warning;
      case 'more_documents':
        return AppColors.warning;
      case 'withdrawn':
        return colors.textSecondary;
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
      case 'more_documents':
        return 'More Documents Required';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final application =
        ModalRoute.of(context)!.settings.arguments as ApplicationModel;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: context.colors.textPrimary,
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
                color: _getStatusColor(application.status, context.colors).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _getStatusColor(application.status, context.colors).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _getStatusLabel(application.status),
                    style: AppTextStyles.h2.copyWith(
                      color: _getStatusColor(application.status, context.colors),
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
              context,
              title: 'School Information',
              children: [
                _buildDetailRow(context, 'School', application.schoolName),
                _buildDetailRow(context, 'Country', application.schoolCountry),
              ],
            ),

            SizedBox(height: 20.h),

            // Personal Details
            _buildSection(
              context,
              title: 'Personal Details',
              children: [
                _buildDetailRow(context, 'Full Name', application.fullName),
                _buildDetailRow(context, 'Date of Birth', application.dateOfBirth),
                _buildDetailRow(context, 'Gender', application.gender),
                _buildDetailRow(context, 'Nationality', application.nationality),
              ],
            ),

            SizedBox(height: 20.h),

            // Academic Details
            _buildSection(
              context,
              title: 'Academic Details',
              children: [
                _buildDetailRow(context, 'Qualification', application.qualification),
                _buildDetailRow(context, 'Grade/Result', application.grade),
                _buildDetailRow(context, 'Graduation Year', application.graduationYear),
              ],
            ),

            SizedBox(height: 20.h),

            // Programme Details
            _buildSection(
              context,
              title: 'Programme Details',
              children: [
                _buildDetailRow(context, 'Course of Study', application.courseOfStudy),
                _buildDetailRow(context, 'Entry Level', application.entryLevel),
                _buildDetailRow(context, 'Session', application.session),
              ],
            ),

            SizedBox(height: 20.h),

            // Submission Info
            _buildSection(
              context,
              title: 'Submission Information',
              children: [
                _buildDetailRow(
                  context,
                  'Date Submitted',
                  application.createdAt != null
                      ? _formatDate(application.createdAt!)
                      : 'Recently',
                ),
                _buildDetailRow(context, 'Status', _getStatusLabel(application.status)),
              ],
            ),
            SizedBox(height: 32.h),

            // Contextual actions based on status
            if (_canWithdraw(application.status)) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmWithdraw(context, application),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: BorderSide(color: AppColors.warning.withValues(alpha: 0.4)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  icon: Icon(Icons.do_not_disturb_on_outlined, size: 20.w),
                  label: const Text('Withdraw Application'),
                ),
              ),
              SizedBox(height: 12.h),
            ],

            if (application.status == 'withdrawn' ||
                application.status == 'rejected') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _reapply(context, application),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Re-apply'),
                ),
              ),
              SizedBox(height: 12.h),
            ],

            // Delete application
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, application),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                icon: Icon(Icons.delete_outline, size: 20.w),
                label: const Text('Delete Application'),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  bool _canWithdraw(String status) {
    return status == 'pending' ||
        status == 'under_review' ||
        status == 'more_documents';
  }

  void _reapply(BuildContext context, ApplicationModel application) {
    final school = SchoolModel(
      name: application.schoolName,
      country: application.schoolCountry,
      state: '',
      website: '',
    );
    Navigator.pushNamed(
      context,
      '/application-form',
      arguments: school,
    );
  }

  Future<void> _confirmWithdraw(
    BuildContext context,
    ApplicationModel application,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Withdraw Application', style: AppTextStyles.h2),
        content: Text(
          'Are you sure you want to withdraw your application to '
          '${application.schoolName}? You can re-apply later.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Withdraw',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final appId = application.id;
    if (appId == null) return;

    final success =
        await context.read<ApplicationProvider>().withdrawApplication(appId);

    if (!context.mounted) return;

    showToast(
      success
          ? 'Application withdrawn'
          : 'Failed to withdraw application',
      backgroundColor: success ? AppColors.warning : AppColors.error,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ApplicationModel application,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Delete Application', style: AppTextStyles.h2),
        content: Text(
          'Are you sure you want to delete your application to '
          '${application.schoolName}? This cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Delete',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final appId = application.id;
    if (appId == null) return;

    final success =
        await context.read<ApplicationProvider>().deleteApplication(appId);

    if (!context.mounted) return;

    if (success) {
      showToast(
        'Application deleted',
        backgroundColor: AppColors.success,
      );
      Navigator.pop(context);
    }
  }

  Widget _buildSection(
    BuildContext context, {
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
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
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
                color: context.colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.colors.textPrimary,
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
