import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    if (_formKey.currentState!.validate()) {
      if (_otpController.text.length < 6) {
        showToast(
          l10n.otpErrorRequired,
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
    final l10n = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendPasswordResetEmail(email: _email);

    if (!mounted) return;

    if (success) {
      showToast(
        l10n.otpResendToast(_email),
        backgroundColor: AppColors.success,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    //Pinput theme setup
    final defaultPinTheme = PinTheme(
      width: 52.w,
      height: 56.h,
      textStyle: AppTextStyles.h2.copyWith(color: context.colors.textPrimary),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colors.border),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: context.colors.primary, width: 1.5),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: context.colors.surfaceAlt,
        border: Border.all(color: context.colors.primary),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              color: context.colors.textPrimary,
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
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    color: context.colors.primary,
                    size: 32.w,
                  ),
                ),
                SizedBox(height: 24.h),

                // Title
                Text(
                  l10n.otpTitle,
                  style: AppTextStyles.displayMedium,
                ),

                SizedBox(height: 8.h),

                // Subtitle with email
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium,
                    children: [
                      TextSpan(text: l10n.otpDescription(_email)),
                      TextSpan(
                        text: l10n.otpDescriptionTail,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                // OTP input
                Text(l10n.otpCodeLabel, style: AppTextStyles.label),
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
                      l10n.otpResendButton,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // New password
                Text(l10n.otpNewPasswordLabel, style: AppTextStyles.label),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l10n.otpNewPasswordHint,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: context.colors.textHint,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
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
                      return l10n.otpErrorPasswordRequired;
                    }
                    if (value.length < 6) {
                      return l10n.otpErrorPasswordTooShort;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // Confirm password
                Text(l10n.otpConfirmPasswordLabel, style: AppTextStyles.label),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l10n.otpConfirmPasswordHint,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: context.colors.textHint,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      child: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: context.colors.textHint,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.otpErrorConfirmPasswordRequired;
                    }
                    if (value != _newPasswordController.text) {
                      return l10n.otpErrorPasswordMismatch;
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
                          color: context.colors.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(l10n.otpResetPasswordButton),
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
