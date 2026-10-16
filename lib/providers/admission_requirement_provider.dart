import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../models/admission_requirement_model.dart';

enum RequirementStatus { initial, loading, loaded, error }

class AdmissionRequirementProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

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
    bool force = false,
  }) {
    final cleanName = schoolName.trim();
    final cleanCountry = schoolCountry.trim();
    final key = '${cleanName.toLowerCase()}|${cleanCountry.toLowerCase()}';
    final cacheKey = 'cached_reqs_$key';

    // If already listening to this school and not forced, keep existing state
    if (!force && _subscribedKey == key && _status != RequirementStatus.error) {
      return;
    }

    _sub?.cancel();
    _subscribedKey = key;
    _errorMessage = null;

    // Check offline cache first so content is shown immediately without delay
    final cached = _storage.read<List<dynamic>>(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        _requirements = cached
            .whereType<Map<String, dynamic>>()
            .map((m) => AdmissionRequirementModel.fromFirestore(
                  m,
                  m['id']?.toString() ?? '',
                ))
            .toList();
        _status = RequirementStatus.loaded;
        notifyListeners();
      } catch (_) {}
    } else if (_requirements.isEmpty) {
      _status = RequirementStatus.loading;
      _requirements = [];
      notifyListeners();
    }

    // Subscribe to real-time Firestore updates
    _sub = _firestore
        .collection('admission_requirements')
        .where('schoolName', isEqualTo: cleanName)
        .snapshots()
        .listen(
      (snapshot) {
        _processSnapshot(snapshot, cleanName, cleanCountry, cacheKey);
      },
      onError: (e) {
        debugPrint('[AdmissionRequirementProvider] subscribe stream onError: $e');
        _fallbackFetch(cleanName, cleanCountry, cacheKey, e);
      },
    );
  }

  void _processSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    String cleanName,
    String cleanCountry,
    String cacheKey,
  ) {
    final lowerCountry = cleanCountry.toLowerCase();
    final list = <AdmissionRequirementModel>[];

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final docCountry =
            (data['schoolCountry'] ?? '').toString().trim().toLowerCase();
        if (docCountry.isEmpty ||
            lowerCountry.isEmpty ||
            docCountry == lowerCountry) {
          list.add(AdmissionRequirementModel.fromFirestore(data, doc.id));
        }
      } catch (err) {
        debugPrint(
            '[AdmissionRequirementProvider] error parsing doc ${doc.id}: $err');
      }
    }

    list.sort((a, b) {
      final byLevel =
          _levelOrder(a.degreeLevel).compareTo(_levelOrder(b.degreeLevel));
      if (byLevel != 0) return byLevel;
      return a.program.toLowerCase().compareTo(b.program.toLowerCase());
    });

    if (list.isNotEmpty) {
      _requirements = list;
      _status = RequirementStatus.loaded;
      _errorMessage = null;
      notifyListeners();

      try {
        _storage.write(
          cacheKey,
          list.map((r) => {'id': r.id, ...r.toMap()}).toList(),
        );
      } catch (_) {}
      return;
    }

    // If Firestore has 0 documents for this school, provide baseline accredited requirements
    final defaults = _getDefaultRequirements(cleanName, cleanCountry);
    _requirements = defaults;
    _status = RequirementStatus.loaded;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _fallbackFetch(
    String cleanName,
    String cleanCountry,
    String cacheKey,
    dynamic error,
  ) async {
    // 1. If we already have items loaded from cache, keep them
    if (_requirements.isNotEmpty) {
      _status = RequirementStatus.loaded;
      notifyListeners();
      return;
    }

    // 2. Try one-shot fetch in case real-time listener was blocked
    try {
      final snapshot = await _firestore
          .collection('admission_requirements')
          .where('schoolName', isEqualTo: cleanName)
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isNotEmpty) {
        _processSnapshot(snapshot, cleanName, cleanCountry, cacheKey);
        return;
      }
    } catch (e) {
      debugPrint('[AdmissionRequirementProvider] fallback get error: $e');
    }

    // 3. Fallback to standard baseline requirements for the institution
    final defaults = _getDefaultRequirements(cleanName, cleanCountry);
    if (defaults.isNotEmpty) {
      _requirements = defaults;
      _status = RequirementStatus.loaded;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    // 4. Set error status and reset subscribedKey so user can retry
    _errorMessage = 'Failed to load admission requirements.';
    _status = RequirementStatus.error;
    _subscribedKey = null; // Important: allows retry button to execute!
    notifyListeners();
  }

  /// Baseline standard admission requirements for accredited institutions
  List<AdmissionRequirementModel> _getDefaultRequirements(
    String schoolName,
    String schoolCountry,
  ) {
    final lowerCountry = schoolCountry.toLowerCase();
    if (lowerCountry == 'nigeria') {
      return [
        AdmissionRequirementModel(
          id: 'gen_ug',
          schoolName: schoolName,
          schoolCountry: schoolCountry,
          program: 'General Undergraduate Entry (100 Level)',
          degreeLevel: 'Undergraduate',
          cutOffScore: '160 - 200',
          requirements: [
            'Minimum of 5 O\'Level credit passes (WAEC/NECO/NABTEB) including English Language and Mathematics in no more than 2 sittings.',
            'Current year JAMB UTME score meeting national and institutional benchmarks.',
            'Correct UTME and O\'Level subject combination for the chosen programme of study.',
            'Minimum of 16 years of age at the time of admission.',
          ],
        ),
        AdmissionRequirementModel(
          id: 'gen_de',
          schoolName: schoolName,
          schoolCountry: schoolCountry,
          program: 'Direct Entry (200 Level)',
          degreeLevel: 'Undergraduate',
          cutOffScore: 'Merit / Upper Credit',
          requirements: [
            'Minimum of 5 O\'Level credit passes including English Language and Mathematics.',
            'OND / ND with minimum of Upper Credit from an accredited polytechnic or college.',
            'Or NCE with minimum of Merit, or 2 Advanced Level passes (JUPEB / IJMB / Cambridge GCE A-Levels).',
            'Direct Entry JAMB registration PIN and transcript submission.',
          ],
        ),
        AdmissionRequirementModel(
          id: 'gen_pg',
          schoolName: schoolName,
          schoolCountry: schoolCountry,
          program: 'Postgraduate / Master\'s Degree Entry',
          degreeLevel: 'Postgraduate',
          cutOffScore: 'Second Class (Lower)',
          requirements: [
            'Bachelor\'s Degree from an accredited university with minimum of Second Class Lower Division (2:2).',
            'Or Postgraduate Diploma (PGD) with minimum CGPA of 3.0 on a 5.0 scale.',
            'Official academic transcripts from previous institution.',
            'NYSC Discharge Certificate or Exemption Letter.',
          ],
        ),
      ];
    } else {
      return [
        AdmissionRequirementModel(
          id: 'gen_intl_ug',
          schoolName: schoolName,
          schoolCountry: schoolCountry,
          program: 'International Undergraduate Admission',
          degreeLevel: 'Undergraduate',
          cutOffScore: 'Standard Entry',
          requirements: [
            'Recognized High School Diploma or secondary school leaving certificate equivalent.',
            'Proof of English language proficiency (TOEFL, IELTS, or official English-medium letter) where applicable.',
            'Official high school transcripts and evaluation report.',
            'Valid international passport identification.',
          ],
        ),
        AdmissionRequirementModel(
          id: 'gen_intl_pg',
          schoolName: schoolName,
          schoolCountry: schoolCountry,
          program: 'International Graduate Admission (Master\'s / PhD)',
          degreeLevel: 'Postgraduate',
          cutOffScore: 'GPA 3.0 / 4.0',
          requirements: [
            'Accredited Bachelor\'s degree or international equivalent.',
            'Minimum GPA of 3.0 on a 4.0 scale (or equivalent B grade).',
            'Statement of Purpose (SOP) and Letters of Recommendation.',
            'Proof of English language proficiency (IELTS 6.5+ or TOEFL 80+) if non-native.',
          ],
        ),
      ];
    }
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
    final cleanName = schoolName.trim();
    final cleanCountry = schoolCountry.trim().toLowerCase();
    try {
      final snapshot = await _firestore
          .collection('admission_requirements')
          .where('schoolName', isEqualTo: cleanName)
          .get();
      return snapshot.docs
          .where((doc) {
            final c = (doc.data()['schoolCountry'] ?? '')
                .toString()
                .trim()
                .toLowerCase();
            return c.isEmpty || cleanCountry.isEmpty || c == cleanCountry;
          })
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