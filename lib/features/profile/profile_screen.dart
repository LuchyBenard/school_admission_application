import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _stateOfOriginController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profile = context.read<AuthProvider>().userProfile;
    if (profile != null) {
      _fullNameController.text = profile['fullName'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _dateOfBirthController.text = profile['dateOfBirth'] ?? '';
      _stateOfOriginController.text = profile['stateOfOrigin'] ?? '';
    }
    }

    @override
  void dispose () {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _stateOfOriginController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
    if (!_isEditing) {
      // Cancelled editing - reload original data
      _loadProfileData();
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.updateProfile(
        fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: _dateOfBirthController.text.trim(),
          stateOfOrigin: _stateOfOriginController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        setState(() => _isEditing = false);
      }
    }
  }
  // continue from future void <selectdata>
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.h2,
        ),
        ),
        body: Center(
          child: Text(
            'User Profile coming soon',
            style: AppTextStyles.bodyMedium,
          ),
        ),
    );
  }
}
