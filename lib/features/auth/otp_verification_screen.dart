import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:oktoast/oktoast.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordConfirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePassword = true;
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the email passed from ForgotPasswordScreen
    _email = ModalRoute.of(context)!.settings.arguments as String;
  }
  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordConfirm.dispose();
    super.dispose();
  }
  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      if (_otpController.text.length < 6) {
        showToast(
          'Please enter the complete 6-digit  OTP',
          backgroundColor: AppColors.error,
          textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Confirm the OTP code and reset password
        await FirebaseAuth.instance.confirmPasswordReset(
            code: _otpController.text,
            newPassword: _newPasswordController.text.trim(),
        );
        if (!mounted) return;
        setState(() => _isLoading = false);

        showToast(
          'Password reset successful! Please sign in.',
            backgroundColor: AppColors.success,
          textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        );

        // Go back to login and clear all screens
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);

        String message = 'Something went wrong. Please try again.';
        if (e.code == 'invalid-action-code') {
          message = 'invalid or expired OTP. Please request a new one,';
        } else if (e.code == 'expired-action-code') {
          message = 'OTP has expired. Please request a new one.';
        } else if (e.code == 'weak password') {
          message = 'Password is too weak. Use at least 6 characters.';
        }
        showToast(
          message,
          backgroundColor: AppColors.error,
          textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        );
      }
  }
  }
  void _resendOTP() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      showToast(
        'A new OTP has been sent to $_email',
        backgroundColor: AppColors.success,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
    } catch (e) {
      showToast(
        'Failed to resend OTP. Please try again,',
        backgroundColor: AppColors.error,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    //Pinput theme
    final defaultPinTheme = PinTheme(
      width: 52.w,
      height: 56.h,
      textStyle: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.surfaceAlt,
        border: Border.all(color: AppColors.primary),
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
            ),
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
                SizedBox(height: 20.h),

                // Icon
                Container(
                  width: 64.w,
                    height: 64.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primary,
                    size: 32.w,
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
