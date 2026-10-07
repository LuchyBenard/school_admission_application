import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_admission_application/core/constants/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<Map<String, String>> _slides;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    _slides = [
      {
        'title': l10n.onboardingSlide1Title,
        'subtitle': l10n.onboardingSlide1Subtitle,
        'image': 'assets/images/universitybuilding.jpg',
      },
      {
        'title': l10n.onboardingSlide2Title,
        'subtitle': l10n.onboardingSlide2Subtitle,
        'image': 'assets/images/studentUpload.png',
      },
    ];
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToNextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut
      );
    } else {
      // Save that onboarding has been seen
      final box = GetStorage();
      box.write('hasSeenOnboarding', true);
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _skip() {
    // Save that onboarding has been seen
    final box = GetStorage();
    box.write('hasSeenOnboarding', true);
    Navigator.pushReplacementNamed(context, '/login');
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: _currentPage < _slides.length - 1
                    ? GestureDetector(
                  onTap: _skip,
                  child: Text(
                    l10n.onboardingSkip,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    : const SizedBox(), // hides skip on the last slide
              ),
            ),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _buildSlide(
                    title: _slides[index]['title']!,
                    subtitle: _slides[index]['subtitle']!,
                    image: _slides[index]['image']!,
                  );
                },
              ),
            ),
            // Dot Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _currentPage == index ? 24.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? context.colors.primary
                        : context.colors.border,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ElevatedButton(
                onPressed: _goToNextPage,
                child: Text(
                  _currentPage < _slides.length - 1 ? l10n.onboardingNext : l10n.onboardingGetStarted,
                ),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),

      ),
    );
  }

  Widget _buildSlide({
    required String title,
    required String subtitle,
    required String image,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Image.asset(
            image,
            width: 260.w,
            height: 260.w,
            fit: BoxFit.contain,
          ), // that will be later
          SizedBox(height: 48.h),

          // Title
          Text(
            title,
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
