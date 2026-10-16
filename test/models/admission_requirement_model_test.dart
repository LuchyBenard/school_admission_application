import 'package:flutter_test/flutter_test.dart';
import 'package:school_admission_application/models/admission_requirement_model.dart';

void main() {
  group('AdmissionRequirementModel', () {
    test('safely parses cutOffScore when provided as an int or double', () {
      final json = {
        'schoolName': 'Stanford University',
        'schoolCountry': 'United States',
        'program': 'Computer Science',
        'degreeLevel': 'BSc',
        'cutOffScore': 95,
        'requirements': ['GRE', 'TOEFL'],
      };

      final model = AdmissionRequirementModel.fromFirestore(json, 'req_1');
      expect(model.cutOffScore, equals('95'));
      expect(model.program, equals('Computer Science'));
      expect(model.requirements, equals(['GRE', 'TOEFL']));
    });

    test('safely parses alternate key names (programme, level, cutoff)', () {
      final json = {
        'schoolName': 'Oxford University',
        'schoolCountry': 'United Kingdom',
        'programme': 'Philosophy & Economics',
        'level': 'Undergraduate',
        'cutoff': 88.5,
        'requirements': 'Letter of Recommendation\nStatement of Purpose',
      };

      final model = AdmissionRequirementModel.fromFirestore(json, 'req_2');
      expect(model.cutOffScore, equals('88.5'));
      expect(model.program, equals('Philosophy & Economics'));
      expect(model.degreeLevel, equals('Undergraduate'));
      expect(model.requirements.length, equals(2));
      expect(model.requirements[0], equals('Letter of Recommendation'));
      expect(model.requirements[1], equals('Statement of Purpose'));
    });

    test('safely parses createdAt as ISO String or milliseconds int', () {
      final now = DateTime.now();
      final modelFromMs = AdmissionRequirementModel.fromFirestore({
        'schoolName': 'Test Uni',
        'schoolCountry': 'Canada',
        'program': 'Engineering',
        'degreeLevel': 'Undergraduate',
        'cutOffScore': '80',
        'createdAt': now.millisecondsSinceEpoch,
      }, 'req_3');

      expect(modelFromMs.createdAt, isNotNull);
      expect(
        modelFromMs.createdAt!.millisecondsSinceEpoch,
        equals(now.millisecondsSinceEpoch),
      );

      final modelFromIso = AdmissionRequirementModel.fromFirestore({
        'schoolName': 'Test Uni',
        'schoolCountry': 'Canada',
        'program': 'Engineering',
        'degreeLevel': 'Undergraduate',
        'cutOffScore': '80',
        'createdAt': now.toIso8601String(),
      }, 'req_4');

      expect(modelFromIso.createdAt, isNotNull);
    });

    test('handles empty or null fields with resilient defaults', () {
      final model = AdmissionRequirementModel.fromFirestore({}, 'req_empty');
      expect(model.id, equals('req_empty'));
      expect(model.schoolName, equals(''));
      expect(model.schoolCountry, equals(''));
      expect(model.program, equals(''));
      expect(model.degreeLevel, equals('Undergraduate'));
      expect(model.cutOffScore, equals(''));
      expect(model.requirements, isEmpty);
      expect(model.createdAt, isNull);
    });

    test('toMap converts model correctly', () {
      final model = AdmissionRequirementModel(
        id: 'test_id',
        schoolName: 'Harvard University',
        schoolCountry: 'United States',
        program: 'Law',
        degreeLevel: 'JD',
        cutOffScore: '175',
        requirements: ['LSAT', 'Transcript'],
      );

      final map = model.toMap();
      expect(map['schoolName'], equals('Harvard University'));
      expect(map['schoolCountry'], equals('United States'));
      expect(map['program'], equals('Law'));
      expect(map['degreeLevel'], equals('JD'));
      expect(map['cutOffScore'], equals('175'));
      expect(map['requirements'], equals(['LSAT', 'Transcript']));
    });
  });
}
