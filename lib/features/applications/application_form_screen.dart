import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ApplicationFormScreen extends StatelessWidget {
  const ApplicationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Applications', style: AppTextStyles.h2),
      ),
      body: Center(
        child: Text(
          'Applications - coming soon',
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }
}
