import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oktoast/oktoast.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/application_model.dart';

class ApplicantDetailScreen extends StatefulWidget {
  const ApplicantDetailScreen({super.key});

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  late ApplicationModel _application;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _application = ModalRoute.of(context) !.settings.arguments as ApplicationModel;
  }
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status) async {
    if (_application.id == null) return;

    setState(() => _isLoading = true);
    try {
      // Update application ststua in firestore
      await _firestore
          .collection('applications')
          .doc(_application.id)
          .update({
        'status': status,
        'adminMessage': _messageController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // send notification to student
      await _firestore.collection('notification').add({
        'userId': _application.userId,
        'title': _getNotificationTitle(status),
        'message': _messageController.text
            .trim()
            .isNotEmpty
            ? _messageController.text.trim()
            : _getDefaultMessage(status),
        'type': status,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;

      showToast(
        'Application ${_getStatusLabel(status)} successfully!',
        backgroundColor: AppColors.success,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      Navigator.pop(context);
    } catch (e) {
      showToast(
        'Failed to update application. Please try again.',
        backgroundColor: AppColors.error,
        textStyle:
        AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _getNotificationTitle(String status) {
    switch (status) {
      case 'accepted':
        return '🎉 Application Accepted!';
      case 'rejected':
        return '❌ Application Rejected';
      case 'more_documents':
        return '📄 More Documents Required';
      case 'under_review':
        return '⏳ Application Under Review';
      default:
        return 'Application Update';
    }
  }

  String _getDefaultMessage(String status) {
    switch (status) {
      case 'accepted':
        return 'Congratulations! Your application to ${_application.schoolName} has been accepted.';
      case 'rejected':
        return 'We regret to inform you that your application to ${_application.schoolName} was not successful.';
      case 'more_documents':
        return 'Please submit additional documents for your application to ${_application.schoolName}.';
      case 'under_review':
        return 'Your application to ${_application.schoolName} is currently under review.';
      default:
        return 'Your application status has been updated.';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'more_documents':
        return 'Documents Requested';
      case 'under_review':
        return 'Marked Under Review';
      default:
        return 'Updated';
    }
  }

  void _showActionDialog(String status, String title, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(title, style: AppTextStyles.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add an optional message to the student:',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTextStyles.hint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(status);
            },
            child: Text(
              'Confirm',
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text('Applicant Details', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Applicant header
          Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
          child: Center(
            child: Text(
              _application.fullName.isNotEmpty
                  ? _application.fullName
                  .trim()
                  .split(' ')
                  .map((e) => e[0])
                  .take(2)
                  .join()
                  .toUpperCase()
                  : 'NA',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.background,
              ),
            ),
          ),
          ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _application.fullName,
                style: AppTextStyles.h2,
              ),
          Text(
            _application.courseOfStudy,
            style: AppTextStyles.bodyMedium,
          ),
          Text(
            _application.schoolName,
            style: AppTextStyles.bodyMedium,
          ),
          ],
          ),
        ),
        ],
          ),

      SizedBox(height: 24.h),

      // Details Section
      _buildSection('Personal Details', [
        _buildRow('Full Name', _application.fullName),
        _buildRow('Date of Birth', _application.dateOfBirth),
        _buildRow('Gender', _application.gender),
        _buildRow('Nationality', _application.nationality),
      ]),

        SizedBox(height: 16.h),

        _buildSection('Academic Details', [
          _buildRow('Qualification', _application.qualification),
          _buildRow('Grade', _application.grade),
          _buildRow('Graduation Year',
              _application.graduationYear),
        ]),

        SizedBox(height: 16.h),

        _buildSection('Programme Details', [
          _buildRow(
              'Course of Study', _application.courseOfStudy),
          _buildRow('Entry Level', _application.entryLevel),
          _buildRow('Session', _application.session),
        ]),

        SizedBox(height: 32.h)

        // Action Buttons
      if (!_isLoading) ...[
        Text('Take Action', style: AppTextStyles.h3),
        SizedBox(height: 16.h),

    // Accept
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: () => _showActionDialog(
    'accepted',
    'Accept Application',
    AppColors.success,
    ),
    style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.success,
    ),
    icon: Icon(Icons.check_circle_outlined),
    label: Text('Accept Application'),
    ),
    ),

    SizedBox(height: 12.h),

    // Request more documents
    SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
    onPressed: () => _showActionDialog(
    'more_documents',
    'Request More Documents',
    AppColors.warning,
    ),
    style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.warning,
    ),
    icon: Icon(Icons.folder_outlined),
    label: Text('Request More Documents'),
    ),
    ),

    SizedBox(height: 12.h),

    // Mark under review
    SizedBox(
    width: double.infinity
    child: ElevatedButton.icon(
    onPressed: () => _showActionDialog(
    'under_review',
    'Mark Under Review',
    AppColors.info,
    ),
    style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.info,
    ),
    icon: Icon(Icons.hourglass_empty_outlined),
    label: Text('Mark as Under Review'),
    ),
    ),

    SizedBox(height: 12.h),

    // Reject
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: () => _showActionDialog(
    'rejected',
    'Reject Application',
    AppColors.error,
    ),
    style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    ),
    icon: Icon(Icons.cancel_outlined),
    label: Text('Reject Application'),
    ),
    ),
    ] else
      Center(
    child: CircularProgressIndicator(
    color: AppColors.primary,
    ),
    ),

    SizedBox(height: 40.h),
    ],
    ),
    ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: rows,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(verticaal: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
          width: 130.w,
          child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textHint,
          ),
          ),
          ),
          SizedBox(width: 8.w),
          Expanded(
          child: Text(
          value.isNotEmpty ? value : '_',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
          ),
          ),
      ],
      ),
    );
  }
}

