class ApplicationModel{
  final String? id;
  final String userId;
  final String schoolName;
  final String schoolCountry;

  // Personal Details
final String fullName;
final String dateOfBirth;
final String gender;
final String nationality;

// Academic Details
  final String qualification;
  final String grade;
  final String graduationYear;
  final String jambScore;
  final String jambYear;

  // Programme Details
  final String courseOfStudy;
  final String entryLevel;
  final String session;

  // Status
  final String status;
  final DateTime? createdAt;

  ApplicationModel({
    this.id,
    required this.userId,
    required this.schoolName,
    required this.schoolCountry,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.qualification,
    required this.grade,
    required this.graduationYear,
    required this.jambScore,
    required this.jambYear,
    required this.courseOfStudy,
    required this.entryLevel,
    required this.session,
    this.status = 'pending',
    this.createdAt,
});

  // To Firestore
Map<String, dynamic> toMap() {
  return {
    'userId': userId,
    'schoolName': schoolName,
    'schoolCountry': schoolCountry,
    'fullName': fullName,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    'nationality': nationality,
    'qualification': qualification,
    'grade': grade,
    'graduationYear': graduationYear,
    'jambScore': jambScore,
    'jambYear': jambYear,
    'courseOfStudy': courseOfStudy,
    'entryLevel': entryLevel,
    'session': session,
    'status': status,
    'createdAt': createdAt?.toIso8601String(),
  };
}

// From Firestore
factory ApplicationModel.fromFirestore(
    Map<String, dynamic> json, String id) {
  return ApplicationModel(
    id: id,
      userId: json ['userId'] ?? '',
      schoolName: json ['schoolName'] ?? '',
      schoolCountry: json ['schoolCountry'] ?? '',
      fullName: json ['fullName'] ?? '',
      dateOfBirth: json ['dateOfBirth'] ?? '',
      gender: json ['gender'] ?? '',
      nationality: json ['nationality'] ?? '',
      qualification: json ['qualification'] ?? '',
      grade: json ['grade'] ?? '',
      graduationYear: json ['graduationYear'] ?? '',
      jambScore: json ['jambScore'] ?? '',
      jambYear: json ['jambYear'] ?? '',
      courseOfStudy: json ['courseOfStudy'] ?? '',
      entryLevel: json ['entryLevel'] ?? '',
      session: json ['session'] ?? '',
    status: json ['status'] ?? 'pending',
    createdAt: json ['createdAt'] != null
      ? DateTime.parse(json['createdAt'])
        : null,
  );
}
}