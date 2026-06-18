import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';

class SchoolListScreen extends StatelessWidget {
  const SchoolListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Schools',
          style: AppTextStyles.h2,
        ),
        body: Center(
          child: Text(
            'School Listing - coming soon',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ),
    );
  }
}
