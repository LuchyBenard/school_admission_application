import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_flags/country_flags.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/school_model.dart';

class SchoolCard extends StatelessWidget {
  final SchoolModel school;
  final VoidCallback;
  
  const SchoolCard({
    super.key,
    required this.school,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

