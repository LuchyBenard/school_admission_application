import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_palette.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendOTP() async {
    final l10n = AppLocalizations.of(context);

    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        showToast(
          l10n.forgotPasswordSentToast,
          backgroundColor: AppColors.success,
          textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        );

        // Navigate to the next screen (Note: Firebase sends a link, not an OTP)
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: _emailController.text.trim(),
        );
      }
      // If it fails, AuthProvider already shows the error toast
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                    Icons.lock_reset_rounded,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: 24.h),
                //Title
                Text(
                  l10n.forgotPasswordTitle,
                  style: AppTextStyles.displayMedium,
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.forgotPasswordDescription,
                  style: AppTextStyles.bodyMedium,
                ),
                SizedBox(height: 40.h),

                // Email field
                Text(
                  l10n.forgotPasswordEmailLabel,
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l10n.forgotPasswordEmailHint,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: context.colors.textHint,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.forgotPasswordErrorEmailRequired;
                    }
                    if (!value.contains('@')) {
                      return l10n.forgotPasswordErrorEmailInvalid;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32.h),

                // Send Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child){
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _sendOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  color: context.colors.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l10n.forgotPasswordButton,
                                style: TextStyle(
                                  color: context.colors.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  }
                ),
                SizedBox(height: 24.h),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ], // End Column Children
            ),
          ),
        ),
      ),
    );
  }
}
