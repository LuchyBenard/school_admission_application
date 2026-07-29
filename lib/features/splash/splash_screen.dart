import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate after 3 seconds
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final box = GetStorage();
    final bool hasSeenOnboarding = box.read('hasSeenOnboarding') ?? false;
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Check role in Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (!mounted) return;

        final role = doc.data()?['role'] ?? 'student';
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else if (!hasSeenOnboarding) {
      // First time user - show onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      // Seen onboarding but has not logged in - go to login page
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.r),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Image.asset(
                        'assets/images/universityLogo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.school, size: 60, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // App Name
                Text(
                  'CampusApply',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.background,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),

                // TagLine
                Text(
                  'Your Admission, Simplified',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.background.withValues(alpha: 0.75),
                  ),
                ),

                SizedBox(height: 80.h),

                // Loading Indicator
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    color: AppColors.background.withValues(alpha: 0.6),
                    strokeWidth: 2.5,
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
