import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/school_model.dart';
import '../../services/school_api_service.dart';

/// Results of parsing + validating a picked CSV file.
class _FileParseResult {
  final String fileName;
  final int totalRows;
  final List<SchoolModel> valid;
  final int duplicatedInFile;
  final List<String> errors;
  final List<SchoolModel> preview;

  _FileParseResult({
    required this.fileName,
    required this.totalRows,
    required this.valid,
    required this.duplicatedInFile,
    required this.errors,
    required this.preview,
  });
}

class BatchUploadScreen extends StatefulWidget {
  const BatchUploadScreen({super.key});

  @override
  State<BatchUploadScreen> createState() => _BatchUploadScreenState();
}

class _BatchUploadScreenState extends State<BatchUploadScreen> {
  final SchoolApiService _schoolApiService = SchoolApiService();

  bool _isPicking = false;
  _FileParseResult? _parse;
  bool _isImporting = false;
  double _progress = 0;
  String _progressText = '';
  BatchImportResult? _result;

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (picked == null || picked.files.isEmpty) {
        return;
      }

      final file = picked.files.single;
      if (!(file.extension?.toLowerCase() == 'csv') && file.path != null) {
        showToast(
          'Please select a CSV file',
          backgroundColor: AppColors.error,
          textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        );
        return;
      }

      final path = file.path;
      if (path == null) {
        showToast(
          'Could not read the selected file',
          backgroundColor: AppColors.error,
          textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        );
        return;
      }

