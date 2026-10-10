import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_flags/country_flags.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/school_model.dart';
import '../../../providers/favorites_provider.dart';

/// Converts a country name to a 2-letter code where known ("" otherwise).
String _getCountryCode(String country) {
  const codes = {
    'Nigeria': 'NG',
    'United States': 'US',
    'United Kingdom': 'GB',
    'Ghana': 'GH',
    'Kenya': 'KE',
    'Canada': 'CA',
    'Australia': 'AU',
    'Germany': 'DE',
    'France': 'FR',
    'Netherlands': 'NL',
    'Sweden': 'SE',
    'Italy': 'IT',
    'Spain': 'ES',
  };
  return codes[country] ?? '';
}

/// Home section that shows the student's saved schools in a horizontal
/// scroll. Tapping a card opens the school detail; the heart removes it.
class SavedSchoolsSection extends StatelessWidget {
  const SavedSchoolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<FavoritesProvider>(
      builder: (context, favProvider, child) {
        final favorites = favProvider.favorites;

        if (favProvider.isLoading && favorites.isEmpty) {
          return SizedBox(
            height: 92.h,
            child: Center(
              child: CircularProgressIndicator(
                color: context.colors.primary,
                strokeWidth: 2.w,
              ),
            ),
          );
        }

        if (favorites.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  color: context.colors.textHint,
                  size: 20.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    l10n.homeNoSavedSchools,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 172.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: favorites.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final school = favorites[index];
              return _SavedSchoolCard(school: school);
            },
          ),
        );
      },
    );
  }
}

class _SavedSchoolCard extends StatelessWidget {
  final SchoolModel school;

  const _SavedSchoolCard({required this.school});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/school-detail',
          arguments: school,
        );
      },
      child: Container(
        width: 150.w,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    school.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: () {
                    context.read<FavoritesProvider>().removeFavorite(school);
                    showToast(
                      l10n.homeRemovedFromFavorites,
                      backgroundColor: AppColors.info,
                      textStyle: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    );
                  },
                  child: Icon(
                    Icons.favorite,
                    color: AppColors.error,
                    size: 18.w,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                if (_getCountryCode(school.country).isNotEmpty) ...[
                  CountryFlag.fromCountryCode(
                    _getCountryCode(school.country),
                    shape: const RoundedRectangle(4),
                    width: 20,
                    height: 14,
                  ),
                  SizedBox(width: 6.w),
                ],
                Expanded(
                  child: Text(
                    school.country,
                    style: AppTextStyles.caption.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}