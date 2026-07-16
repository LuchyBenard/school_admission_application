import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/application_provider.dart';
import 'widgets/application_card.dart';

class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Pending',
    'Under Review',
    'Accepted',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadApplications();
    });
  }

  String _filterToStatus(String filter) {
    switch (filter) {
      case 'Pending':
        return 'pending';
      case 'Under Review':
        return 'under_review';
      case 'Accepted':
        return 'accepted';
      case 'Rejected':
        return 'rejected';
      default:
        return 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 16.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Applications',
                    style: AppTextStyles.displayMedium,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Track all your admission applications',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),

            // Filter Chips
            SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: AppTextStyles.label.copyWith(
                            color: isSelected
                                ? AppColors.background
                                : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),

            // Application List
            Expanded(
              child: Consumer<ApplicationProvider>(
                builder: (context, appProvider, child) {
                  // Loading state
                  if (appProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  // Error State
                  if (appProvider.status == ApplicationStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.w,
                            color: AppColors.textHint,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load applications',
                            style: AppTextStyles.h3,
                          ),
                          SizedBox(height: 8.h),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ApplicationProvider>().loadApplications();
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter applications
                  final filtered = _selectedFilter == 'All'
                      ? appProvider.applications
                      : appProvider.applications
                          .where((a) => a.status == _filterToStatus(_selectedFilter))
                          .toList();

                  // empty State
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64.w,
                            color: AppColors.textHint,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            _selectedFilter == 'All'
                                ? 'No Applications yet'
                                : 'No $_selectedFilter applications',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          if (_selectedFilter == 'All') ...[
                            SizedBox(height: 24.h),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/dashboard', // Or school list
                                );
                              },
                              child: const Text('Browse Schools'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  // Applications list
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final application = filtered[index];
                      return ApplicationCard(
                        application: application,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/application-detail',
                            arguments: application,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
