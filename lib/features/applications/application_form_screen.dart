import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/application_model.dart';
import '../../models/school_model.dart';
import '../../providers/application_provider.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1 controllers
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
 String? _selectedGender;
  final _nationalityController = TextEditingController();

  // Step 2 controllers
  String? _selectedQualification;
  final _gradeController = TextEditingController();
  final _graduationYearController = TextEditingController();

  // Step 3 controllers
  final _courseController = TextEditingController();
  String? _selectedEntryLevel;
  final _sessionController = TextEditingController();

  // Form keys for each step
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  SchoolModel? _school;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _school =
        ModalRoute.of(context)?.settings.arguments as SchoolModel?;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _gradeController.dispose();
    _graduationYearController.dispose();
    _courseController.dispose();
    _sessionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Validate current step
    bool isValid = false;
    if (_currentStep == 0) isValid = _step1Key.currentState!.validate();
    if (_currentStep == 1) isValid = _step2Key.currentState!.validate();
    if (_currentStep == 2) isValid = _step3Key.currentState!.validate();

    if (!isValid) return;

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut
      );
      setState(() => _currentStep++);
    } else {
      _submitApplication();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  void _submitApplication() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final application = ApplicationModel(
      userId: uid,
        schoolName: _school?.name ?? '',
        schoolCountry: _school?.country ?? '',
        fullName: _fullNameController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        gender: _selectedGender ?? '',
        nationality: _nationalityController.text.trim(),
        qualification: _selectedQualification ?? '',
        grade: _gradeController.text.trim(),
        graduationYear: _graduationYearController.text.trim(),
        courseOfStudy: _courseController.text.trim(),
        entryLevel: _selectedEntryLevel ?? '',
        session: _sessionController.text.trim(),
    );

    final success = await context.read<ApplicationProvider>()
        .submitApplication(application);

    if (!mounted) return;

    if (success) {
      showToast(
        'Application submitted successfully!',
        backgroundColor: AppColors.success,
        textStyle:
          AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
      Navigator.pop(context);
    } else {
      showToast(
        'Failed to submit application. Please try again.',
        backgroundColor: AppColors.error,
        textStyle:
          AppTextStyles.bodySmall.copyWith(color: Colors.white),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.background,
              ),
            ),
child: child!,
);
  },
);

    if (picked != null) {
      setState(() {
        _dobController.text =
         '${picked.day}/${picked.month}/${picked.year}';
      });
    }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: _currentStep > 0
              ? _previousStep
              : () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
            _school?.name ?? 'Application Form',
            style: AppTextStyles.h3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis, ,
        ),
      ),
      body: Column(
        children: [
          //Progress indicator
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),

          // Bottom button
          _buildBottomButton(),
        ],
      ),
    );
  }
  Widget _buildProgreesIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: AppTextStyles.label,
              ),
              Text(
                _stepTitle(),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
                ),

          SizedBox(height: 8.h),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child:  LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6,
            ),
            ),
            ],
      ),
              );

  }

  String _stepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Personal Details';
      case 1:
        return 'Academic Details';
      case 2:
        return 'Programme Selection';
      default:
        return '';
    }
  }

  // Step 1 - Personal Details
Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),

            Text(
              'Personal Details',
              style: AppTextStyles.h2,
            ),
        SizedBox(height: 4.h),

        Text(
          'Tell us about yourself',
          style: AppTextStyles.bodyMedium,
    ),
          SizedBox(height: 24.h),

          // Full Name
          Text('Full Name', style: AppTextStyles.label),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _fullNameController,
            style: AppTextStyles.bodyLarge,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Icon(
                Icons.person_outline,
                color: AppColors.textHint,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),

        SizedBox(height: 16.h),

        // Date of Birth
        Text('Date of Birth', style: AppTextStyles.label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _selectDate,
          child: AbsorbPointer(
              TextFormField(
                controller: _dobController,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Select your date of birth',
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.textHint,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
            ),
                ),

        SizedBox(height: 16.h),

        // Gender
        Text('Gender', style: AppTextStyles.label),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.wc_outlined,
              color: AppColors.textHint,
            ),
            hint: Text(
              'Select gender',
              style: AppTextStyles.hint,
            ),
            items: ['Male', 'Female', 'Prefer not to say']
              .map((g) => DropdownMenuItem(
              value: g,
            child:  Text(g),
            ))
              .toList(),
          onChanged: (value){
              setState (() => _selectedGender = value);
          }
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your gender';
            }
            return null;
          },
        ),
         SizedBox(height: 16.h),

        // Nationality
        Text('Nationality', style: AppTextStyles.label),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _nationalityController,
          style: AppTextStyles.bodyLarge,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g Nigerian',
            prefixIcon: Icon(
              Icons.flag_outlined,
              color: AppColors.textHint,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
            return 'Please enter your nationality';
          }
          return null;
        },
        ),

          SizedBox(height: 40.h),

          // Step 2 - Academic Details
          Widget _buildStep2() {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _step2Key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),

    Text(
    'Academic Details',
    style: AppTextStyles.h2,
    ),
    SizedBox(height: 4.h),
    Text(
    'Tell us about your educational background',
    style: AppTextStyles.bodyMedium,
    ),
    SizedBox(height: 24.h),

    // Qualification
    Text(
    'Highest Qualification',
    style: AppTextStyles.label,
    ),
    SizedBox(height: 8.h),
    DropdownButtonFormField<String>(
    value: _selectedQualification,
    style: AppTextStyles.bodyLarge,
    decoration: InputDecoration(
    prefixIcon: Icon(
    Icons.school_outlined,
    color: AppColors.textHint,
    ),
    ),
    hint: Text(
    'Select qualification',
    style: AppTextStyles.hint,
    ),
    items: [
      'WAEC/SSCE',
    'NECO',
    'A-Levels',
    'OND',
    'HND',
    "Bachelor's Degree",
    "Master's Degree",
    ]
    .map((q) => DropdownMenuItem(
    value: q,
    child: Text(q),
    ))
    .toList(),
    onChanged: (value) {
    setState(() => _selectedQualification = value);
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select your qualification';
      }
      return null;
    },
    ),

    SizedBox(height: 16.h),

    // Grade
    Text('Grade', style: AppTextStyles.label),
    SizedBox(height: 8.h),
    TextFormField(
    controller: _gradeController,
    style: AppTextStyles.bodyLarge,
    decoration: InputDecoration(
    hintText: 'e.g 5 A\'s and 2 B\'s',
    prefixIcon: Icon(
    Icons.grade_outlined,
    color: AppColors.textHint,
    ),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your grade or result';
    }
    return null;
    },
    ),

    SizedBox(height: 16.h),

    // Graduation Year
    Text('Graduation Year', style: AppTextStyles.label),
    SizedBox(height: 8.h),
    TextFormField(
    controller: _graduationYearController,
    style: AppTextStyles.bodyLarge,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
    hintText: 'e.g 2023',
    prefixIcon: Icon(
    Icons.date_range_outlined,
    color: AppColors.textHint,
    ),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your graduation year';
    }
    if (value.length != 4) {
      return 'Please enter a valid year';
    }
    return null;
    },
    ),

    SizedBox(height: 40.h),
],
),
),
);
          }

          // Step 3 - Programme Selection
Widget _buildStep3() {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _step3Key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
Text(
'Programme Selection',
style: AppTextStyles.h2,
)
}
}