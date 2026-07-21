import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return Scaffold();
  }
}
