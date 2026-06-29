import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class FeaturedSchoolsBanner extends StatefulWidget {
  const FeaturedSchoolsBanner({super.key});

  @override
  State<FeaturedSchoolsBanner> createState() => _FeaturedSchoolsBannerState();
}

class _FeaturedSchoolsBannerState extends State<FeaturedSchoolsBanner> {
  int _currentIndex = 0;

  // Placeholder data - we will replace with firestore data later
  final List<Map<String, String>> _featuredSchools = [
    {
      'name': 'University of Lagos',
      'location': 'Lagos, Nigeria',
      'tag': 'Top Ranked',
    },
    {
      'name': 'University of Nigeria, Nsukka',
      'location': 'Enugu, Nigeria',
      'tag': 'Top Ranked',
    },
    {
      'name': 'University of Ibadan',
      'location': 'Ibadan, Nigeria',
      'tag': 'First in Nigeria',
    },
    {
      'name': 'Ahmadu Bello University',
      'location': 'Zaria, Nigeria',
      'tag': 'Federal University',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // COMING BACK TO FINISH YOU UP
    return Column(
      children: [
        CarouselSlider.builder(
            itemCount: _featuredSchools.length,
            itemBuilder: (context, index, realIndex){
              final school = _featuredSchools[index];
               return _buildBannerCard(school);
            },
          options: CarouselOptions(
            height: 160.h,
            viewportFraction: 0.92,
              enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 4),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
        ),

        SizedBox(height: 12.h),

        // DOT INDICATORS
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _featuredSchools.length,
              (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: _currentIndex == index ? 20.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AppColors.primary
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(Map<String, String> school) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
          padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Tag
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                school['tag']!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // School Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school['name']!,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.background,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.background.withValues(alpha: 0.8),
                      size: 14.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      school['location']!,
                          style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.background.withValues(alpha: 0.8),
                    ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

