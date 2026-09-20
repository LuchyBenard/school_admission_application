import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/deadline_chip.dart';
import '../../models/school_model.dart';
import '../../providers/favorites_provider.dart';

class SchoolDetailScreen extends StatelessWidget {
  const SchoolDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final school = ModalRoute.of(context)!.settings.arguments as SchoolModel;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          school.name,
          style: AppTextStyles.h2,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Save to favorites
          Consumer<FavoritesProvider>(
            builder: (context, favProvider, child) {
              final isFavorite = favProvider.isFavorite(school);
              return GestureDetector(
                onTap: () {
                  final adding = !isFavorite;
                  favProvider.toggleFavorite(school);
                  if (adding) {
                    showToast(
                      '${school.name} saved to favorites',
                      backgroundColor: AppColors.success,
                      textStyle: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    );
                  } else {
                    showToast(
                      'Removed from favorites',
                      backgroundColor: AppColors.info,
                      textStyle: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.error : AppColors.textPrimary,
                    size: 22.w,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // School Name
              Text(school.name, style: AppTextStyles.displayMedium),
              SizedBox(height: 8.h),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textHint,
                    size: 16.w,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    school.state.isNotEmpty
                        ? '${school.state}, ${school.country}'
                        : school.country,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Info Section
              _buildInfoSection('Country', school.country),
              _buildInfoSection(
                'Location',
                school.state.isNotEmpty
                    ? '${school.state}, ${school.country}'
                    : school.country,
              ),
              _buildInfoSection('Website', school.website),

              if (school.description != null && school.description!.isNotEmpty)
                _buildInfoSection('About', school.description!),

              if (school.applicationFee != null && school.applicationFee!.isNotEmpty)
                _buildInfoSection('Application Fee', school.applicationFee!),

              if (school.deadline != null && school.deadline!.isNotEmpty) ...[
                _buildInfoSection('Deadline', school.deadline!),
                // Countdown chip
                if (!school.isDeadlinePassed) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DeadlineChip(deadline: school.deadlineDate),
                  ),
                  SizedBox(height: 16.h),
                ] else
                  _buildInfoSection(
                    'Status',
                    'Applications closed',
                    labelColor: AppColors.error,
                  ),
              ],

              SizedBox(height: 32.h),

              // Website button
              if (school.website.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () async {
                    String url = school.website;
                    if (!url.startsWith('http')) url = 'https://$url';
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.language_outlined),
                  label: const Text('Visit Website'),
                ),

              SizedBox(height: 12.h),

              // Apply Now button
              if (school.isDeadlinePassed) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showToast(
                        'Applications are closed for ${school.name}',
                        backgroundColor: AppColors.error,
                        textStyle: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textHint,
                      disabledForegroundColor: Colors.white,
                    ),
                    child: const Text('Applications Closed'),
                  ),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/application-form',
                        arguments: school,
                      );
                    },
                    child: const Text('Apply Now'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String value, {Color? labelColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: labelColor ?? AppColors.textHint,
            ),
          ),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.bodyLarge),
          const Divider(),
        ],
      ),
    );
  }
}
