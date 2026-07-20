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
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
