import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Track Upload state per document
  final Map<String, File?> _selectedFiles = {
    'waec_neco': null,
    'jamb_result': null,
    'passport_photo': null,
    'birth_certificate': null,
  };

  final Map<String, bool> _uploading = {
    'waec_neco': false,
    'jamb_result': false,
    'passport_photo': false,
    'birth_certificate': false,
  };

  final Map<String, String> _uploadedUrls = {
    'waec_neco': null,
    'jamb_result': null,
    'passport_photo': null,
    'birth_certificate': null,
  };

  bool _isSubmitting = false;
  String? _applicationId;

  // Document display names
  final Map<String, String> _documentNames = {
    'waec_neco': {
      'title': 'WAEC/NECO Result',
      'subtitle': 'Upload your O-level result',
      'icon': Icons.school_outlined,
      'required': true,
    },
    'jamb_result': {
      'title': 'JAMB Result',
      'subtitle': 'Upload your JAMB result slip',
      'icon': Icons.assignment_outlined,
      'required': true,
    },
    'passport_photo': {
      'title': 'Passport Photo',
      'subtitle': 'Upload a recent passport-sized photo',
      'icon': Icons.person_outline,
      'required': true,
    },
    'birth_certificate': {
      'title': 'Birth Certificate',
      'subtitle': 'Upload your birth certificate',
      'icon': Icons.card_membership_outlined,
      'required': true,
    },
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      _applicationId = args as String;
    }
    }

    Future<void> _pickFile(String dockey) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imagequality: 80,
      );

      if (file != null) {
        setState(() {
          _selectedFiles[dockey] = File(file.path);
        });

        // Auto upload when file is picked
        await _uploadFile(dockey);
      }
    } catch (e) {
      showToast(
        'Failed to pick file. Please try again.',
        backgroundColor: AppColors.error,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
    }
    }

    Future<void> _uploadFile(String dockey) async {
    final file = _selectedFiles[dockey];
    if (file == null) return;

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _uploading[dockey] = true);
  }

  try {
  // Uplpoad to Firebase Storage
  final ref = _storage.ref().child(
  'documents/$uid/$dockey/${DateTime.now().millisecondsSinceEpoch}.jpg',
  );

  await ref.putFile(file);
  final url = await ref.getDownloadURL();

  setState(() {
  _uploadedUrls[dockey] = url;
  _uploading[dockey] = false;
  });

  showToast(
  '${_documents[dockey]!['title']} uploaded successfully',
  backgroundColor: AppColors.success,
  textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
  );
  } catch (e) {
  setState(() => _uploading[dockey] = false);
  showToast(
  'Upload failed. Please try again',
  backgroundColor: AppColors.error,
  textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
  );
  }
}

bool get _allRequiredUploaded {
  return _documents.entries
      .where((e) => e.value['required']== true)
      .every((e) => _uploadedUrls[e.key] != null);
}

