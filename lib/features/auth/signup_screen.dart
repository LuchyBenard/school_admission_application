import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_admission_application/core/constants/app_text_styles.dart';
import 'package:school_admission_application/core/constants/app_colors.dart';
import 'package:oktoast/oktoast.dart';

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
  bool _isLoading = false;
  bool _isAccepted = false;

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
    if (!_acceptedTerms) {
      showToast(
        'Please accept the terms and condition to continue.',
        backgroundColor: AppColors.error,
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
    }
    return;
  }

  if (_formKey.currentState!.validate()) {
  setState(() => _isLoading = true);

  // WE WILL CONNECT TO AUTHPROVIDER LATER
  await Future.delayed(Duration(seconds: 2)); // placeholder

  if (!mounted) return;
  setState(() => _isLoading = false);
  }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
