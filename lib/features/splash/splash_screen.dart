import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_admission_application/core/constants/app_colors.dart';
import 'package:school_admission_application/core/constants/app_text_styles.dart';

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
      duration: Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate after 3 seconds
    Future.delayed(
        Duration(seconds: 3), () {
      if (!mounted) return;

      final box = GetStorage();
      final bool hasSeenOnboarding = box.read('hasSeenOnboarding') ?? false;
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Already logged in - go to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (!hasSeenOnboarding) {
        // First time user - show onboarding
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        // Seen onboarding but has not logged in - go to loin page
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
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
                        offset: Offset(0, 10),
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