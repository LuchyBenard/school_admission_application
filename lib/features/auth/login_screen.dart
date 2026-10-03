import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_palette.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/biometric_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final BiometricService _biometricService = BiometricService();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _biometricAvailable = false;
  bool _isFingerprintLoading = false;
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
    if (!mounted) return;
    if (!supported) return;

    final credentials = await _biometricService.readCredentials();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = true;
      _savedEmail = credentials?.email;
    });
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        context: context,
      );

      if (!mounted) return;

      if (success) {
        // Save (or keep) credentials for fingerprint sign-in
        if (_biometricAvailable && _rememberMe) {
          await _biometricService.saveCredentials(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
          if (!mounted) return;
          setState(() => _savedEmail = _emailController.text.trim());
        }

        if (!mounted) return;

        // Unverified accounts are sent to the email-verification gate instead
        // of the dashboard.
        final verified = authProvider.isEmailVerified;
        Navigator.pushNamedAndRemoveUntil(
          context,
          verified ? '/dashboard' : '/email-verification',
          (route) => false,
        );
      }
    }
  }

  Future<void> _signInWithFingerprint() async {
    final l10n = AppLocalizations.of(context);
    final authenticated = await _biometricService.authenticate();
    if (!authenticated) {
      if (!mounted) return;
      showToast(
        l10n.loginFingerprintNotRecognised,
        backgroundColor: AppColors.warning,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      return;
    }

    final credentials = await _biometricService.readCredentials();
    if (!mounted) return;

    if (credentials == null) {
      setState(() => _savedEmail = null);
      showToast(
        l10n.loginNoSavedCredentials,
        backgroundColor: AppColors.warning,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      return;
    }

    _emailController.text = credentials.email;
    _passwordController.text = credentials.password;
    setState(() => _isFingerprintLoading = true);

    await _login();

    if (mounted) setState(() => _isFingerprintLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48.h),

                // Logo
                Center(
                  child: Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: context.colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Image.asset(
                        'assets/images/universityLogo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Welcome Text
                Text(
                  l10n.loginTitle,
                  style: AppTextStyles.displayMedium,
                ),

                SizedBox(height: 40.h),

                // sub text
                Text(
                  l10n.loginSubtitle,
                  style: AppTextStyles.bodyMedium,
                ),
                SizedBox(height: 40.h),
                // email field
                Text(
                  l10n.loginEmailLabel,
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l10n.loginEmailHint,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: context.colors.textHint,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.loginErrorEmailRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                //Password field
                Text(
                  l10n.loginPasswordLabel,
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l10n.loginPasswordHint,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: context.colors.textHint,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: _togglePassword,
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: context.colors.textHint,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.loginErrorPasswordRequired;
                    }
                    if (value.length < 8) {
                      return l10n.loginErrorPasswordTooShort;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 12.h),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: Text(
                      l10n.loginForgotPassword,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

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
                                ? context.colors.primary
                                : context.colors.surface,
                            borderRadius: BorderRadius.circular(5.r),
                            border: Border.all(
                              color: _rememberMe
                                  ? context.colors.primary
                                  : context.colors.border,
                              width: 1.5,
                            ),
                          ),
                          child: _rememberMe
                              ? Icon(
                                  Icons.check,
                                  size: 14,
                                  color: context.colors.onPrimary,
                                )
                              : null,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          l10n.loginEnableFingerprint,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 20.h),

                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _login,
                      child: authProvider.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                color: context.colors.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.loginSignIn),
                    );
                  },
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
                              child: CircularProgressIndicator(
                                color: context.colors.primary,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.fingerprint),
                      label: Text(
                        _isFingerprintLoading
                            ? l10n.loginSigningIn
                            : l10n.loginFingerprintSignIn,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: BorderSide(color: context.colors.border),
                        foregroundColor: context.colors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 24.r),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        l10n.commonOr,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 24.h),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.loginNoAccount,
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        l10n.loginCreateAccount,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),

                // Admin portal Link
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/admin-login'),
                  child: Center(
                    child: Text(
                      l10n.loginAdminPortal,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.colors.textHint,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}