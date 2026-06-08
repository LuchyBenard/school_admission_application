import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_admission_application/core/constants/app_colors.dart';
import 'package:school_admission_application/core/constants/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map> <String, String> _slides = [
    {
    'title': 'Find Your Perfect School',
    'subtitle': 'Explore thousands of universities and institutions across Nigeria and worldwide all in one place.',
    'image': 'assets/images/' // Will attach a picture later to it.
    }
    {
      'title': 'Apply & Track With Ease',
      'subtitle': 'Submit applications, upload documents, pay fees and get real-time updates on your admission status.',
      'image': 'assets/images/' // also will attach picture to this later.
    },
  ];

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
      // Last slide - go to login

    Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/login');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  'Skip',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              : SizedBox(), // hides skip on the last slide

              //Pageview
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return _buildSlide(
                      title: _slides[index] ['title'] !,
                      subtitle: _slides[index] ['subtitle']!,
                      image: _slides[index] ['image']!,
                    );
                  },
                  ), 
                ),

                // Dot Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: _currentPage == index ? 24.w : 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _currentPage == index  
                        ? AppColors.primary
                        : AppColors.border,
                        borderRadius: BorderRadius.circular(4.r),                    
                        ),
                       ),
                ),
            ),

            SizedBox(height: 40.h),

            // Botton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ElevatedButton(
                onPressed: _goToNextPage,
                child: Text(
                  _currentPage < _slides.length -1 ? 'Next' : 'Get Started',
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
          Image.asset() // that will be later
          
        ],
      ),
    )
  }
}
