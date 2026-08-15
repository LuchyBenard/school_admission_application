import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/biometric_service.dart';

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
  final BiometricService _biometricService = BiometricService();
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  bool _fingerprintEnabled = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    // Wait for profile to be available then load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
      _loadFingerprintStatus();
    });
  }

  Future<void> _loadFingerprintStatus() async {
    final supported = await _biometricService.isSupported;
    final credentials = await _biometricService.readCredentials();
    if (!mounted) return;

    final profile = context.read<AuthProvider>();
    final currentEmail = profile.userProfile?['email'] ?? profile.user?.email;

    if (supported && credentials != null && currentEmail != null) {
      setState(() {
        _fingerprintEnabled = credentials.email == currentEmail;
      });
    }
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
  void dispose() {
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.background,
                surface: AppColors.background,
              ),
            ),
            child: child!,
          );
        });

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Uint8List? _photoBytes(dynamic photo) {
    if (photo is! String || photo.isEmpty) return null;
    try {
      return base64Decode(photo);
    } catch (e) {
      return null;
    }
  }

  void _showPhotoSource() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Choose Photo Source',
                style: AppTextStyles.h2,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                'Choose from Gallery',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                'Take a Photo',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.camera);
              },
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final authProvider = context.read<AuthProvider>();
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );
      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();
      final photo = base64Encode(bytes);

      setState(() => _isUploadingPhoto = true);
      final success = await authProvider.updateProfilePhoto(photo);
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);

      if (!success) {
        showToast(
          'Failed to update photo. Please try again.',
          backgroundColor: AppColors.error,
          textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      showToast(
        'Failed to pick photo. Please try again.',
        backgroundColor: AppColors.error,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.userProfile;
    final String fullName = profile?['fullName'] ?? 'Student';
    final String email = profile?['email'] ?? authProvider.user?.email ?? '';
    final String initials = fullName.isNotEmpty
        ? fullName.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join()
        : 'S';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.h2,
        ),
        actions: [
          GestureDetector(
            onTap: _toggleEdit,
            child: Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: Center(
                child: Text(
                  _isEditing ? 'Cancel' : 'Edit',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Avatar
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 90.w,
                          height: 90.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            image: _photoBytes(profile?['photo']) != null
                                ? DecorationImage(
                                    image: MemoryImage(
                                      _photoBytes(profile?['photo'])!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _photoBytes(profile?['photo']) != null
                              ? null
                              : Center(
                                  child: Text(
                                    initials.toUpperCase(),
                                    style: AppTextStyles.displayMedium.copyWith(
                                      color: AppColors.background,
                                      fontSize: 32,
                                    ),
                                  ),
                                ),
                        ),
                        // Camera / change photo button
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _isUploadingPhoto ? null : _showPhotoSource,
                            child: Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: _isUploadingPhoto
                                  ? Padding(
                                      padding: EdgeInsets.all(6.w),
                                      child: const CircularProgressIndicator(
                                        color: AppColors.background,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      color: AppColors.background,
                                      size: 15,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      fullName,
                      style: AppTextStyles.h2,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      email,
                      style: AppTextStyles.bodyMedium,
                    ),
                    SizedBox(height: 12.h),
                    // Role Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Student',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              const Divider(),
              SizedBox(height: 24.h),

              // Profile Fields
              Text('Personal Information', style: AppTextStyles.h3),
              SizedBox(height: 20.h),

              // Full Name
              _buildField(
                  label: 'Full Name',
                  controller: _fullNameController,
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  }),
              SizedBox(height: 16.h),

              // Email - always disabled
              _buildField(
                label: 'Email Address',
                controller: TextEditingController(text: email),
                icon: Icons.email_outlined,
                enabled: false,
                validator: null,
              ),
              SizedBox(height: 16.h),

              // Phone Number
              _buildField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  }),
              SizedBox(height: 16.h),

              // Date of Birth
              GestureDetector(
                onTap: _isEditing ? _selectDate : null,
                child: AbsorbPointer(
                  child: _buildField(
                    label: 'Date of Birth',
                    controller: _dateOfBirthController,
                    icon: Icons.calendar_today_outlined,
                    enabled: _isEditing,
                    validator: null,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // State of Origin
              _buildField(
                label: 'State of Origin',
                controller: _stateOfOriginController,
                icon: Icons.location_on_outlined,
                enabled: _isEditing,
                validator: null,
              ),
              SizedBox(height: 32.h),

              // Save button - only shows when editing
              if (_isEditing)
                Consumer<AuthProvider>(builder: (context, authProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _saveProfile,
                      child: authProvider.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                color: AppColors.background,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  );
                }),

              if (_isEditing) SizedBox(height: 16.h),

              // Logout Button
              if (!_isEditing) ...[
                const Divider(),
                SizedBox(height: 16.h),

                // Account selection
                Text('Account', style: AppTextStyles.h3),
                SizedBox(height: 16.h),

                // Fingerprint sign-in toggle
                _buildFingerprintTile(),
                SizedBox(height: 12.h),

                // Change Password
                _buildAccountTile(
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  onTap: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                ),

                SizedBox(height: 12.h),

                // Logout
                _buildAccountTile(
                  icon: Icons.logout,
                  label: 'Logout',
                  color: AppColors.error,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),

                SizedBox(height: 40.h),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textHint),
            fillColor: enabled ? AppColors.surface : AppColors.surface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildFingerprintTile() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.fingerprint,
              color: _fingerprintEnabled
                  ? AppColors.primary
                  : AppColors.textHint,
              size: 22.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fingerprint sign-in',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _fingerprintEnabled
                      ? 'Enabled — sign in without your password'
                      : 'Use your fingerprint to sign in faster',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: _fingerprintEnabled,
            onChanged: _onFingerprintChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _onFingerprintChanged(bool value) async {
    if (value) {
      await _enableFingerprint();
    } else {
      await _biometricService.deleteCredentials();
      if (!mounted) return;
      setState(() => _fingerprintEnabled = false);
      showToast(
        'Fingerprint sign-in disabled',
        backgroundColor: AppColors.info,
      );
    }
  }

  Future<void> _enableFingerprint() async {
    final supported = await _biometricService.isSupported;
    if (!supported) {
      if (!mounted) return;
      setState(() => _fingerprintEnabled = false);
      showToast(
        'Biometrics are not available on this device',
        backgroundColor: AppColors.warning,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      return;
    }

    if (!mounted) return;

    final profile = context.read<AuthProvider>();
    final email = profile.userProfile?['email'] ?? profile.user?.email;
    if (email == null) {
      if (!mounted) return;
      showToast(
        'Could not determine your account email',
        backgroundColor: AppColors.error,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      return;
    }

    final password = await _showPasswordDialog();
    if (password == null) return;

    final verified = await profile.verifyPassword(
      email: email,
      password: password,
    );
    if (!mounted) return;

    if (!verified) {
      showToast(
        'Incorrect password. Please try again.',
        backgroundColor: AppColors.error,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      return;
    }

    await _biometricService.saveCredentials(email, password);
    if (!mounted) return;
    setState(() => _fingerprintEnabled = true);
    showToast(
      'Fingerprint sign-in enabled',
      backgroundColor: AppColors.success,
    );
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Confirm password', style: AppTextStyles.h2),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            style: AppTextStyles.bodyLarge,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: AppColors.textHint,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: Text(
              'Enable',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      return controller.text;
    }
    return null;
  }

  Widget _buildAccountTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.textPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.w),
            SizedBox(width: 12.w),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: color),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textHint,
              size: 14.w,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Logout', style: AppTextStyles.h2),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMedium,
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
              context.read<AuthProvider>().logout(context);
            },
            child: Text(
              'Logout',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
