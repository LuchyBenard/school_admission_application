import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/notification_provider.dart';
import '../../providers/push_navigation_provider.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().subscribeToNotifications();
    });
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Clear All', style: AppTextStyles.h2),
        content: Text(
          'Are you sure you want to delete all notifications? This cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<NotificationProvider>()
                  .clearAllNotifications();
            },
            child: Text(
              'Clear All',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: context.colors.textPrimary,
          ),
        ),
        title: Text('Notifications', style: AppTextStyles.h2),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, child) {
              if (notifProvider.notifications.isEmpty) {
                return const SizedBox();
              }
              return Row(
                children: [
                  // Mark all as read
                  if (notifProvider.unreadCount > 0)
                    GestureDetector(
                      onTap: () {
                        notifProvider.markAllAsRead();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: Text(
                          'Mark all read',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Clear all
                  GestureDetector(
                    onTap: _showClearAllDialog,
                    child: Padding(
                      padding: EdgeInsets.only(right: 24.w),
                      child: Text(
                        'Clear',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notifProvider, child) {
          // Loading state
          if (notifProvider.isLoading) {
            return ListView.builder(
              padding: EdgeInsets.all(24.w),
              itemCount: 5,
              itemBuilder: (_, _) => Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        color: context.colors.border,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120.w,
                            height: 12,
                            decoration: BoxDecoration(
                              color: context.colors.border,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            height: 10,
                            decoration: BoxDecoration(
                              color: context.colors.border,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Empty state
          if (notifProvider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 64.w,
                    color: context.colors.textHint,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No notifications yet',
                    style: AppTextStyles.h3,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'You will be notified when there are\nupdates on your applications',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Notifications list
          return ListView.separated(
            padding: EdgeInsets.all(24.w),
            itemCount: notifProvider.notifications.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final notification =
              notifProvider.notifications[index];
              return _buildNotificationTile(
                  notification, notifProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(
      NotificationModel notification,
      NotificationProvider notifProvider,
      ) {
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.delete_outline,
          color: context.colors.background,
          size: 24.w,
        ),
      ),
      onDismissed: (_) {
        notifProvider.deleteNotification(notification.id);
      },
      child: GestureDetector(
        onTap: () {
          // Marks the notification as read and opens the application it is
          // about — same behaviour as tapping the push notification.
          context.read<PushNavigationProvider>().openNotification(notification);
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            // Unread = slightly highlighted background
            color: isUnread
                ? context.colors.surfaceAlt
                : context.colors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isUnread
                  ? context.colors.primaryLight.withValues(alpha: 0.4)
                  : context.colors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 20.w,
                ),
              ),

              SizedBox(width: 12.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),

                        // Unread dot
                        if (isUnread)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: context.colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      notification.message,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6.h),

                    Text(
                      _formatTime(notification.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: context.colors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'under_review':
        return AppColors.warning;
      case 'withdrawn':
        return context.colors.textSecondary;
      case 'deadline':
        return AppColors.error;
      default:
        return context.colors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'under_review':
        return Icons.hourglass_empty_outlined;
      case 'withdrawn':
        return Icons.do_not_disturb_on_outlined;
      case 'deadline':
        return Icons.alarm_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${time.day} ${months[time.month - 1]}';
  }
}
