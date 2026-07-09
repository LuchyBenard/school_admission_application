import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _stateOfOriginController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profile = context.read<AuthProvider>().userProfile;
    if (profile != null) {
      _fullNameController.text = profile['fullName'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _dateOfBirthController.text = profile['dateOfBirth'] ?? '';
      _stateOfOriginController.text = profile['stateOfOrigin'] ?? '';
    }
    }

    @override
  void dispose () {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _stateOfOriginController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
    if (!_isEditing) {
      // Cancelled editing - reload original data
      _loadProfileData();
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.updateProfile(
        fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: _dateOfBirthController.text.trim(),
          stateOfOrigin: _stateOfOriginController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        setState(() => _isEditing = false);
      }
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
           date: Theme.of(context).copyWith(
             colorScheme: ColorScheme.light(
               primary: AppColors.primary,
               onPrimary: AppColors.backgroud,
               surface: AppColors.backgroud,
             ),
           ),
           child: child!,
         );
       }
   );

   if (picked != null) {
     setState(() {
       _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
     });
   }
 }
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.userProfile;
    final String fullName = profile?['fullName'] ?? 'Student';
    final String email = profile?['email'] ??
    authProvider.user?.email??'';
    final String initials = fullName.isNotEmpty
    ? fullName.trim().split(' ').map((e) => e[0].take(2).join()
    : 'S';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.h2,
        ),
        actions: GestureDetector(
          onTap: _toggleEdit,
          child: Padding(
              padding: EdgeInsets.only(right: 24.w),
            child: Text(
              _isEditing ? 'Cancel' : 'Edit',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form (
            key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Avatar
              Center(
                child: Colunm(
                  children:[
                    Container(
                      width: 90.w,
                      height: 90.w,
                      decoration: BoxDecoration(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                              child: Text(
                                  initials.toUpperCase(),
                                  style: AppTextStyles.displayMedium.copyWith(
                                    color: AppColors.background,
                                    fontSize: 32,
                                  ),
                              ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // CONTINUE FROM TEXT()
                  ]
                )
              )
            ],
          )

        ),
    );
  }
}
