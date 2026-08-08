import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double> (begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
              opacity: _animation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(widget.borderRadius.r),
              ),
            ),
          );
        }
    );
  }
}

// Pre-built skeleton layouts
class SchoolCardSkeleton extends StatelessWidget {
  const SchoolCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SkeletonLoader(width: 56.w, height: 56.w, borderRadius: 12),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: double.infinity, height: 16.h),
                SizedBox(height: 8.h),
                SkeletonLoader(width: 120.w, height: 12.h),
                SizedBox(height: 8.h),
                SkeletonLoader(width: 80.w, height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ApplicationCardSkeleton extends StatelessWidget {
  const ApplicationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: 180.w, height: 16.h),
              SkeletonLoader(width: 80.w, height: 24.h, borderRadius: 20),
                    ],
          ),
                    SizedBox(height: 10.h),
                    SkeletonLoader(width: 140.w, height: 12.h),
                    SizedBox(height: 6.h),
                    SkeletonLoader(width: 100.w, height: 12.h),
                    SizedBox(height: 10.h),
                    SkeletonLoader(width: 120.w, height: 10.h),
                  ],
                ),
              );
  }
}

class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SkeletonLoader(width: 40.w, height: 40.w, borderRadius: 10),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: double.infinity, height: 14.h),
                SizedBox(height: 6.h),
                SkeletonLoader(width: 200.w, height: 12.h),
                SizedBox(height: 6.h),
                SkeletonLoader(width: 80.w, height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.1,
      children: List.generate(
        4,
          (_) => Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 36.w, height: 36.w, borderRadius: 10),
                const Spacer(),
                SkeletonLoader(width: 50.w, height: 28.h),
                SizedBox(height: 6.h),
                SkeletonLoader(width: 80.w, height: 12.h),
              ],
            ),
          ),
      ),
    );
  }
}




