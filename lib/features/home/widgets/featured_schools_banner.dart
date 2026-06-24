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
              // return _buildBannerCard(school);
              return Container(
                width: double.infinity,
                height: 100.h,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
              );
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
            }
          ),
        ),

        SizedBox(height: 12.h),

        // DOT INDICATORS

      ],

    );
  }
}

