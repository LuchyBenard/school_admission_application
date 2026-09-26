import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';

/// Shown after signup (and for unverified users on login / splash) until
/// the email is confirmed. Firebase sends a verification email; this screen
/// polls `emailVerified`, lets the user resend, or verify manually with the
/// code from the email link. The dashboard stays blocked until verified.
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _pollTimer;
  bool _checking = false;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _email = FirebaseAuth.instance.currentUser?.email ?? '';
    // Poll so the app moves on automatically once the link is clicked.
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkVerified();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVerified();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkVerified() async {
    if (_checking) return;
    _checking = true;
    final verified =
        await context.read<AuthProvider>().checkEmailVerified();
    _checking = false;
    if (!mounted) return;
    if (verified) {
      _pollTimer?.cancel();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    }
  }

  Future<void> _resend() async {
    final authProvider = context.read<AuthProvider>();
    final sent = await authProvider.sendVerificationEmail();
    if (!mounted) return;
    showToast(
      sent
          ? 'Verification email sent. Check your inbox.'
          : 'Could not send verification email. Please wait a minute and retry.',
      backgroundColor: sent ? AppColors.success : AppColors.error,
      textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
    );
  }

  Future<void> _verifyWithCode() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final verified = await authProvider.verifyEmailWithCode(
      _codeController.text.trim(),
    );
    if (!mounted) return;

    if (verified) {
      _pollTimer?.cancel();
      showToast(
        'Email verified. Welcome aboard!',
        backgroundColor: AppColors.success,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    } else {
      showToast(
        'Invalid or expired verification code.',
        backgroundColor: AppColors.error,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
    }
  }

  Future<void> _signOut() async {
    _pollTimer?.cancel();
    await context.read<AuthProvider>().logout(context);
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
          child: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),

                // Icon
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    color: AppColors.primary,
                    size: 32.w,
                  ),
                ),
                SizedBox(height: 24.h),

                // Title
                Text(
                  'Verify your email',
                  style: AppTextStyles.displayMedium,
                ),
                SizedBox(height: 8.h),

                // Subtitle with email
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium,
                    children: [
                      TextSpan(text: 'We sent a verification email to '),
                      TextSpan(
                        text: _email.isEmpty ? 'your inbox' : _email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text:
                            '. Open it and click the link to confirm your account.',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Auto-detection note
                Container(
                  padding: EdgeInsets.all(14.w),
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
                        Icons.auto_mode_outlined,
                        color: AppColors.primary,
                        size: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Once verified, you will be taken to your dashboard automatically.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Verify with code (optional OTP-style)
                Text('Verify with code', style: AppTextStyles.h2),
                SizedBox(height: 4.h),
                Text(
                  'In the email, copy the code from the verification link and paste it below.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _codeController,
                  style: AppTextStyles.bodyLarge,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Paste verification code',
                    prefixIcon: Icon(
                      Icons.pin_outlined,
                      color: AppColors.textHint,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the verification code';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyWithCode,
                    child: const Text('Verify Code'),
                  ),
                ),

                SizedBox(height: 24.h),

                // Resend
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _resend,
                    child: const Text('Resend Email'),
                  ),
                ),

                SizedBox(height: 24.h),

                // Manual refresh
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: authProvider.isLoading ? null : _checkVerified,
                        child: const Text(
                          "I've verified — Continue",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 16.h),

                // Sign out
                Center(
                  child: GestureDetector(
                    onTap: _signOut,
                    child: Text(
                      'Sign out',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}