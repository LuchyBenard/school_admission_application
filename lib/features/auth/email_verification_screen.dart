import 'dart:async';
import '../../../core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();
    final sent = await authProvider.sendVerificationEmail();
    if (!mounted) return;
    showToast(
      sent
          ? l10n.emailVerifySentToast
          : l10n.emailVerifySendFailedToast,
      backgroundColor: sent ? AppColors.success : AppColors.error,
      textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
    );
  }

  Future<void> _verifyWithCode() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final verified = await authProvider.verifyEmailWithCode(
      _codeController.text.trim(),
    );
    if (!mounted) return;

    if (verified) {
      _pollTimer?.cancel();
      showToast(
        l10n.emailVerifySuccessToast,
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
        l10n.emailVerifyCodeInvalid,
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: context.colors.textPrimary),
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
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    color: context.colors.primary,
                    size: 32.w,
                  ),
                ),
                SizedBox(height: 24.h),

                // Title
                Text(
                  l10n.emailVerifyTitle,
                  style: AppTextStyles.displayMedium,
                ),
                SizedBox(height: 8.h),

                // Subtitle with email
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium,
                    children: [
                      TextSpan(text: l10n.emailVerifySentTo(_email.isEmpty ? l10n.emailVerifyInbox : _email)),
                      TextSpan(
                        text: '. Open it and click the link to confirm your account.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Auto-detection note
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: context.colors.primaryLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_mode_outlined,
                        color: context.colors.primary,
                        size: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          l10n.emailVerifyAutoDetect,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Verify with code (optional OTP-style)
                Text(l10n.emailVerifyVerifyWithCode, style: AppTextStyles.h2),
                SizedBox(height: 4.h),
                Text(
                  l10n.emailVerifyCodeDescription,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _codeController,
                  style: AppTextStyles.bodyLarge,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: l10n.emailVerifyCodeHint,
                    prefixIcon: Icon(
                      Icons.pin_outlined,
                      color: context.colors.textHint,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.emailVerifyCodeRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyWithCode,
                    child: Text(l10n.emailVerifyVerifyCodeButton),
                  ),
                ),

                SizedBox(height: 24.h),

                // Resend
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _resend,
                    child: Text(l10n.emailVerifyResendButton),
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
                        child: Text(
                          l10n.emailVerifyManualRefresh,
                          style: TextStyle(
                            color: context.colors.primary,
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
                      l10n.emailVerifySignOut,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.colors.textHint,
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