      final bytes = await File(path).readAsBytes();
      var raw = utf8.decode(bytes, allowMalformed: true);
      if (raw.startsWith('\uFEFF')) {
        raw = raw.substring(1); // strip BOM
      }
      raw = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      final parse = _parseCsv(file.name, raw);
      if (!mounted) return;
      setState(() => _parse = parse);
    } catch (e) {
      if (mounted) {
        showToast(
          'Failed to read file: $e',
          backgroundColor: AppColors.error,
          textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  _FileParseResult _parseCsv(String fileName, String raw) {
    final errors = <String>[];
    var duplicatedInFile = 0;
    final valid = <SchoolModel>[];
    final preview = <SchoolModel>[];
    var totalRows = 0;

    final rows =
        const CsvToListConverter(shouldParseNumbers: false).convert(raw);

    if (rows.isEmpty || rows.every((r) => r.every((c) => c.toString().trim().isEmpty))) {
      return _FileParseResult(
        fileName: fileName,
        totalRows: 0,
        valid: valid,
        duplicatedInFile: duplicatedInFile,
        errors: const ['File contains no data'],
        preview: preview,
      );
    }

    // Build a header -> index map (case-insensitive).
    final header = rows.first.map((c) => c.toString().trim()).toList();
    final cols = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      final key = header[i].toLowerCase();
      if (key.isNotEmpty) cols[key] = i;
    }

    final missing = <String>[
      if (!cols.containsKey('name')) 'name',
      if (!cols.containsKey('country')) 'country',
    ];
    if (missing.isNotEmpty) {
      return _FileParseResult(
        fileName: fileName,
        totalRows: 0,
        valid: valid,
        duplicatedInFile: duplicatedInFile,
        errors: ['Missing required columns: ${missing.join(', ')}'],
        preview: preview,
      );
    }

    final nameCol = cols['name']!;
    final countryCol = cols['country']!;
    final stateCol = cols['state'];
    final websiteCol = cols['website'];
    final isFeaturedCol = cols['isfeatured'];
    final descriptionCol = cols['description'];
    final imageUrlCol = cols['imageurl'];
    final applicationFeeCol = cols['applicationfee'];
    final deadlineCol = cols['deadline'];

    String cell(List row, int? index) =>
        (index != null && index < row.length) ? row[index].toString().trim() : '';

    final seen = <String>{};

    for (var r = 1; r < rows.length; r++) {
      final row = rows[r];
      // Skip fully-empty lines.
      if (row.every((c) => c.toString().trim().isEmpty)) continue;

      totalRows++;
      if (totalRows > 5000) {
        errors.add('Total rows capped at 5000 per import');
        break;
      }

      final name = cell(row, nameCol);
      final country = cell(row, countryCol);

      if (name.isEmpty) {
        errors.add('Row ${r + 1}: name is required');
        continue;
      }
      if (country.isEmpty) {
        errors.add('Row ${r + 1}: country is required');
        continue;
      }

      final website = cell(row, websiteCol);
      if (website.isNotEmpty && !website.startsWith('https://')) {
        errors.add('Row ${r + 1}: website must start with https://');
        continue;
      }

      final key = '${name.toLowerCase()}|${country.toLowerCase()}';
      if (!seen.add(key)) {
        duplicatedInFile++;
        continue;
      }

      final school = SchoolModel(
        name: name,
        country: country,
        state: cell(row, stateCol),
        website: website,
        imageUrl: cell(row, imageUrlCol).isEmpty
            ? null
            : cell(row, imageUrlCol),
        description: cell(row, descriptionCol).isEmpty
            ? null
            : cell(row, descriptionCol),
        applicationFee: cell(row, applicationFeeCol).isEmpty
            ? null
            : cell(row, applicationFeeCol),
        deadline: cell(row, deadlineCol).isEmpty ? null : cell(row, deadlineCol),
        isFeatured: _parseBool(cell(row, isFeaturedCol)),
      );

      valid.add(school);
      if (preview.length < 10) preview.add(school);
    }

    return _FileParseResult(
      fileName: fileName,
      totalRows: totalRows,
      valid: valid,
      duplicatedInFile: duplicatedInFile,
      errors: errors,
      preview: preview,
    );
  }

  bool _parseBool(String value) {
    final v = value.toLowerCase().trim();
    return v == 'true' || v == '1' || v == 'yes';
  }

  Future<void> _import() async {
    final parse = _parse;
    if (parse == null || parse.valid.isEmpty) return;

    setState(() {
      _isImporting = true;
      _progress = 0;
      _progressText = '';
      _result = null;
    });

    final result = await _schoolApiService.importSchoolsBatch(
      parse.valid,
      onProgress: (processed, total) {
        if (!mounted) return;
        setState(() {
          _progress = total == 0 ? 0 : processed / total;
          _progressText = '$processed of $total';
        });
      },
    );

    _cacheImported(result.added);

    if (!mounted) return;
    setState(() {
      _result = result;
      _isImporting = false;
    });

    showToast(
      'Imported ${result.imported} school${result.imported == 1 ? '' : 's'}',
      backgroundColor:
          result.failed == 0 ? AppColors.success : AppColors.warning,
      textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
    );
  }

  void _cacheImported(List<SchoolModel> added) {
    if (added.isEmpty) return;
    final box = GetStorage();
    final byCountry = <String, List<SchoolModel>>{};
    for (final school in added) {
      byCountry.putIfAbsent(school.country, () => []).add(school);
    }

    for (final entry in byCountry.entries) {
      final key = 'cached_schools_${entry.key}';
      final existing = (box.read<List<dynamic>>(key) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(SchoolModel.fromFirestore)
          .toList();
      final importedKeys = entry.value
          .map((s) => '${s.name.toLowerCase()}|${s.country.toLowerCase()}')
          .toSet();
      final merged = existing
          .where((s) =>
              !importedKeys
                  .contains('${s.name.toLowerCase()}|${s.country.toLowerCase()}'))
          .toList()
        ..addAll(entry.value);
      box.write(key, merged.map((s) => s.toMap()).toList());
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
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
        title: Text('Upload Schools', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_result != null) ...[
              _buildResultCard(_result!),
            ] else if (_isImporting) ...[
              _buildProgressCard(),
            ] else if (_parse != null) ...[
              _buildPreviewCard(_parse!),
            ] else ...[
              _buildInstructions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.upload_file_outlined,
                  color: AppColors.background, size: 32.w),
              SizedBox(height: 12.h),
              Text(
                'Batch Upload Schools',
                style: AppTextStyles.h2.copyWith(color: AppColors.background),
              ),
              SizedBox(height: 4.h),
              Text(
                'Import up to 5,000 schools from a CSV file into the schools collection.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.background.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        Text('Required columns', style: AppTextStyles.h3),
        SizedBox(height: 8.h),
        _buildColumnList([
          ('name', true),
          ('country', true),
          ('state', false),
          ('website — must start with https://', true),
          ('isFeatured', false),
          ('description', false),
          ('imageUrl', false),
          ('applicationFee', false),
          ('deadline', false),
        ]),
        SizedBox(height: 24.h),

        Text('Example', style: AppTextStyles.h3),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'name,country,state,website,isFeatured\\n'
                'University of Lagos,Nigeria,Lagos,https://unilag.edu.ng,true\\n'
                'Ahmadu Bello University,Nigeria,Zaria,https://abu.edu.ng,false',
                style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isPicking ? null : _pickFile,
            icon: _isPicking
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      color: AppColors.background,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.folder_open_outlined),
            label: Text(_isPicking ? 'Reading file...' : 'Pick a CSV file'),
          ),
        ),
      ],
    );
  }

  Widget _buildColumnList(List<(String, bool)> items) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Icon(
                    item.$2 ? Icons.star : Icons.circle_outlined,
                    color: item.$2 ? AppColors.warning : AppColors.textHint,
                    size: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(item.$1, style: AppTextStyles.bodyMedium),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPreviewCard(_FileParseResult parse) {
    final hasErrors = parse.errors.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description_outlined,
                color: AppColors.primary, size: 24.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                parse.fileName,
                style: AppTextStyles.h3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Summary chips
        Row(
          children: [
            _buildChip('${parse.totalRows} rows', AppColors.info),
            SizedBox(width: 8.w),
            _buildChip('${parse.valid.length} valid', AppColors.success),
            SizedBox(width: 8.w),
            _buildChip('${parse.duplicatedInFile} dupes', AppColors.warning),
          ],
        ),
        SizedBox(height: 16.h),

        // First 10 rows preview
        Text('Preview (first ${parse.preview.length})', style: AppTextStyles.h3),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: parse.preview.isEmpty
                ? [
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'No valid rows found',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ]
                : [
                    _buildPreviewHeader(),
                    ...parse.preview.map((s) => _buildPreviewRow(s)),
                  ],
          ),
        ),

        if (hasErrors) ...[
          SizedBox(height: 16.h),
          Text('Validation issues — fix and re-pick the file',
              style: AppTextStyles.h3.copyWith(color: AppColors.error)),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: parse.errors
                  .take(50)
                  .map(
                    (e) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      child: Text(
                        '• $e',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.error),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        SizedBox(height: 24.h),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: parse.valid.isEmpty ? null : _import,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: Text(
                'Import ${parse.valid.length} School${parse.valid.length == 1 ? '' : 's'}'),
          ),
        ),
        SizedBox(height: 8.h),
        TextButton(
          onPressed: _pickFile,
          child: Text(
            'Choose a different file',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      color: AppColors.surfaceAlt,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Name', style: AppTextStyles.label)),
          Expanded(flex: 2, child: Text('Country', style: AppTextStyles.label)),
          Expanded(flex: 2, child: Text('State', style: AppTextStyles.label)),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(SchoolModel school) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              school.name,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              school.country,
              style: AppTextStyles.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              school.state.isEmpty ? '-' : school.state,
              style: AppTextStyles.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.cloud_upload_outlined,
            color: AppColors.primary, size: 32.w),
        SizedBox(height: 16.h),
        Text('Importing schools...', style: AppTextStyles.h2),
        SizedBox(height: 8.h),
        Text(
          '$_progressText school${_progressText == '1' ? '' : 's'} — writing in batches to Firestore',
          style: AppTextStyles.bodyMedium,
        ),
        SizedBox(height: 16.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 10.h,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          '${(_progress * 100).round()}%',
          style: AppTextStyles.h2,
        ),
      ],
    );
  }

  Widget _buildResultCard(BatchImportResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          result.failed == 0
              ? Icons.check_circle_outline
              : Icons.warning_amber_outlined,
          color: result.failed == 0 ? AppColors.success : AppColors.warning,
          size: 40.w,
        ),
        SizedBox(height: 12.h),
        Text(
          result.failed == 0 ? 'Import Complete' : 'Import Finished',
          style: AppTextStyles.h1,
        ),
        SizedBox(height: 16.h),
        _buildStat(
          'Imported',
          result.imported,
          AppColors.success,
        ),
        _buildStat(
          'Skipped (duplicates)',
          result.skipped,
          AppColors.info,
        ),
        _buildStat(
          'Failed',
          result.failed,
          AppColors.error,
        ),
        if (result.errors.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.errors
                  .map(
                    (e) => Text(
                      '• $e',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        SizedBox(height: 24.h),

        if (result.failed > 0)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _import,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Failed'),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.done_outline),
              label: const Text('Done'),
            ),
          ),
        SizedBox(height: 8.h),
        TextButton(
          onPressed: () {
            setState(() {
              _parse = null;
              _result = null;
            });
          },
          child: Text(
            'Upload another file',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            '$value',
            style: AppTextStyles.displayMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}