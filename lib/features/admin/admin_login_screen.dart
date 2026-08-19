import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _biometricAvailable = false;
  bool _isFingerprintLoading = false;
  bool _rememberMe = false;
  String? _savedEmail;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    final supported = await _biometricService.isSupported;
    if (!mounted || !supported) return;

    final credentials = await _biometricService.readAdminCredentials();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = true;
      _savedEmail = credentials?.email;
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.adminLogin(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Save (or keep) credentials for fingerprint sign-in
        if (_biometricAvailable && _rememberMe) {
          await _biometricService.saveAdminCredentials(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
          if (!mounted) return;
          setState(() => _savedEmail = _emailController.text.trim());
        }

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin-dashboard',
              (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        showToast(
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: AppColors.error,
          textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        );
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithFingerprint() async {
    final authenticated = await _biometricService.authenticate();
    if (!authenticated) return;

    final credentials = await _biometricService.readAdminCredentials();
    if (!mounted) return;

    if (credentials == null) {
      setState(() => _savedEmail = null);
      showToast(
        'No saved credentials found. Sign in manually once first.',
        backgroundColor: AppColors.warning,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      return;
    }

    _emailController.text = credentials.email;
    _passwordController.text = credentials.password;
    setState(() => _isFingerprintLoading = true);

    _login();

    if (mounted) setState(() => _isFingerprintLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),

                // Icon
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.background,
                    size: 32.w,
                  ),
                ),

                SizedBox(height: 24.h),

                Text('Admin Portal', style: AppTextStyles.displayMedium),
                SizedBox(height: 8.h),
                Text(
                  'Sign in to manage applications',
                  style: AppTextStyles.bodyMedium,
                ),

                SizedBox(height: 40.h),
                // Email
                Text('Email Address', style: AppTextStyles.label),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _emailController,
                  style: AppTextStyles.bodyLarge,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter admin email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.textHint,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),
                // PassWord
                Text(
                  'Password',
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Enter Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textHint,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscureText = !_obscureText),
                      child: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Biometric remember-me
                if (_biometricAvailable)
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      children: [
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: _rememberMe
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(5.r),
                            border: Border.all(
                              color: _rememberMe
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: _rememberMe
                              ? const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.background,
                          )
                              : null,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Enable fingerprint sign-in',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 20.h),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        color: AppColors.background,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Sign In as Admin'),
                  ),
                ),

                // Fingerprint sign-in
                if (_biometricAvailable && _savedEmail != null) ...[
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                      _isFingerprintLoading ? null : _signInWithFingerprint,
                      icon: _isFingerprintLoading
                          ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.fingerprint),
                      label: Text(
                        _isFingerprintLoading
                            ? 'Signing in...'
                            : 'Sign in with fingerprint',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 24.h),

                // Back to student login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Are you a student?',
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Text(
                          'Student Login',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
