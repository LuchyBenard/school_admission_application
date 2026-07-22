import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_admission_application/features/applications/widgets/application_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/application_model.dart';
import 'widgets/applicant_card.dart';

class ApplicantListScreen extends StatefulWidget {
  const ApplicantListScreen({super.key});

  @override
  State<ApplicantListScreen> createState() => _ApplicantListScreenState();
}

class _ApplicantListScreenState extends State<ApplicantListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ApplicationModel> _applications = [];
  List<ApplicationModel> _filtered = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Pending',
    'Under Review',
    'Accepted',
    'Rejected',
    'Docs Needed',
  ];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  @override
  void dispose () {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    try {
      final snapshot = await _firestore
          .collection('applications')
          .orderBy('createdAt', descending: true)
          .get();

      _applications = snapshot.docs
          .map((doc) =>
          ApplicationModel.fromFirestore(
            doc.data(),
            doc.id,
          ))
          .toList();

      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    String statusFilter = '';
    switch (_selectedFilter) {
      case 'Pending': statusFilter = 'pending';
      break;
      case 'Under Review': statusFilter = 'under_review';
      break;
      case 'Accepted': statusFilter = 'accepted';
      break;
      case 'Rejected': statusFilter = 'rejected';
      break;
      case 'Docs Needed': statusFilter = 'more_documents';
      break;
    }

    setState(() {
      _filtered = _applications.where((app) {
        final matchesFilter = _selectedFilter == 'All' || app.status == statusFilter;
        final matchesSearch = _searchController.text.isEmpty || app.fullName.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        ) || app.courseOfStudy.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
        return matchesFilter && matchesSearch;
      }).toList();
      _isLoading = false;
    });
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
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text('All Applications', style: AppTextStyles.h2),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 8.h,
            ),
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.bodyLarge,
              onChanged: (_) => _applyFilters(),
              decoration: InputDecoration(
                hintText: 'Search by name or course...',
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textHint,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                  child: Icon(
                    Icons.close,
                    color: AppColors.textHint,
                  ),
                )
                    : null,
              ),
            ),
          ),
          
          // Filter Chips
          SizedBox(
            height: 36.h,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      _applyFilters();
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: AppTextStyles.label.copyWith(
                        color: isSelected
                            ? AppColors.background
                            : AppColors.textSecondary,
                        fontWeight:isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // List
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
                : _filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 48.w,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No Applications found',
                    style: AppTextStyles.h3,
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                return ApplicationCard(
                    application: _filtered[index],
                    onTap: () {
                      Navigator.pushNamed(
                          context,
                        '/admin-applicant-detail',
                        arguments: _filtered[index],
                      );
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
