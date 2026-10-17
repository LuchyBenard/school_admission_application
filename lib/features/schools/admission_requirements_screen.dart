import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../l10n/generated/app_localizations.dart';
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
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _school = ModalRoute.of(context)!.settings.arguments as SchoolModel;
      _loadRequirements();
    }
  }

  void _loadRequirements({bool force = false}) {
    context.read<AdmissionRequirementProvider>().subscribeToRequirements(
          schoolName: _school.name,
          schoolCountry: _school.country,
          force: force,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: context.colors.textPrimary,
          ),
        ),
        title: Text(l10n.requirementsTitle, style: AppTextStyles.h2),
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
                  l10n.requirementsProgrammesHeading,
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
                if (reqProvider.isLoading && reqProvider.requirements.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  );
                }

                // Error state
                if (reqProvider.status == RequirementStatus.error &&
                    reqProvider.requirements.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.w,
                            color: context.colors.error,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            l10n.requirementsLoadFailed,
                            style: AppTextStyles.h3,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            reqProvider.errorMessage ??
                                'Check your connection and tap below to retry.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton.icon(
                            onPressed: () => _loadRequirements(force: true),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(l10n.requirementsTryAgain),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Empty state
                if (reqProvider.requirements.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadRequirements(force: true);
                      await Future.delayed(const Duration(milliseconds: 600));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: 380.h,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64.w,
                              color: context.colors.textHint,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              l10n.requirementsEmptyTitle,
                              style: AppTextStyles.h3,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              l10n.requirementsEmptyNote,
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            OutlinedButton.icon(
                              onPressed: () => _loadRequirements(force: true),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(l10n.requirementsTryAgain),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Requirements list with pull-to-refresh
                return RefreshIndicator(
                  onRefresh: () async {
                    _loadRequirements(force: true);
                    await Future.delayed(const Duration(milliseconds: 600));
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 40.h),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: reqProvider.requirements.length,
                    itemBuilder: (context, index) {
                      final req = reqProvider.requirements[index];
                      return _RequirementCard(requirement: req);
                    },
                  ),
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
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colors.border),
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
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    requirement.degreeLevel,
                    style: AppTextStyles.caption.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),

          // Cut-off score / entry criteria
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
                      _isNigeria
                          ? Icons.speed_outlined
                          : Icons.verified_outlined,
                      size: 16.w,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      requirement.cutOffScore.isNotEmpty
                          ? (_isNigeria
                              ? l10n.requirementsCutOffLabel(
                                  requirement.cutOffScore)
                              : l10n.requirementsEntryCriteriaLabel(
                                  requirement.cutOffScore))
                          : l10n.requirementsNoCutOff,
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

          // Structured requirement categories (international schools)
          if (requirement.categories.isNotEmpty)
            ...requirement.categories.map(
              (category) => _buildCategory(context, l10n, category),
            )

          // Legacy flat requirements fallback
          else if (requirement.requirements.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(l10n.requirementsRequirementsHeading, style: AppTextStyles.label),
            SizedBox(height: 6.h),
            ...requirement.requirements.map((r) => _buildItem(context, r)),
          ],
        ],
      ),
    );
  }

  bool get _isNigeria =>
      requirement.schoolCountry.trim().toLowerCase().contains('nigeria');

  Widget _buildCategory(
    BuildContext context,
    AppLocalizations l10n,
    RequirementCategory category,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _categoryIcon(category.key),
                size: 15.w,
                color: context.colors.primary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  _categoryTitle(l10n, category),
                  style: AppTextStyles.label,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ...category.items.map((r) => _buildItem(context, r)),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 14.w,
            color: context.colors.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _categoryTitle(AppLocalizations l10n, RequirementCategory category) {
    if (category.title.isNotEmpty) return category.title;
    switch (category.key) {
      case 'academic':
        return l10n.requirementsCategoryAcademic;
      case 'english':
        return l10n.requirementsCategoryEnglish;
      case 'tests':
        return l10n.requirementsCategoryTests;
      case 'documents':
        return l10n.requirementsCategoryDocuments;
      default:
        return l10n.requirementsRequirementsHeading;
    }
  }

  IconData _categoryIcon(String key) {
    switch (key) {
      case 'academic':
        return Icons.school_outlined;
      case 'english':
      case 'language':
        return Icons.translate_outlined;
      case 'tests':
        return Icons.fact_check_outlined;
      case 'documents':
        return Icons.description_outlined;
      default:
        return Icons.checklist_outlined;
    }
  }
}
