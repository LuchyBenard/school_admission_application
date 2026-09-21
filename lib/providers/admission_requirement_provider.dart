import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/admission_requirement_model.dart';

enum RequirementStatus { initial, loading, loaded, error }

class AdmissionRequirementProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RequirementStatus _status = RequirementStatus.initial;
  List<AdmissionRequirementModel> _requirements = [];
  String? _errorMessage;

  // Registry for the real-time listener so a new school selection
  // replaces the old subscription.
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  String? _subscribedKey;

  RequirementStatus get status => _status;
  List<AdmissionRequirementModel> get requirements => _requirements;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == RequirementStatus.loading;

  // Subscribe to real-time requirement updates for a school.
  // Keyed by schoolName|country so changing schools swaps the listener.
  void subscribeToRequirements({
    required String schoolName,
    required String schoolCountry,
  }) {
    final key = '$schoolName|$schoolCountry';

    if (_subscribedKey == key) return;

    _sub?.cancel();
    _subscribedKey = key;
    _status = RequirementStatus.loading;
    _requirements = [];
    notifyListeners();

    _sub = _firestore
        .collection('admission_requirements')
        .where('schoolName', isEqualTo: schoolName)
        .where('schoolCountry', isEqualTo: schoolCountry)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs
          .map((doc) => AdmissionRequirementModel.fromFirestore(
                doc.data(),
                doc.id,
              ))
          .toList()
        ..sort((a, b) {
          // Programs first, then by programme name
          final byLevel = _levelOrder(a.degreeLevel)
              .compareTo(_levelOrder(b.degreeLevel));
          if (byLevel != 0) return byLevel;
          return a.program.toLowerCase().compareTo(b.program.toLowerCase());
        });

      _requirements = list;
      _status = RequirementStatus.loaded;
      notifyListeners();
    }, onError: (e) {
      debugPrint(
          '[AdmissionRequirementProvider] subscribe onError: $e');
      _errorMessage = 'Failed to load admission requirements.';
      _status = RequirementStatus.error;
      notifyListeners();
    });
  }

  int _levelOrder(String level) {
    switch (level.toLowerCase()) {
      case 'undergraduate':
        return 0;
      case 'diploma':
        return 1;
      case 'postgraduate':
        return 2;
      case 'masters':
        return 3;
      case 'phd':
        return 4;
      default:
        return 5;
    }
  }

  /// Add or update a single requirement entry (admin).
  Future<bool> saveRequirement(AdmissionRequirementModel requirement) async {
    try {
      final docRef = requirement.id != null && requirement.id!.isNotEmpty
          ? _firestore
              .collection('admission_requirements')
              .doc(requirement.id)
          : _firestore.collection('admission_requirements').doc();

      await docRef.set({
        ...requirement.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('[AdmissionRequirementProvider] saveRequirement error: $e');
      return false;
    }
  }

  /// Delete an existing requirement entry (admin).
  Future<bool> deleteRequirement(String id) async {
    if (id.isEmpty) return false;
    try {
      await _firestore.collection('admission_requirements').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('[AdmissionRequirementProvider] deleteRequirement error: $e');
      return false;
    }
  }

  /// One-shot fetch used by the admin screen to load existing
  /// requirements for editing.
  Future<List<AdmissionRequirementModel>> loadRequirementsForSchool({
    required String schoolName,
    required String schoolCountry,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('admission_requirements')
          .where('schoolName', isEqualTo: schoolName)
          .where('schoolCountry', isEqualTo: schoolCountry)
          .get();
      return snapshot.docs
          .map((doc) => AdmissionRequirementModel.fromFirestore(
                doc.data(),
                doc.id,
              ))
          .toList();
    } catch (e) {
      debugPrint('[AdmissionRequirementProvider] load error: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}