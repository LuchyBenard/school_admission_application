import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/admission_requirement_model.dart';
import '../../models/school_model.dart';
import '../../providers/admission_requirement_provider.dart';

class AdmissionRequirementsScreen extends StatefulWidget {
  const AdmissionRequirementsScreen({super.key});

  @override
  State<AdmissionRequirementsScreen> createState() =>
      _AdmissionRequirementsScreenState();
}

class _AdmissionRequirementsScreenState
    extends State<AdmissionRequirementsScreen> {
  late SchoolModel _school;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _school = ModalRoute.of(context)!.settings.arguments as SchoolModel;

    context.read<AdmissionRequirementProvider>().subscribeToRequirements(
          schoolName: _school.name,
          schoolCountry: _school.country,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text('Admission Requirements', style: AppTextStyles.h2),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // School header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_school.name, style: AppTextStyles.displayMedium),
                SizedBox(height: 4.h),
                Text(
                  'Programmes and cut-off scores',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          Expanded(
            child: Consumer<AdmissionRequirementProvider>(
              builder: (context, reqProvider, child) {
                // Loading state
                if (reqProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                // Error state
                if (reqProvider.status == RequirementStatus.error) {
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
                          'Failed to load requirements',
                          style: AppTextStyles.h3,
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<AdmissionRequirementProvider>()
                                .subscribeToRequirements(
                                  schoolName: _school.name,
                                  schoolCountry: _school.country,
                                );
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                // Empty state
                if (reqProvider.requirements.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64.w,
                            color: AppColors.textHint,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No requirements published yet',
                            style: AppTextStyles.h3,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Check the school website or contact the admission office for the latest requirements.',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Requirements list
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 40.h),
                  itemCount: reqProvider.requirements.length,
                  itemBuilder: (context, index) {
                    final req = reqProvider.requirements[index];
                    return _RequirementCard(requirement: req);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementCard extends StatelessWidget {
  final AdmissionRequirementModel requirement;

  const _RequirementCard({required this.requirement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program name + degree level
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  requirement.program,
                  style: AppTextStyles.h3,
                ),
              ),
              if (requirement.degreeLevel.isNotEmpty) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    requirement.degreeLevel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),

          // Cut-off score
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.speed_outlined,
                      size: 16.w,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      requirement.cutOffScore.isNotEmpty
                          ? 'Cut-off: ${requirement.cutOffScore}'
                          : 'No cut-off published',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Additional requirements
          if (requirement.requirements.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text('Requirements', style: AppTextStyles.label),
            SizedBox(height: 6.h),
            ...requirement.requirements.map(
              (r) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 14.w,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        r,
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}