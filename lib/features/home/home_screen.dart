import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';
import 'package:school_admission_application/providers/application_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import 'widgets/featured_schools_banner.dart';
import 'widgets/saved_schools_section.dart';
import 'widgets/application_summary_card.dart';
import '../../providers/notification_provider.dart';
import '../../core/widgets/skeleton_loader.dart';

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
      context.read<ApplicationProvider>().subscribeToApplications();
      context.read<NotificationProvider>().subscribeToNotifications();
      context.read<FavoritesProvider>().subscribeToFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    final String firstName = authProvider.userProfile?['fullName']
            ?.toString()
            .split(' ')
            .first ??
        'Student';

    return Scaffold(
      backgroundColor: context.colors.background,
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
                        l10n.homeGreeting(firstName),
                        style: AppTextStyles.displayMedium,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.homeSearchTitle,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),

                  // Notification bell
                  Consumer<NotificationProvider>(
                    builder: (context, notifProvider, child) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: context.colors.surface,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: context.colors.border),
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: context.colors.textPrimary,
                                size: 22.w,
                              ),
                            ),
                            // Badge - only shows where there are unread notifications
                            if (notifProvider.unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 18.w,
                                  height: 18.w,
                                  decoration: const BoxDecoration(
                                      color: AppColors.error, shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(
                                      notifProvider.unreadCount > 9
                                          ? '9+'
                                          : notifProvider.unreadCount.toString(),
                                      style: AppTextStyles.caption.copyWith(
                                        color: context.colors.background,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              // Featured Schools
              Text(l10n.homeFeaturedSchools, style: AppTextStyles.h2),
              SizedBox(height: 16.h),
              const FeaturedSchoolsBanner(),

              SizedBox(height: 28.h),

              // Saved Schools
              Text(l10n.homeSavedSchools, style: AppTextStyles.h2),
              SizedBox(height: 16.h),
              const SavedSchoolsSection(),

              SizedBox(height: 28.h),

              // Application summary
              Text(l10n.homeMyApplications, style: AppTextStyles.h2),
              SizedBox(height: 16.h),

              Consumer<ApplicationProvider>(
                builder: (context, appProvider, child) {
                  if (appProvider.isLoading) {
                    return const HomeSkeleton();
                  }

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.1,
                    children: [
                      ApplicationSummaryCard(
                        count: appProvider.totalApplied.toString(),
                        label: l10n.homeStatsTotalApplied,
                        color: context.colors.primary,
                        icon: Icons.assignment_outlined,
                      ),
                      ApplicationSummaryCard(
                        count: appProvider.underReview.toString(),
                        label: l10n.homeStatsUnderReview,
                        color: AppColors.warning,
                        icon: Icons.hourglass_empty_outlined,
                      ),
                      ApplicationSummaryCard(
                        count: appProvider.accepted.toString(),
                        label: l10n.homeStatsAccepted,
                        color: AppColors.success,
                        icon: Icons.check_circle_outline,
                      ),
                      ApplicationSummaryCard(
                        count: appProvider.rejected.toString(),
                        label: l10n.homeStatsRejected,
                        color: AppColors.error,
                        icon: Icons.cancel_outlined,
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 28.h),

              // Quick Actions
              Text(l10n.homeQuickActions, style: AppTextStyles.h2),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      context: context,
                      icon: Icons.search,
                      label: l10n.homeFindSchools,
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
                      label: l10n.homeMyDocuments,
                      onTap: () {
                        final appProvider =
                            context.read<ApplicationProvider>();
                        appProvider.subscribeToApplications();
                        final apps = appProvider.applications;
                        if (apps.isEmpty) {
                          showToast(
                            l10n.homeNoApplicationsYet,
                            backgroundColor: AppColors.warning,
                            textStyle: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white),
                          );
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          '/document-upload',
                          arguments: apps.first.id,
                        );
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
          color: context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: context.colors.primary,
              size: 22.w,
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
