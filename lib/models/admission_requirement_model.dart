import 'package:cloud_firestore/cloud_firestore.dart';

/// A titled group of requirement items, e.g. "English Proficiency"
/// or "Standardized Tests". Used to structure international admission
/// requirements, which differ greatly from Nigerian cut-off based entries.
class RequirementCategory {
  /// Machine key identifying the category intent:
  /// `academic`, `english`, `tests`, `documents` or `other`.
  final String key;

  /// Optional admin-authored display title. When empty the UI falls back
  /// to a localized title derived from [key].
  final String title;

  final List<String> items;

  const RequirementCategory({
    required this.key,
    this.title = '',
    this.items = const [],
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'title': title,
      'items': items,
    };
  }

  factory RequirementCategory.fromMap(Map<String, dynamic> map) {
    List<String> parsed = [];
    final raw = map['items'] ?? map['requirements'];
    if (raw is List) {
      parsed = raw
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (raw is String && raw.trim().isNotEmpty) {
      parsed = raw
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return RequirementCategory(
      key: (map['key'] ?? 'other').toString().trim(),
      title: (map['title'] ?? '').toString().trim(),
      items: parsed,
    );
  }
}

/// A single admission requirement entry for a school: a programme
/// (course of study) with its cut-off score, entry criteria and any
/// structured or flat requirements.
class AdmissionRequirementModel {
  final String? id;
  final String schoolName;
  final String schoolCountry;

  // Programme details
  final String program;
  final String degreeLevel;
  final String cutOffScore;

  // Supplementary requirements (documents, subjects, notes)
  final List<String> requirements;

  // Structured requirement groups (international schools). When non-empty
  // the UI shows these sections; otherwise it falls back to [requirements].
  final List<RequirementCategory> categories;

  final DateTime? createdAt;

  AdmissionRequirementModel({
    this.id,
    required this.schoolName,
    required this.schoolCountry,
    required this.program,
    required this.degreeLevel,
    required this.cutOffScore,
    this.requirements = const [],
    this.categories = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolName': schoolName,
      'schoolCountry': schoolCountry,
      'program': program,
      'degreeLevel': degreeLevel,
      'cutOffScore': cutOffScore,
      // Flatten categories into the legacy list so older clients and the
      // offline cache still surface every item.
      'requirements': requirements.isNotEmpty
          ? requirements
          : categories.expand((c) => c.items).toList(),
      'categories': categories.map((c) => c.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory AdmissionRequirementModel.fromFirestore(
    Map<String, dynamic> json,
    String id,
  ) {
    List<String> parsedReqs = [];
    final rawReqs = json['requirements'];
    if (rawReqs is List) {
      parsedReqs = rawReqs
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (rawReqs is String && rawReqs.trim().isNotEmpty) {
      parsedReqs = rawReqs
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    List<RequirementCategory> parsedCategories = [];
    final rawCats = json['categories'];
    if (rawCats is List) {
      parsedCategories = rawCats
          .whereType<Map>()
          .map((e) => RequirementCategory.fromMap(Map<String, dynamic>.from(e)))
          .where((c) => c.isNotEmpty)
          .toList();
    }

    return AdmissionRequirementModel(
      id: id,
      schoolName: (json['schoolName'] ?? '').toString().trim(),
      schoolCountry: (json['schoolCountry'] ?? '').toString().trim(),
      program: (json['program'] ?? json['programme'] ?? json['course'] ?? '').toString().trim(),
      degreeLevel: (json['degreeLevel'] ?? json['level'] ?? 'Undergraduate').toString().trim(),
      cutOffScore: (json['cutOffScore'] ?? json['cutOff'] ?? json['cutoff'] ?? '').toString().trim(),
      requirements: parsedReqs,
      categories: parsedCategories,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  factory AdmissionRequirementModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return AdmissionRequirementModel.fromFirestore(
      map,
      id ?? (map['id']?.toString() ?? ''),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}