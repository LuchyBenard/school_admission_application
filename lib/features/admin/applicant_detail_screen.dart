import 'dart:convert';
import 'dart:typed_data';

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

  // Uploaded documents (base64) keyed by the same docKeys used by the
  // student's DocumentUploadScreen.
  final Map<String, Map<String, dynamic>> _documentMeta = {
    'waec_neco': {
      'title': 'WAEC/NECO Result',
      'icon': Icons.school_outlined,
    },
    'jamb_result': {
      'title': 'JAMB Result',
      'icon': Icons.assignment_outlined,
    },
    'passport_photo': {
      'title': 'Passport Photo',
      'icon': Icons.person_outline,
    },
    'birth_certificate': {
      'title': 'Birth Certificate',
      'icon': Icons.card_membership_outlined,
    },
  };
  final Map<String, String> _documentImages = {};
  bool _documentsLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _application =
    ModalRoute.of(context)!.settings.arguments as ApplicationModel;
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final appId = _application.id;
    if (appId == null) {
      if (mounted) setState(() => _documentsLoading = false);
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('applications')
          .doc(appId)
          .collection('documents')
          .get();

      if (!mounted) return;
      setState(() {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final key = data['docKey']?.toString() ?? doc.id;
          final base64 = data['data'];
          if (base64 != null && base64 is String && base64.isNotEmpty) {
            _documentImages[key] = base64;
          }
        }
        _documentsLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _documentsLoading = false);
    }
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
      // Update application status in firestore
      await _firestore.collection('applications').doc(_application.id).update({
        'status': status,
        'adminMessage': _messageController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // send notification to student
      await _firestore.collection('notifications').add({
        'userId': _application.userId,
        'title': _getNotificationTitle(status),
        'message': _messageController.text.trim().isNotEmpty
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
      if (mounted) {
        showToast(
          'Failed to update application. Please try again.',
          backgroundColor: AppColors.error,
          textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        );
      }
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
    _messageController.clear();
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
              decoration: const InputDecoration(
                hintText: 'Type a message...',
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
          child: const Icon(
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
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _application.fullName.isNotEmpty
                          ? _application.fullName
                          .trim()
                          .split(' ')
                          .take(2)
                          .map((e) => e[0])
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
              _buildRow('Graduation Year', _application.graduationYear),
            ]),

            SizedBox(height: 16.h),

            _buildSection('Programme Details', [
              _buildRow('Course of Study', _application.courseOfStudy),
              _buildRow('Entry Level', _application.entryLevel),
              _buildRow('Session', _application.session),
            ]),

            SizedBox(height: 16.h),

            _buildSection('Uploaded Documents', _buildDocumentRows()),

            SizedBox(height: 32.h),

            // Action Buttons
            if (_application.status == 'withdrawn') ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.do_not_disturb_on_outlined,
                      color: AppColors.textSecondary,
                      size: 22.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'This applicant has withdrawn their application.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (!_isLoading) ...[
              Text('Take Action', style: AppTextStyles.h3),
              SizedBox(height: 16.h),

              // Accept
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showActionDialog(
                    'accepted',
                    'Accept Application',
                    AppColors.success,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  icon: const Icon(Icons.check_circle_outlined),
                  label: const Text('Accept Application'),
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
                  icon: const Icon(Icons.folder_outlined),
                  label: const Text('Request More Documents'),
                ),
              ),

              SizedBox(height: 12.h),

              // Mark under review
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showActionDialog(
                    'under_review',
                    'Mark Under Review',
                    AppColors.info,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                  ),
                  icon: const Icon(Icons.hourglass_empty_outlined),
                  label: const Text('Mark as Under Review'),
                ),
              ),

              SizedBox(height: 12.h),

              // Reject
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showActionDialog(
                    'rejected',
                    'Reject Application',
                    AppColors.error,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Reject Application'),
                ),
              ),
            ] else
              const Center(
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

  List<Widget> _buildDocumentRows() {
    if (_documentsLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      ];
    }

    if (_documentImages.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'No documents uploaded for this application yet.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ];
    }

    return [
      Text(
        '${_documentImages.length} of ${_documentMeta.length} documents uploaded',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 8),
      ..._documentMeta.entries.map((entry) {
        final key = entry.key;
        final title = entry.value['title'] as String;
        final icon = entry.value['icon'] as IconData;
        final base64 = _documentImages[key];
        final hasImage = base64 != null && base64.isNotEmpty;

        return InkWell(
          onTap: hasImage ? () => _viewDocument(title, base64) : null,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: hasImage
                        ? AppColors.surfaceAlt
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.memory(
                            _decodeBase64(base64)!,
                            fit: BoxFit.cover,
                            width: 44.w,
                            height: 44.w,
                            errorBuilder: (_, _, _) => Icon(
                              icon,
                              color: AppColors.textHint,
                              size: 22.w,
                            ),
                          ),
                        )
                      : Icon(icon, color: AppColors.textHint, size: 22.w),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (hasImage)
                  Row(
                    children: [
                      Text(
                        'View',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.zoom_in,
                        color: AppColors.primary,
                        size: 16.w,
                      ),
                    ],
                  )
                else
                  Text(
                    'Not uploaded',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    ];
  }

  Uint8List? _decodeBase64(String base64) {
    try {
      return base64Decode(base64);
    } catch (_) {
      return null;
    }
  }

  void _viewDocument(String title, String base64) {
    final bytes = _decodeBase64(base64);
    if (bytes == null) {
      showToast(
        'Could not read this document.',
        backgroundColor: AppColors.error,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.h2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20.w,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                color: AppColors.surface,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
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
      padding: EdgeInsets.symmetric(vertical: 8.h),
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

