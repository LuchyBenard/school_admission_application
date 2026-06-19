import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Home',
          style: AppTextStyles.h2,
        ),
      ),
        body: Center(
          child: Text(
            'Home screen coming soon...',
            style: AppTextStyles.bodyMedium,
          ),
        ),
    );
  }
}
