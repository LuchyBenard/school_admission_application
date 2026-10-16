import 'package:cloud_firestore/cloud_firestore.dart';

/// A single admission requirement entry for a school: a programme
/// (course of study) with its cut-off score and any requirements.
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

  final DateTime? createdAt;

  AdmissionRequirementModel({
    this.id,
    required this.schoolName,
    required this.schoolCountry,
    required this.program,
    required this.degreeLevel,
    required this.cutOffScore,
    this.requirements = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'schoolName': schoolName,
      'schoolCountry': schoolCountry,
      'program': program,
      'degreeLevel': degreeLevel,
      'cutOffScore': cutOffScore,
      'requirements': requirements,
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

    return AdmissionRequirementModel(
      id: id,
      schoolName: (json['schoolName'] ?? '').toString().trim(),
      schoolCountry: (json['schoolCountry'] ?? '').toString().trim(),
      program: (json['program'] ?? json['programme'] ?? json['course'] ?? '').toString().trim(),
      degreeLevel: (json['degreeLevel'] ?? json['level'] ?? 'Undergraduate').toString().trim(),
      cutOffScore: (json['cutOffScore'] ?? json['cutOff'] ?? json['cutoff'] ?? '').toString().trim(),
      requirements: parsedReqs,
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