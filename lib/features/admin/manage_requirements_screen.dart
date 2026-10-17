import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
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

  // Optional structured requirement sections (international schools).
  final List<_ReqSection> _sections = [];

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
    for (final s in _sections) {
      s.dispose();
    }
    super.dispose();
  }

  bool get _isNigeria =>
      _countryController.text.trim().toLowerCase().contains('nigeria');

  String get _cutOffHint =>
      _isNigeria ? 'e.g 200' : 'e.g IELTS 6.5 / GPA 3.0 / ABB';

  void _addSection(String key) {
    setState(() {
      _sections.add(_ReqSection(key: key));
    });
  }

  void _removeSection(int index) {
    setState(() {
      _sections.removeAt(index).dispose();
    });
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

    final reqLines = _requirementsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Structured sections (international). Empty sections are ignored.
    final sections = _sections.where((s) => !s.isEmpty).toList();
    final categories = sections
        .map((s) => RequirementCategory(
              key: s.key,
              title: s.title.text.trim(),
              items: s.items.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
            ))
        .toList();

    if (reqLines.isEmpty && categories.isEmpty) {
      showToast(
        _isNigeria
            ? 'Add at least one requirement'
            : 'Add a general requirement or at least one section',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    setState(() => _saving = true);

    final requirement = AdmissionRequirementModel(
      id: _editingId,
      schoolName: schoolName,
      schoolCountry: _countryController.text.trim(),
      program: program,
      degreeLevel: _degreeLevel,
      cutOffScore: cutOff,
      requirements: reqLines,
      categories: categories,
    );

    final success =
        await context.read<AdmissionRequirementProvider>().saveRequirement(
              requirement,
            );

    if (!mounted) return;
    setState(() {
      _saving = false;
      _editingId = null;
      for (final s in _sections) {
        s.dispose();
      }
      _sections.clear();
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
        backgroundColor: context.colors.background,
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
                color: context.colors.textSecondary,
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

    if (confirmed != true || !mounted) return;

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
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: context.colors.textPrimary),
        ),
        title: Text('Manage Requirements', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add, edit or remove admission requirements and entry '
                'criteria for a school.',
                style: AppTextStyles.bodyMedium),
            SizedBox(height: 20.h),

            // School selection
            Text('School', style: AppTextStyles.label),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _schoolNameController,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'e.g University of Lagos',
                prefixIcon: Icon(Icons.school_outlined, color: context.colors.textHint),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _countryController,
              style: AppTextStyles.bodyLarge,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Country',
                prefixIcon: Icon(Icons.public_outlined, color: context.colors.textHint),
              ),
            ),
            SizedBox(height: 12.h),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadingExisting ? null : _loadExisting,
                icon: Icon(Icons.search, color: context.colors.primary),
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
              decoration: InputDecoration(
                hintText: 'e.g Computer Science',
                prefixIcon: Icon(Icons.book_outlined, color: context.colors.textHint),
              ),
            ),
            SizedBox(height: 12.h),

            // Degree level
            Text('Degree Level', style: AppTextStyles.label),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _degreeLevel,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.layers_outlined, color: context.colors.textHint),
              ),
              items: _degreeLevels
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (value) => setState(() => _degreeLevel = value ?? _degreeLevel),
            ),
            SizedBox(height: 12.h),

            // Cut-off score / entry criteria
            Text(
              _isNigeria ? 'Cut-off Score' : 'Entry Criteria',
              style: AppTextStyles.label,
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _cutOffController,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: _cutOffHint,
                prefixIcon: Icon(
                  _isNigeria ? Icons.speed_outlined : Icons.verified_outlined,
                  color: context.colors.textHint,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Optional for international schools (e.g. IELTS band, GPA or A-Level grades).',
              style: AppTextStyles.caption.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),

            // General requirements list
            Text('General requirements (one per line)',
                style: AppTextStyles.label),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _requirementsController,
              style: AppTextStyles.bodyMedium,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: _isNigeria
                    ? 'e.g\nFive credit passes in O\'Level\nPass JAMB at cut-off'
                    : 'e.g\nProof of English proficiency\nTwo letters of recommendation',
              ),
            ),
            SizedBox(height: 16.h),

            // Structured requirement sections
            Text('Requirement Sections', style: AppTextStyles.label),
            SizedBox(height: 4.h),
            Text(
              _isNigeria
                  ? 'Optional. Group requirements by category.'
                  : 'Recommended. Group entry criteria into categories.',
              style: AppTextStyles.caption.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _sectionChip('academic', 'Academic'),
                _sectionChip('english', 'English'),
                _sectionChip('tests', 'Tests'),
                _sectionChip('documents', 'Documents'),
                _sectionChip('other', 'Other'),
              ],
            ),
            if (_sections.isNotEmpty) ...[
              SizedBox(height: 12.h),
              ...List.generate(
                _sections.length,
                (index) => _buildSectionEditor(index),
              ),
            ],
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
                        child: CircularProgressIndicator(
                          color: context.colors.background,
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colors.border),
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
                  color: context.colors.primary,
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
          Text(
            _tileSummary(req),
            style: AppTextStyles.caption.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _tileSummary(AdmissionRequirementModel req) {
    final parts = <String>[req.degreeLevel];
    if (req.cutOffScore.isNotEmpty) {
      parts.add(
        _isNigeria
            ? 'Cut-off: ${req.cutOffScore}'
            : 'Entry: ${req.cutOffScore}',
      );
    }
    if (req.categories.isNotEmpty) {
      final count = req.categories.length;
      parts.add('$count section${count == 1 ? '' : 's'}');
    } else if (req.requirements.isNotEmpty) {
      final count = req.requirements.length;
      parts.add('$count item${count == 1 ? '' : 's'}');
    }
    return parts.join('  •  ');
  }

  void _editEntry(AdmissionRequirementModel req) {
    _editingId = req.id;
    _programController.text = req.program;
    _cutOffController.text = req.cutOffScore;
    _requirementsController.text = req.requirements.join('\n');

    for (final s in _sections) {
      s.dispose();
    }
    _sections.clear();
    if (req.categories.isNotEmpty) {
      _sections.addAll(
        req.categories.map((c) => _ReqSection(
              key: c.key,
              titleText: c.title,
              itemsText: c.items.join('\n'),
            )),
      );
    }

    setState(() => _degreeLevel = req.degreeLevel);

    showToast(
      'Editing "${req.program}". Tap Save to update.',
      backgroundColor: AppColors.info,
    );
  }

  Widget _sectionChip(String key, String label) {
    return ActionChip(
      avatar: Icon(
        _sectionIcon(key),
        size: 16.w,
        color: context.colors.primary,
      ),
      label: Text('+ $label', style: AppTextStyles.bodySmall),
      onPressed: () => _addSection(key),
      backgroundColor: context.colors.surface,
      side: BorderSide(color: context.colors.border),
    );
  }

  Widget _buildSectionEditor(int index) {
    final section = _sections[index];
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _sectionIcon(section.key),
                size: 18.w,
                color: context.colors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _sectionLabel(section.key),
                  style: AppTextStyles.label,
                ),
              ),
              GestureDetector(
                onTap: () => _removeSection(index),
                child: Icon(
                  Icons.close,
                  size: 18.w,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: section.title,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Section title (optional)',
              isDense: true,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: section.items,
            style: AppTextStyles.bodySmall,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '${_sectionHint(section.key)} (one per line)',
            ),
          ),
        ],
      ),
    );
  }

  IconData _sectionIcon(String key) {
    switch (key) {
      case 'academic':
        return Icons.school_outlined;
      case 'english':
        return Icons.translate_outlined;
      case 'tests':
        return Icons.fact_check_outlined;
      case 'documents':
        return Icons.description_outlined;
      default:
        return Icons.checklist_outlined;
    }
  }

  String _sectionLabel(String key) {
    switch (key) {
      case 'academic':
        return 'Academic Qualifications';
      case 'english':
        return 'English Proficiency';
      case 'tests':
        return 'Standardized Tests';
      case 'documents':
        return 'Required Documents';
      default:
        return 'Other Requirements';
    }
  }

  String _sectionHint(String key) {
    switch (key) {
      case 'academic':
        return 'e.g WAEC 5 credits / GPA 3.0';
      case 'english':
        return 'e.g IELTS 6.5 / TOEFL 80';
      case 'tests':
        return 'e.g SAT 1200 / GRE 300';
      case 'documents':
        return 'e.g Transcript, SOP, passport';
      default:
        return 'Requirement';
    }
  }
}

class _ReqSection {
  final String key;
  final TextEditingController title;
  final TextEditingController items;

  _ReqSection({
    required this.key,
    String titleText = '',
    String itemsText = '',
  })  : title = TextEditingController(text: titleText),
        items = TextEditingController(text: itemsText);

  bool get isEmpty => items.text.trim().isEmpty;

  void dispose() {
    title.dispose();
    items.dispose();
  }
}
