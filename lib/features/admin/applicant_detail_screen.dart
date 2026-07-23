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
    return const Placeholder();
  }
}

