import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
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
    );

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
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
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
                l10n.documentUploadChooseSource,
                style: AppTextStyles.h2,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: context.colors.primary,
              ),
              title: Text(
                l10n.documentUploadChooseFromGallery,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
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
                color: context.colors.primary,
              ),
              title: Text(
                l10n.documentUploadTakePhoto,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
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
    final l10n = AppLocalizations.of(context);
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
          l10n.profilePhotoUpdateFailed,
          backgroundColor: context.colors.error,
          textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      showToast(
        l10n.profilePhotoPickFailed,
        backgroundColor: context.colors.error,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final profile = authProvider.userProfile;
    final String fullName = profile?['fullName'] ?? 'Student';
    final String email = profile?['email'] ?? authProvider.user?.email ?? '';
    final String initials = fullName.isNotEmpty
        ? fullName.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join()
        : 'S';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          GestureDetector(
            onTap: _toggleEdit,
            child: Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: Center(
                child: Text(
                  _isEditing ? l10n.commonCancel : l10n.commonDone,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.primary,
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
                            color: colors.primary,
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
                                      color: colors.onPrimary,
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
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: _isUploadingPhoto
                                  ? Padding(
                                      padding: EdgeInsets.all(6.w),
                                      child: CircularProgressIndicator(
                                        color: colors.onPrimary,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.camera_alt,
                                      color: colors.onPrimary,
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
                        color: colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        l10n.homeRoleStudent,
                        style: AppTextStyles.caption.copyWith(
                          color: colors.primary,
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
              Text(l10n.settingsProfileSection, style: AppTextStyles.h3),
              SizedBox(height: 20.h),

              // Full Name
              _buildField(
                  label: l10n.profileFullName,
                  controller: _fullNameController,
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.applicationFormErrorNameRequired;
                    }
                    return null;
                  }),
              SizedBox(height: 16.h),

              // Email - always disabled
              _buildField(
                label: l10n.profileEmailAddress,
                controller: TextEditingController(text: email),
                icon: Icons.email_outlined,
                enabled: false,
                validator: null,
              ),
              SizedBox(height: 16.h),

              // Phone Number
              _buildField(
                  label: l10n.profilePhoneNumber,
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.signupErrorPhoneRequired;
                    }
                    return null;
                  }),
              SizedBox(height: 16.h),

              // Date of Birth
              GestureDetector(
                onTap: _isEditing ? _selectDate : null,
                child: AbsorbPointer(
                  child: _buildField(
                    label: l10n.applicationFormDateOfBirth,
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
                label: l10n.profileStateOfOrigin,
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
                              child: CircularProgressIndicator(
                                color: colors.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.settingsSaveChanges),
                    ),
                  );
                }),

              if (_isEditing) SizedBox(height: 16.h),

              // Logout Button
              if (!_isEditing) ...[
                const Divider(),
                SizedBox(height: 16.h),

                // Appearance & language
                Text(l10n.settingsTitle, style: AppTextStyles.h3),
                SizedBox(height: 16.h),

                _buildThemeSelector(),
                SizedBox(height: 12.h),
                _buildLanguageSelector(),

                SizedBox(height: 24.h),

                // Account selection
                Text(l10n.settingsAccount, style: AppTextStyles.h3),
                SizedBox(height: 16.h),

                // Fingerprint sign-in toggle
                _buildFingerprintTile(),
                SizedBox(height: 12.h),

                // Change Password
                _buildAccountTile(
                  icon: Icons.lock_outline,
                  label: l10n.settingsChangePassword,
                  onTap: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                ),

                SizedBox(height: 12.h),

                // Logout
                _buildAccountTile(
                  icon: Icons.logout,
                  label: l10n.settingsLogout,
                  color: colors.error,
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

  /// Segmented control for light / dark / system appearance.
  Widget _buildThemeSelector() {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();

    return _buildSettingsGroup(
      icon: Icons.palette_outlined,
      title: l10n.settingsAppearance,
      child: Column(
        children: [
          _buildSegmentedRow<AppThemePreference>(
            value: settings.themePreference,
            options: <AppThemePreference, String>{
              AppThemePreference.system: l10n.settingsThemeSystem,
              AppThemePreference.light: l10n.settingsThemeLight,
              AppThemePreference.dark: l10n.settingsThemeDark,
            },
            onChanged: settings.setThemePreference,
          ),
        ],
      ),
    );
  }

  /// Language list. Endonyms are shown so each option is readable to the
  /// person who speaks it.
  Widget _buildLanguageSelector() {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();

    return _buildSettingsGroup(
      icon: Icons.language,
      title: l10n.settingsLanguage,
      child: Column(
        children: [
          for (final locale in SettingsProvider.supportedLocales)
            _buildOptionTile(
              label: SettingsProvider.languageNames[locale.languageCode]!,
              selected: settings.locale?.languageCode == locale.languageCode,
              onTap: () => settings.setLocale(locale),
            ),
          _buildOptionTile(
            label: l10n.settingsLanguageSystem,
            selected: settings.locale == null,
            onTap: () => settings.setLocale(null),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.colors.primary, size: 20.w),
              SizedBox(width: 12.w),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            const Spacer(),
            if (selected)
              Icon(Icons.check, color: context.colors.primary, size: 20.w),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedRow<T>({
    required T value,
    required Map<T, String> options,
    required Future<void> Function(T) onChanged,
  }) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          for (final entry in options.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.key),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: value == entry.key ? colors.primary : null,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          value == entry.key ? colors.onPrimary : colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
    final colors = context.colors;
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
            prefixIcon: Icon(icon, color: colors.textHint),
            fillColor:
                enabled ? colors.surface : colors.surface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildFingerprintTile() {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.fingerprint,
              color: _fingerprintEnabled ? colors.primary : colors.textHint,
              size: 22.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileFingerprint,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _fingerprintEnabled
                      ? l10n.profileFingerprintOn
                      : l10n.profileFingerprintOff,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: _fingerprintEnabled,
            onChanged: _onFingerprintChanged,
            activeThumbColor: colors.primary,
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
        AppLocalizations.of(context).profileFingerprintDisabledToast,
        backgroundColor: context.colors.info,
      );
    }
  }

  Future<void> _enableFingerprint() async {
    final l10n = AppLocalizations.of(context);
    final supported = await _biometricService.isSupported;
    if (!supported) {
      if (!mounted) return;
      setState(() => _fingerprintEnabled = false);
      showToast(
        l10n.profileFingerprintUnavailable,
        backgroundColor: context.colors.warning,
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
        l10n.profileFingerprintEmailMissing,
        backgroundColor: context.colors.error,
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
        l10n.profileFingerprintWrongPassword,
        backgroundColor: context.colors.error,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      return;
    }

    await _biometricService.saveCredentials(email, password);
    if (!mounted) return;
    setState(() => _fingerprintEnabled = true);
    showToast(
      l10n.profileFingerprintEnabledToast,
      backgroundColor: context.colors.success,
    );
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(l10n.settingsConfirmPasswordTitle, style: AppTextStyles.h2),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            style: AppTextStyles.bodyLarge,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l10n.profileEnterPassword,
              prefixIcon: Icon(Icons.lock_outline, color: colors.textHint),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.signupErrorPasswordRequired;
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
              l10n.commonCancel,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
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
              l10n.profileEnable,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.primary,
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
    Color? color,
  }) {
    final colors = context.colors;
    final resolved = color ?? colors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: resolved, size: 20.w),
            SizedBox(width: 12.w),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: resolved),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: colors.textHint,
              size: 14.w,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(l10n.settingsLogoutTitle, style: AppTextStyles.h2),
        content: Text(
          l10n.settingsLogoutBody,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.commonCancel,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout(context);
            },
            child: Text(
              l10n.settingsLogout,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
