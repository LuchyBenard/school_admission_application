import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_flags/country_flags.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/school_model.dart';

class SchoolCard extends StatelessWidget {
  final SchoolModel school;
  final VoidCallback onTap;

  const SchoolCard({
    super.key,
    required this.school,
    required this.onTap,
  });

  // Converts country name to 2-letter country code for flag
  String _getCountryCode(String country) {
    const Map<String, String> countryCodes = {
      'Nigeria': 'NG',
      'United States': 'US',
      'Canada': 'CA',
      'United Kingdom': 'GB',
      'Ghana': 'GH',
      'Kenya': 'KE',
      'South Africa': 'ZA',
      'Australia': 'AU',
      'Germany': 'DE',
      'France': 'FR',
    };
    return countryCodes[country] ?? 'NG';
  }
  Widget _buildFlag() {
    return Padding (
      padding: EdgeInsets.all(8.w),
      child: CountryFlag.fromCountryCode(
        _getCountryCode(school.country),
        shape: const RoundedRectangle(8),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // flag //logo
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: school.imageUrl != null
                    ? Image.network(
                  school.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFlag(),
                )
                    : _buildFlag(),
              ),
            ),

            SizedBox(width: 12.w),

            // School Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // School Name
                  Text(
                    school.name,
                    style: AppTextStyles.h3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.textHint,
                        size: 14.w,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          school.state.isNotEmpty
                              ? '${school.state}, ${school.country}'
                              : school.country,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Bottom Row
                  Row(
                    children: [
                      // Website chip
                      if (school.website.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Website',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      Spacer(),

                      // Featured badge
                      if (school.isFeatured)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Featured',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textHint,
              size: 14.w,
            ),
          ],
        ),
      ),
    );
  }
}

