import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/school_model.dart';

class SchoolDetailScreen extends StatelessWidget {
  const SchoolDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final school = ModalRoute.of(context)!.settings.arguments as SchoolModel;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(school.name, style: AppTextStyles.h2),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Padding(
          padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Country',
              style: AppTextStyles.label,
            ),
            SizedBox(height: 4.h),
            Text(school.country, style: AppTextStyles.bodyLarge),
            SizedBox(height: 16.h),
            Text('Location', style: AppTextStyles.label),
            SizedBox(height: 4.h),
            Text(
              school.state.isNotEmpty
                  ? '${school.state}, ${school.country}'
                  : school.country,
              style: AppTextStyles.bodyLarge,
            ),
            SizedBox(height: 16.h),
            Text(school.website, style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
            )),
            SizedBox(height: 32.h),
            ElevatedButton(
                onPressed: () {
                  // Apply button - coming soon
                },
              child: Text('Apply Now'),
            ),
          ],
        ),
      ),
    );
  }
}
