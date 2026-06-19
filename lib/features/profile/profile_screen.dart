import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.h2,
        ),
        ),
        body: Center(
          child: Text(
            'User Profile coming soon',
            style: AppTextStyles.bodyMedium,
          ),
        ),
    );
  }
}
