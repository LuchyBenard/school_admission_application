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
    return AdmissionRequirementModel(
      id: id,
      schoolName: json['schoolName'] ?? '',
      schoolCountry: json['schoolCountry'] ?? '',
      program: json['program'] ?? '',
      degreeLevel: json['degreeLevel'] ?? '',
      cutOffScore: json['cutOffScore'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}