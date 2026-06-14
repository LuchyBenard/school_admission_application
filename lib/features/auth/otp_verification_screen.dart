import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:oktoast/oktoast.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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
    _confirmPasswordController.dispose();
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

      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.confirmPasswordReset(
          otp: _otpController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
      );

        if (!mounted) return;

        if (success) {
        // Go back to login and clear all screens
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
        // if it fails, AuthProvider already shows the error toast
  }
  }
  void _resendOTP() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendPasswordResetEmail(email: _email);

    if (!mounted) return;

    if (success) {
      showToast(
        'A new OTP has been sent to $_email',
        backgroundColor: AppColors.success,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    //Pinput theme setup
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
                SizedBox(height: 24.h),

                // Title
                Text(
                  'Check your Email',
                  style: AppTextStyles.displayMedium,
                ),

                SizedBox(height: 8.h),

                // Subtitle with email
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium,
                    children: [
                      TextSpan(text: 'We sent a 6-digit OTP to '),
                      TextSpan(
                        text: _email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                          text: '. Enter it below along with your new password.'),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                // OTP input
                Text('Enter OTP', style: AppTextStyles.label),
                SizedBox(height: 12.h),
                Center(
                  child: Pinput(
                    controller: _otpController,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    keyboardType: TextInputType.number,
                  ),
                ),

                SizedBox(height: 8.h),

                // Resend OTP
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _resendOTP,
                    child: Text(
                      'Resend OTP',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // New password
                Text('New Password', style: AppTextStyles.label),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.textHint,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // Confirm password
                Text('Confirm Password', style: AppTextStyles.label),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Confirm new password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textHint,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      child: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 32.h),

                // Reset button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child){
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _resetPassword,
                      child: authProvider.isLoading
                          ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          color: AppColors.background,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Reset Password'),
                    );
                  }
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