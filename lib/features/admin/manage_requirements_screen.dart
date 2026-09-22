import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/admission_requirement_model.dart';
import '../../providers/admission_requirement_provider.dart';
import 'package:provider/provider.dart';

class ManageRequirementsScreen extends StatefulWidget {
  const ManageRequirementsScreen({super.key});

  @override
  State<ManageRequirementsScreen> createState() =>
      _ManageRequirementsScreenState();
}

class _ManageRequirementsScreenState extends State<ManageRequirementsScreen> {
  final _schoolNameController = TextEditingController();
  final _countryController = TextEditingController(text: 'Nigeria');

  // Entry form controllers
  final _programController = TextEditingController();
  final _cutOffController = TextEditingController();
  final _requirementsController = TextEditingController();
  String _degreeLevel = 'Undergraduate';

  bool _loadingExisting = false;
  bool _saving = false;
  List<AdmissionRequirementModel> _existing = [];
  String? _editingId;

  final List<String> _degreeLevels = [
    'Undergraduate',
    'Diploma',
    'Postgraduate',
    'Masters',
    'PhD',
  ];

  @override
  void dispose() {
    _schoolNameController.dispose();
    _countryController.dispose();
    _programController.dispose();
    _cutOffController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final schoolName = _schoolNameController.text.trim();
    if (schoolName.isEmpty) {
      showToast(
        'Enter a school name first',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    setState(() => _loadingExisting = true);
    final results = await context
        .read<AdmissionRequirementProvider>()
        .loadRequirementsForSchool(
          schoolName: schoolName,
          schoolCountry: _countryController.text.trim(),
        );
    if (!mounted) return;
    setState(() {
      _existing = results;
      _loadingExisting = false;
    });

    showToast(
      results.isEmpty
          ? 'No existing requirements found'
          : 'Loaded ${results.length} requirement${results.length == 1 ? '' : 's'}',
      backgroundColor: results.isEmpty ? AppColors.info : AppColors.success,
    );
  }

  Future<void> _saveEntry() async {
    final schoolName = _schoolNameController.text.trim();
    final program = _programController.text.trim();
    final cutOff = _cutOffController.text.trim();

    if (schoolName.isEmpty) {
      showToast(
        'Enter a school name first',
        backgroundColor: AppColors.warning,
      );
      return;
    }
    if (program.isEmpty) {
      showToast(
        'Enter the programme name',
        backgroundColor: AppColors.warning,
      );
      return;
    }
    if (cutOff.isEmpty) {
      showToast(
        'Enter the cut-off score',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final reqLines = _requirementsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    setState(() => _saving = true);

    final requirement = AdmissionRequirementModel(
      id: _editingId,
      schoolName: schoolName,
      schoolCountry: _countryController.text.trim(),
      program: program,
      degreeLevel: _degreeLevel,
      cutOffScore: cutOff,
      requirements: reqLines,
    );

    final success =
        await context.read<AdmissionRequirementProvider>().saveRequirement(
              requirement,
            );

    if (!mounted) return;
    setState(() {
      _saving = false;
      _editingId = null;
    });

    showToast(
      success ? 'Requirement saved' : 'Failed to save requirement',
      backgroundColor: success ? AppColors.success : AppColors.error,
    );

    if (success) {
      _programController.clear();
      _cutOffController.clear();
      _requirementsController.clear();
      await _loadExisting();
    }
  }

  Future<void> _deleteEntry(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Delete Requirement', style: AppTextStyles.h2),
        content: Text(
          'Are you sure you want to delete this requirement?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Delete',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success =
        await context.read<AdmissionRequirementProvider>().deleteRequirement(id);

    if (!mounted) return;

    showToast(
      success ? 'Requirement deleted' : 'Failed to delete requirement',
      backgroundColor: success ? AppColors.success : AppColors.error,
    );
    if (success) await _loadExisting();
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
          child: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
        title: Text('Manage Requirements', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add, edit or remove admission requirements '
                'and cut-off scores for a school.',
                style: AppTextStyles.bodyMedium),
            SizedBox(height: 20.h),

            // School selection
            Text('School', style: AppTextStyles.label),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _schoolNameController,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'e.g University of Lagos',
                prefixIcon: Icon(Icons.school_outlined, color: AppColors.textHint),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _countryController,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Country',
                prefixIcon: Icon(Icons.public_outlined, color: AppColors.textHint),
              ),
            ),
            SizedBox(height: 12.h),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadingExisting ? null : _loadExisting,
                icon: Icon(Icons.search, color: AppColors.primary),
                label: Text(_loadingExisting ? 'Loading...' : 'Load Existing'),
              ),
            ),

            // Existing requirements
            if (_existing.isNotEmpty) ...[
              SizedBox(height: 20.h),
              Text(
                'Existing (${_existing.length})',
                style: AppTextStyles.h2,
              ),
              SizedBox(height: 4.h),
              Text(
                'Tap Settings to edit, or the trash icon to delete.',
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: 12.h),
              ..._existing.map((req) => _buildExistingTile(req)),
            ],

            SizedBox(height: 24.h),
            Text('Add New Requirement', style: AppTextStyles.h2),
            SizedBox(height: 16.h),

            // Programme name
            Text('Programme', style: AppTextStyles.label),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _programController,
              style: AppTextStyles.bodyLarge,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g Computer Science',
                prefixIcon: Icon(Icons.book_outlined, color: AppColors.textHint),
              ),
            ),
            SizedBox(height: 12.h),

            // Degree level
            Text('Degree Level', style: AppTextStyles.label),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _degreeLevel,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.layers_outlined, color: AppColors.textHint),
              ),
              items: _degreeLevels
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (value) => setState(() => _degreeLevel = value ?? _degreeLevel),
            ),
            SizedBox(height: 12.h),

            // Cut-off score
            Text('Cut-off Score', style: AppTextStyles.label),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _cutOffController,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'e.g 200 or 70%',
                prefixIcon: Icon(Icons.speed_outlined, color: AppColors.textHint),
              ),
            ),
            SizedBox(height: 12.h),

            // Requirements list
            Text('Requirements (one per line)', style: AppTextStyles.label),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _requirementsController,
              style: AppTextStyles.bodyMedium,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g\nFive credit passes in O\'Level\nPass JAMB at cut-off',
              ),
            ),
            SizedBox(height: 20.h),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveEntry,
                icon: _saving
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          color: AppColors.background,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving
                    ? 'Saving...'
                    : _editingId != null
                        ? 'Update Requirement'
                        : 'Save Requirement'),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingTile(AdmissionRequirementModel req) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(req.program, style: AppTextStyles.h3),
              ),
              GestureDetector(
                onTap: () => _editEntry(req),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18.w,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () => _deleteEntry(req.id!),
                child: Icon(
                  Icons.delete_outline,
                  size: 18.w,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                '${req.degreeLevel}  •  Cut-off: ${req.cutOffScore}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editEntry(AdmissionRequirementModel req) {
    _editingId = req.id;
    _programController.text = req.program;
    _cutOffController.text = req.cutOffScore;
    _requirementsController.text = req.requirements.join('\n');
    setState(() => _degreeLevel = req.degreeLevel);

    showToast(
      'Editing "${req.program}". Tap Save to update.',
      backgroundColor: AppColors.info,
    );
  }
}