void _proceed() async {
  if (!_allRequiredUploaded) {
    showToast(
      'Please upload all required documents before proceeding.',
      backgroundColor: AppColors.error,
      textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
    );
    return;
  }
  setState(() => _isSubmitting = true);

  try {
    // Save document URLs to Firestore
    if (_applicationId != null) {
      await _firestore
          .collection('applications')
          .doc(_applicationId)
          .update({
        'documents': _uploadedUrls,
        'documentsUploaded': true,
      });
    }

    if (!mounted) return;

    // Navigate to payment screen
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: _applicationId,
    );
  } catch (e) {
    showToast(
      'Something went wrong. Please try again.',
      backgroundColor: AppColors.error,
      textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
    );
  }
  if (mounted) setState(() => _isSubmitting = false);
}
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
        title: Text(
          'Document Upload',
          style: AppTextStyles.h2,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'All documents must be clear and readable. Accepted formats: JPG, PNG.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Required Documents',
                style: AppTextStyles.h2,
              ),
              SizedBox(height: 4.h),
              Text(
                'Upload all 4 documents to proceed',
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 20.h),

              // document tiles
              ..._documents.entries.map((entry) {
    final key = entry.key;
    final doc = entry.value;
    final isUploaded = _uploadedUrls[key] != null;
    final isUploading = _uploading[key] == true;
    final hasFile = _selectedFiles[key] != null;

    return Container(
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
    color: isUploaded
    ? AppColors.success.withValues(alpha: 0.05),
        : AppColors.background,
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(
    color: isUploaded
    ? AppColors.success.withValues(alpha: 0.4)
        : AppColors.border,
    ),
    ),

    child: Row(
    children: [
    // Doc icon
    Container(
    width: 48.w,
    height: 48.w,
    decoration: BoxDecoration(
    color: isUploaded
    ? AppColors.primary.withValues(alpha: 0.1)
        : AppColors.surfaceAlt,
    borderRadius: BorderRadius.circular(12.r),
    ),
    Child: Icon(
    isUploaded
    ? Icons.check_circle_outline
        : doc['icon'] as IconData,
    color: isUploaded
    ? AppColors.success
        : AppColors.primary,
    size: 24.w,
    ),
    ),

    SizedBox(width: 12.w),

    // Title and subtitle
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    children: [
    Text(
    doc['title'] as String,
    style: AppTextStyles.bodyMedium.copyWith(
    fontWeight: FontWeight.w600
    color: AppColors.textPrimary,
    ),
    ),
    SizedBox(width: 4.w),
    Text('*', style: AppTextStyles.bodyMedium.copyWith(
    color: AppColors.error,
    ),
    ),
    ],
    ),
    SizedBox(height: 2.h),
    Text(
    isUploaded
    ? 'upload successfully'
        : doc['subtitle'] as string,
    style: AppTextStyles.bodySmall.copyWith(
    color: isUploaded
    ? AppColors.success
        : AppColors.textHint,
    ),
    ),
    ],
    ),
    ),

    SizedBox(width: 8.w),

    // Upload button or loading
    if (isUploading)
    SizedBox(
    width: 24.w,
    height: 24.w,
    child: CircularProgressIndicator(
    color: AppColors.primary,
    strokeWidth: 2.w,
    ),
    )
    else
    GestureDetector(
    onTap: () => _pickFile(key),
    child: Container(
    padding: EdgeInsets.symmetric(
    horizontal: 12.w,
    vertical: 6.h,
    ),
    decoration: BoxDecoration(
    color: isUploaded
    ? AppColors.surface
        : AppColors.primary,
    borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(
    isUploaded ? 'Replace' : 'Upload',
    style: AppTextStyles.caption.copyWith(
    color: isUploaded
    ? AppColors.textSecondary
        : AppColors.background,
    fontWeight: FontWeight.w600,
    ),
    )
    ),
    ),
    ],
    ),
    );
    }),

      SizedBox(height: 16.h),

    // Progress Indicator
    Row(
    children: [
      Text(
    '${_uploadedUrls.values.where((v) => v != null).length} of ${_documents.length} uploaded',
    style: AppTextStyles.bodySmall.copyWith(
    color: AppColors.textSecondary,
    ),
    ),
    const Spacer(
    Text(
    _allRequiredUploaded
    ? 'All Done
        : 'Required: all 4',
    style: AppTextStyles.bodySmall.copyWith(
    color: _allRequiredUploaded ? AppColors.success : AppColors.textHint,
    fontWeight: FontWeight.w600,
    ),
    ),
    ],
    ),

    SizedBox(height: 8.h),

    // Progress AppBar
    ClipRRect(
    borderRadius: BorderRadius.circular(4.r),
    child: LinearProgressIndicator(
    value: _uploadedUrls.values
        .where((v) => v != null)
    .length /
    _documents.length,
    backgroundColor: AppColors.border,
    valueColor: AlwaysStoppedAnimation<Color>(
    _allRequiredUploaded
    ? AppColors.success
        : AppColors.primary,
    ),
    minHeight: 6,
    ),
    ),

    SizedBox(height: 32.h),

    // Proceed Button
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: (_allRequiredUploaded && !_isSubmitting),
    ? proceed
    : null,
    child: _isSubmitting
    ? SizedBox(
    width: 20.w,
    height: 20.w,
    child: CircularProgressIndicator(
    color:  AppColors.background,
    strokeWidth: 2,
    ),
    )
    : const Text(' to Payment'),
    ),
    ),

    SizedBox(height: 40),
    ],
    ),
    ),
    );
  }
}



