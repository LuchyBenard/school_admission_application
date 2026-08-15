import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_admission_application/core/constants/app_colors.dart';
import 'package:school_admission_application/core/constants/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';
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

        // Go to the dashboard and Clear all previous screens
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      }
    }
  }

  Future<void> _signInWithFingerprint() async {
    final authenticated = await _biometricService.authenticate();
    if (!authenticated) {
      if (!mounted) return;
      showToast(
        'Fingerprint not recognised. Try again or sign in manually.',
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
        'No saved credentials found. Sign in manually once first.',
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
                SizedBox(height: 48.h),

                // Logo
                Center(
                  child: Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
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
                  'Welcome Back',
                  style: AppTextStyles.displayMedium,
                ),

                SizedBox(height: 40.h),

                // sub text
                Text(
                  'Sign in to continue your admission journey',
                  style: AppTextStyles.bodyMedium,
                ),
                SizedBox(height: 40.h),
                // email field
                Text(
                  'Email address',
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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
                  return null;
                },
                ),
                SizedBox(height: 20.h),

                //Password field
                Text(
                  'Password',
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.textHint,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: _togglePassword,
                      child: Icon(
                        _obscurePassword
                        ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
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
                      'Forgot Password?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
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

                // Login Button
               Consumer<AuthProvider> (
                 builder: (context, authProvider, child){
                   return ElevatedButton(
                     onPressed: authProvider.isLoading ? null : _login,
                     child: authProvider.isLoading ? SizedBox(
                       width: 20.w,
                       height: 20.w,
                       child: CircularProgressIndicator(
                         color: AppColors.background,
                         strokeWidth: 2,
                       ),
                     )
                         : Text('Sign In'),
                   );
                 }

               ),

                // Fingerprint sign-in
                if (_biometricAvailable && _savedEmail != null) ...[
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isFingerprintLoading ? null : _signInWithFingerprint,
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

                SizedBox(height: 24.r),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        'or',
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
                      "Don't have an account?",
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Create Account',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
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
                      'Admin Portal',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
