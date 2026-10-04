import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_palette.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    final l10n = AppLocalizations.of(context);

    if (!_acceptedTerms) {
      showToast(
        l10n.signupErrorTermsRequired,
        backgroundColor: AppColors.error,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.register(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        context: context,
      );

      if (!mounted) return;

      if (success) {
        // Account created — verify the email before allowing dashboard access.
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/email-verification',
          (route) => false,
        );
      }
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
                SizedBox(height: 8.h),

                // TITLE
                Text(
                  l10n.signupTitle,
                  style: AppTextStyles.displayMedium,
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.signupSubtitle,
                  style: AppTextStyles.bodyMedium,
                ),
                SizedBox(height: 32.h),

                // FULL NAME
                Text(
                  l10n.signupFullNameLabel,
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _fullNameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l10n.signupFullNameHint,
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: context.colors.textHint,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.signupErrorNameRequired;
                    }
                    if (value.trim().split(' ').length < 2) {
                      return l10n.signupErrorNameShort;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // email field
                Text(
                  l10n.signupEmailLabel,
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l10n.signupEmailHint,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: context.colors.textHint,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.signupErrorEmailRequired;
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return l10n.signupErrorEmailInvalid;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Phone field
                Text(
                  l10n.signupPhoneLabel,
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l10n.signupPhoneHint,
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: context.colors.textHint,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.signupErrorPhoneRequired;
                    }
                    if (value.length < 11) {
                      return l10n.signupErrorPhoneInvalid;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // password field
                Text(
                  l10n.signupPasswordLabel,
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l10n.signupPasswordHint,
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                      color: context.colors.textHint,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
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
                      return l10n.signupErrorPasswordRequired;
                    }
                    if (value.length < 8) {
                      return l10n.loginErrorPasswordTooShort;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Confirm password field
                Text(
                  l10n.signupConfirmPasswordLabel,
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l10n.signupConfirmPasswordHint,
                    prefixIcon: Icon(
                      Icons.lock_outlined,
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
                      return l10n.signupErrorConfirmPasswordRequired;
                    }
                    if (value != _passwordController.text) {
                      return l10n.signupErrorPasswordMismatchShort;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Terms and Conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _acceptedTerms = !_acceptedTerms),
                      child: Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          color: _acceptedTerms
                              ? context.colors.primary
                              : context.colors.background,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: _acceptedTerms
                                ? context.colors.primary
                                : context.colors.border,
                            width: 1.5,
                          ),
                        ),
                        child: _acceptedTerms
                            ? Icon(
                                Icons.check,
                                color: context.colors.onPrimary,
                                size: 14.w,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium,
                          children: [
                            TextSpan(text: l10n.signupTermsPrefix),
                            TextSpan(
                              text: l10n.signupTermsAndConditions,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: l10n.signupTermsSeparator),
                            TextSpan(
                              text: l10n.signupPrivacyPolicy,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _register,
                      child: authProvider.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                color: context.colors.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.signupButton),
                    );
                  },
                ),
                SizedBox(height: 24.h),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.signupHaveAccount,
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        l10n.signupSignInLink,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
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