import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'widgets/featured_schools_banner.dart';
import 'widgets/application_summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final String firstName = authProvider.userProfile?['fullName']
    ?.toString()
    .split(' ')
    .first ??
    'Student';

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
