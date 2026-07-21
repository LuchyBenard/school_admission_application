import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  int _total = 0;
  int _pending = 0;
  int _underReview = 0;
  int _accepted = 0;
  int _rejected = 0;
  int _moreDocs = 0;
  bool _isLoading = true;

  @override
  void initstate() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final snapshot = await _firestore.collection('applications').get();
      setState(() {
        _total = snapshot.docs.length;
        _pending = snapshot.docs.where((d) => d['status'] == 'pending').length;
        _underReview = snapshot.docs.where((d) => d['status'] == 'under_review').length;
        _accepted = snapshot.docs.where((d) => d['status'] == 'accepted').length;
        _rejected = snapshot.docs.where((d) => d['status'] == 'rejected').length;
        _moreDocs = snapshot.docs.where((d) => d['status'] == 'more_documents').length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context,
        '/admin-login',
        (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
          automaticallyImplyLeading: false,
        title: Text('Admin Dashboard', style: AppTextStyles.h2),
        actions: [
          GestureDetector(
            onTap: _logout,
            child: Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: Icon(
                Icons.logout,
                color: AppColors.error,
                size: 22.w,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
        ? Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                'Welcome, Admin 👋',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.background,
                ),
              ),
              SizedBox(height: 4.h),
                  Text(
                    'You have $_pending pending applications to review',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.background
                          .withValues(alpha: 0.8),
                    ),
            ),
          ],
        ),
      ),
        SizedBox(height: 24.h),

        Text('Overview', style: AppTextStyles.h2),
        SizedBox(height: 16.h),

        // Stats Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              'Total',
              _total,
              AppColors.primary,
              Icons.assignment_outlined,
            ),
            _buildStatCard(
              'Pending',
              _pending,
              AppColors.info,
              Icons.access_time_outlined,
            ),
            _buildStatCard(
              'Under Review',
              _underReview,
              AppColors.warning,
              Icons.hourglass_empty_outlined,
            ),
            _buildStatCard(
              'Accepted',
              _accepted,
              AppColors.success,
              Icons.check_circle_outlined,
            ),
            _buildStatCard(
              'Rejected',
              _rejected,
              AppColors.error,
              Icons.cancel_outlined,
            ),
            _buildStatCard(
              'Docs Needed',
              _moreDocs,
              AppColors.primaryLight,
              Icons.folder_outlined,
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // Quick Action
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context, '/admin-applicants'
              );
            },
            icon: Icon(Icons.people_outline),
            label: Text('View All Applicants'),
          ),
        ),
        ],
        ),
      ),
        );
  }

  Widget _buildStatCard(
      String label, int count, Color color, IconData icon
      ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: AppTextStyles.displayMedium.copyWith(
                  color: color,
                  fontSize: 28,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
