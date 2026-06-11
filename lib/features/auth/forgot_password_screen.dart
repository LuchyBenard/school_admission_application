import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oktoast/oktoast.dart';
import 'package:school_admission_application/core/constants/app_colors.dart';
import 'package:school_admission_application/core/constants/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
        if (!mounted) return;
        setState(() => _isLoading = false);
        // Navigate to OPT screen and pass the email along
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: _emailController.text.trim(),
        );
      } FirebaseAuthException catch (e) {
    setState(() => _isLoading = false);

    String message = 'Something went wrong. Please try again.';
    if (e.code == 'User-not-found') {
    message = 'No account found with email address.';
    } else if (e.code == 'Invalid email') {
    message = 'Please enter a valid email address.';
    }
    showToast(
    message,
    backgroundColor: AppColors.error,
    textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
    );
    }
  }
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
                    Icons.lock_reset_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),

                //Title
                Text(
                  'Forgot Password?',
                  style: AppTextStyles.displayMedium,
                ),
            SizedBox(height: 8.h),
            Text(
              'Enter your email address and w\'ll send you a 6-digit OTP to reset your password.',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 40.h),

            // Email field
            Text(
              'Email Address',
              style: AppTextStyles.label,
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppColors.textHint,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains(@)) {
                  return 'Please enter a valid email address';
                }
                return null;
                },
            ),
              SizedBox(height: 32.h),

              // send OTP button
              ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  child: _isLoading ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      color: AppColors.background,
                      strokeWidth: 2,
                    ),
                  )
                      : Text('Send OTP'),
                  ),
              SizedBox(height: 24.h),

              // Back to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Remember your password?',
                    style: AppTextStyles.bodyMedium,
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Sign In',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
