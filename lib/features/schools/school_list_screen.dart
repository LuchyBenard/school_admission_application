import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../core/constants/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';
import '../../core/widgets/skeleton_loader.dart';
import 'widgets/school_card.dart';
import '../../l10n/generated/app_localizations.dart';

class SchoolListScreen extends StatefulWidget {
  const SchoolListScreen({super.key});

  @override
  State<SchoolListScreen> createState() => _SchoolListScreenState();
}

class _SchoolListScreenState extends State<SchoolListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load Nigerian Schools by default when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchoolProvider>().loadSchools();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
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
                    Text(l10n.schoolsTitle, style: AppTextStyles.displayMedium),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.schoolsListSubtitle,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyLarge,
                  onChanged: (value) {
                    context.read<SchoolProvider>().search(value);
                  },
                  decoration: InputDecoration(
                    hintText: l10n.schoolsSearchHint,
                    prefixIcon: Icon(
                      Icons.search,
                      color: context.colors.textHint,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        context.read<SchoolProvider>().clearSearch();
                      },
                      child: Icon(
                        Icons.close,
                        color: context.colors.textHint,
                      ),
                    )
                        : null,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Country filter chips
              Consumer<SchoolProvider> (
                builder: (context, schoolProvider, child) {
                  return SizedBox(
                    height: 36.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      itemCount: schoolProvider.availableCountries.length,
                      separatorBuilder: (_, _) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final country =
                            schoolProvider.availableCountries[index];
                        final isSelected = schoolProvider.selectedCountry == country;

                        return GestureDetector(
                          onTap: () {
                            schoolProvider.filterByCountry(country);
                          },
                          child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.colors.primary
                                  : context.colors.surface,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected
                                    ? context.colors.primary
                                    : context.colors.border,
                              ),
                            ),
                            child: Text(
                              country,
                              style: AppTextStyles.label.copyWith(
                                color: isSelected
                                    ? context.colors.background
                                    : context.colors.textSecondary,
                                fontWeight: isSelected
                              ? FontWeight.w600
                                : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              SizedBox(height: 16.h),
              // Schools List
              Expanded(
                child: Consumer<SchoolProvider>(
                  builder: (context, schoolProvider, child) {
                    // Loading State
                    if (schoolProvider.isLoading) {
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        itemCount: 6,
                        itemBuilder: (_, _) => SchoolCardSkeleton(),
                      );
                    }

                    // error State
                    if (schoolProvider.status == SchoolStatus.error) {
                      return Center (
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon (
                              Icons.wifi_off_outlined,
                              size: 48.w,
                              color: context.colors.textHint,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              l10n.schoolsLoadFailed,
                              style: AppTextStyles.h3,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              l10n.schoolsOffline,
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24.h),
                            ElevatedButton(
                              onPressed: () {
                                context.read<SchoolProvider>()
                                    .loadSchools();
                              },
                              child: Text(l10n.schoolsTryAgain),
                            ),
                          ],
                        ),
                      );
                    }

                    // Empty State
                    if (schoolProvider.schools.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 48.w,
                          color: context.colors.textHint,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          l10n.schoolsEmptyTitle,
                          style: AppTextStyles.h3,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          l10n.schoolsEmptyMessage,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                          ],
                        ),
                      );
                    }

                    // Schools list
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      itemCount: schoolProvider.schools.length,
                      itemBuilder: (context, index) {
                        final school = schoolProvider.schools[index];
                        return SchoolCard(
                          school: school,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/school-detail',
                              arguments: school,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}
