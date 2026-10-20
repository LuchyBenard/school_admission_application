import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/offline_queue_provider.dart';

/// Fixed colours for the branded splash, matching the approved design.
///
/// The splash is intentionally a dark, full-bleed hero that looks the same in
/// light and dark mode, so it uses its own fixed palette rather than the
/// theme's [AppPalette].
class _SplashColors {
  _SplashColors._();

  static const Color navy = Color(0xFF091426);
  static const Color navyAlt = Color(0xFF1E293B);
  static const Color blue = Color(0xFF0051D5);
  static const Color blueBright = Color(0xFF316BF3);
  static const Color amber = Color(0xFFD97705);
  static const Color lightBlue = Color(0xFFD3E4FE);
  static const Color gray = Color(0xFF45474C);
  static const Color white = Color(0xFFFFFFFF);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _pulseController;

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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _controller.forward();

    // Start connectivity monitoring / queue replay after first frame so
    // notifying listeners doesn't interrupt the build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OfflineQueueProvider>().init();
    });

    _routeReturningUserIfSignedIn();
  }

  /// Returning (already signed-in) users are taken straight to their
  /// destination. First-time / signed-out users stay on this landing screen
  /// and choose between "Begin Application" and "Sign in".
  Future<void> _routeReturningUserIfSignedIn() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Let the emblem animation play before leaving the splash.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!mounted) return;

      final role = doc.data()?['role'] ?? 'student';

      // Refresh the cached Firebase Auth state so the emailVerified flag is
      // current (in case the user verified while the app was closed). Falls
      // back to the cached value offline.
      bool verified = user.emailVerified;
      if (!verified) {
        try {
          await user.reload();
          verified = FirebaseAuth.instance.currentUser?.emailVerified == true;
        } catch (_) {
          verified = user.emailVerified;
        }
      }

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else if (verified) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/email-verification');
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _beginApplication() {
    final box = GetStorage();
    final hasSeenOnboarding = box.read('hasSeenOnboarding') ?? false;
    final route = hasSeenOnboarding ? '/register' : '/onboarding';
    Navigator.pushReplacementNamed(context, route);
  }

  void _goToSignIn() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _SplashColors.navy,
      body: Stack(
        children: [
          // Architectural campus background.
          Positioned.fill(
            child: Image.asset(
              'assets/images/universitybuilding.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: _SplashColors.navy),
            ),
          ),

          // Top-down navy depth.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _SplashColors.navy.withValues(alpha: 0.80),
                    _SplashColors.navy.withValues(alpha: 0.50),
                    _SplashColors.navy,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Bottom-up anchor so the card reads cleanly.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _SplashColors.navy,
                    _SplashColors.navy.withValues(alpha: 0.75),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _topBadges(l10n),
                Expanded(
                  child: Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: _hero(l10n),
                        ),
                      ),
                    ),
                  ),
                ),
                _bottomCard(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBadges(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
      child: Row(
        children: [
          // Admissions badge.
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _SplashColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: _SplashColors.white.withValues(alpha: 0.20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars, size: 16.sp, color: _SplashColors.amber),
                SizedBox(width: 6.w),
                Text(
                  l10n.splashAdmissionsBadge.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    color: _SplashColors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Official portal badge.
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: _SplashColors.navy.withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: _SplashColors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  size: 14.sp,
                  color: _SplashColors.lightBlue,
                ),
                SizedBox(width: 4.w),
                Text(
                  l10n.splashOfficialPortal,
                  style: AppTextStyles.label.copyWith(
                    color: _SplashColors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emblem pod with glow.
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: _SplashColors.blue.withValues(alpha: 0.45),
                blurRadius: 44,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.50),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Container(
            width: 116.w,
            height: 116.w,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _SplashColors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: _SplashColors.white),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset(
                'assets/images/universityLogo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.school,
                  size: 64.sp,
                  color: _SplashColors.blue,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // App name.
        Text(
          l10n.splashAppName,
          textAlign: TextAlign.center,
          style: AppTextStyles.displayLarge.copyWith(
            color: _SplashColors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),

        // Tagline.
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300.w),
          child: Text(
            l10n.splashHeroTagline,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: _SplashColors.lightBlue,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // Trust pills.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _pill(l10n.splashPillIvyLeague, _SplashColors.blueBright),
            _pill(l10n.splashPillRussellGroup, _SplashColors.amber),
            _pill(l10n.splashPillGlobalTier1, _SplashColors.lightBlue),
          ],
        ),
      ],
    );
  }

  Widget _pill(String label, Color dotColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _SplashColors.navyAlt.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: _SplashColors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: _SplashColors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomCard(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: _SplashColors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: _SplashColors.white.withValues(alpha: 0.60),
          ),
          boxShadow: [
            BoxShadow(
              color: _SplashColors.navy.withValues(alpha: 0.45),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Live network metric.
            Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: _SplashColors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.public,
                    size: 18.sp,
                    color: _SplashColors.blue,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.splashVerifiedNetwork,
                        style: AppTextStyles.label.copyWith(
                          color: _SplashColors.gray,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10n.splashConnectingInstitutions,
                        style: AppTextStyles.label.copyWith(
                          color: _SplashColors.navy,
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _pulseDot(),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(
              height: 1,
              color: _SplashColors.navy.withValues(alpha: 0.10),
            ),
            SizedBox(height: 16.h),

            // Primary CTA.
            SizedBox(
              height: 50.h,
              child: ElevatedButton(
                onPressed: _beginApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _SplashColors.navy,
                  foregroundColor: _SplashColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.splashBeginApplication,
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: _SplashColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward,
                      size: 18.sp,
                      color: _SplashColors.white,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Secondary sign-in action.
            Center(
              child: TextButton(
                onPressed: _goToSignIn,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.splashAlreadyApplied,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _SplashColors.gray,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      l10n.loginSignIn,
                      style: AppTextStyles.label.copyWith(
                        color: _SplashColors.blue,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            _SplashColors.blue.withValues(alpha: 0.30),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.north_east,
                      size: 14.sp,
                      color: _SplashColors.blue,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Divider(
              height: 1,
              color: _SplashColors.navy.withValues(alpha: 0.10),
            ),
            SizedBox(height: 12.h),

            // Accreditation footnote.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 13.sp, color: _SplashColors.blue),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    l10n.splashSslSecured,
                    style: AppTextStyles.caption.copyWith(
                      color: _SplashColors.gray,
                      fontSize: 10.5.sp,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    '\u2022',
                    style: AppTextStyles.caption.copyWith(
                      color: _SplashColors.gray,
                    ),
                  ),
                ),
                Icon(Icons.school, size: 13.sp, color: _SplashColors.blue),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    l10n.splashAccreditation,
                    style: AppTextStyles.caption.copyWith(
                      color: _SplashColors.gray,
                      fontSize: 10.5.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Pulsing "live" indicator for the verified-network metric.
  Widget _pulseDot() {
    return SizedBox(
      width: 10.w,
      height: 10.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final t = _pulseController.value;
              return Opacity(
                opacity: (1 - t).clamp(0.0, 0.75),
                child: Transform.scale(
                  scale: 1 + t * 2,
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: const BoxDecoration(
                      color: _SplashColors.blueBright,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 10.w,
            height: 10.w,
            decoration: const BoxDecoration(
              color: _SplashColors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
