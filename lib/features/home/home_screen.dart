import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:school_admission_application/providers/application_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'widgets/featured_schools_banner.dart';
import 'widgets/application_summary_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onFindSchoolsTapped;

  const HomeScreen({
    super.key,
    this.onFindSchoolsTapped,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadApplicationStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final appProvider = context.watch<ApplicationProvider>();
    final String firstName = authProvider.userProfile?['fullName']
        ?.toString()
        .split(' ')
        .first ??
        'Student';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Greeting Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $firstName 👋',
                        style: AppTextStyles.displayMedium,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Find and apply to your dream school',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),

                  // Notification bell
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textPrimary,
                        size: 22.w,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              // Featured Schools
              Text('Featured Schools', style: AppTextStyles.h2),
              SizedBox(height: 16.h),
              const FeaturedSchoolsBanner(),

              SizedBox(height: 28.h),

              // Application summary
              Text('My Applications', style: AppTextStyles.h2),
              SizedBox(height: 16.h),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.1,
                children: [
                  ApplicationSummaryCard(
                    count: appProvider.totalApplied.toString(),
                    label: 'Total Applied',
                    color: AppColors.primary,
                    icon: Icons.assignment_outlined,
                  ),
                  ApplicationSummaryCard(
                    count: appProvider.underReview.toString(),
                    label: 'Under Review',
                    color: AppColors.warning,
                    icon: Icons.hourglass_empty_outlined,
                  ),
                  ApplicationSummaryCard(
                    count: appProvider.accepted.toString(),
                    label: 'Accepted',
                    color: AppColors.success,
                    icon: Icons.check_circle_outline, // ← fixed
                  ),
                  ApplicationSummaryCard(
                    count: appProvider.rejected.toString(),
                    label: 'Rejected',
                    color: AppColors.error,
                    icon: Icons.cancel_outlined,
                  ),
                ], // ← closes children list
              ), // ← closes GridView.count

              SizedBox(height: 28.h),

              // Quick Actions
              Text('Quick Actions', style: AppTextStyles.h2),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      context: context,
                      icon: Icons.search,
                      label: 'Find Schools',
                      onTap: () {
                        widget.onFindSchoolsTapped?.call();
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildQuickAction(
                      context: context,
                      icon: Icons.description_outlined,
                      label: 'My Documents',
                      onTap: () {
                        // Navigate to documents later
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 22.w,
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}