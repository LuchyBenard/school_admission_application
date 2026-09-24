import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../../providers/offline_queue_provider.dart';

/// Shows connectivity / pending-sync state:
///  - offline          -> amber banner, changes are queued locally
///  - online + queued  -> banner with a manual retry button
///  - syncing          -> progress banner
///  - online, queue empty -> nothing
///
/// Used on the dashboard and application screens so the user knows
/// their submission isn't lost when connectivity drops.
class OfflineSyncBanner extends StatelessWidget {
  final bool showRetryButton;

  const OfflineSyncBanner({super.key, this.showRetryButton = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineQueueProvider>(
      builder: (context, queue, child) {
        final online = queue.isOnline;
        final pending = queue.pendingCount;
        final syncing = queue.isSyncing;

        if (online && !syncing && pending == 0) {
          return const SizedBox.shrink();
        }

        final IconData icon;
        final Color color;
        final String title;
        final String subtitle;

        if (!online) {
          icon = Icons.cloud_off_outlined;
          color = AppColors.warning;
          title = 'You are offline';
          subtitle = pending > 0
              ? '$pending change${pending == 1 ? '' : 's'} queued and will sync automatically when you are back online.'
              : 'Changes will be queued and synced when you are back online.';
        } else if (syncing) {
          icon = Icons.sync_outlined;
          color = AppColors.info;
          title = 'Syncing your changes';
          subtitle = '$pending pending item${pending == 1 ? '' : 's'} remaining';
        } else {
          icon = Icons.cloud_queue_outlined;
          color = AppColors.info;
          title = 'You are back online';
          subtitle = '$pending change${pending == 1 ? '' : 's'} waiting to sync';
        }

        return Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              syncing
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        color: color,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(icon, color: color, size: 20.w),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.label.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (showRetryButton && online && !syncing && pending > 0)
                GestureDetector(
                  onTap: () => context.read<OfflineQueueProvider>().syncNow(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Sync',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}