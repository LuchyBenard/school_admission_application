import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/school_model.dart';

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

              if (school.deadline != null && school.deadline!.isNotEmpty)
                _buildInfoSection('Deadline', school.deadline!),

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

  Widget _buildInfoSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              )),
          const Divider(),
        ],
      ),
    );
  }
}
