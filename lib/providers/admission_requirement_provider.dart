import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../models/admission_requirement_model.dart';

enum RequirementStatus { initial, loading, loaded, error }

/// Region bucket used to select baseline admission requirement templates.
/// International regions differ greatly from the Nigerian JAMB-based model,
/// and also from one another in language, credential recognition and
/// application procedures.
enum RequirementRegion {
  nigeria,
  uk,
  us,
  canada,
  ghana,
  kenya,
  australia,
  sweden,
  germany,
  belgium,
  france,
  netherlands,
  denmark,
  finland,
  italy,
  spain,
  norway,
  southKorea,
  generic,
}

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

  /// Baseline standard admission requirements for accredited institutions.
  /// International schools are grouped by region because entry criteria
  /// (GPA scales, English tests, documents) differ greatly from Nigerian
  /// JAMB/UTME cut-off based admissions.
  List<AdmissionRequirementModel> _getDefaultRequirements(
    String schoolName,
    String schoolCountry,
  ) {
    switch (_regionForCountry(schoolCountry)) {
      case RequirementRegion.nigeria:
        return _nigeriaDefaults(schoolName, schoolCountry);
      case RequirementRegion.uk:
        return _ukDefaults(schoolName, schoolCountry);
      case RequirementRegion.us:
        return _usDefaults(schoolName, schoolCountry);
      case RequirementRegion.canada:
        return _canadaDefaults(schoolName, schoolCountry);
      case RequirementRegion.ghana:
        return _ghanaDefaults(schoolName, schoolCountry);
      case RequirementRegion.kenya:
        return _kenyaDefaults(schoolName, schoolCountry);
      case RequirementRegion.australia:
        return _australiaDefaults(schoolName, schoolCountry);
      case RequirementRegion.sweden:
        return _swedenDefaults(schoolName, schoolCountry);
      case RequirementRegion.germany:
        return _germanyDefaults(schoolName, schoolCountry);
      case RequirementRegion.belgium:
        return _belgiumDefaults(schoolName, schoolCountry);
      case RequirementRegion.france:
        return _franceDefaults(schoolName, schoolCountry);
      case RequirementRegion.netherlands:
        return _netherlandsDefaults(schoolName, schoolCountry);
      case RequirementRegion.denmark:
        return _denmarkDefaults(schoolName, schoolCountry);
      case RequirementRegion.finland:
        return _finlandDefaults(schoolName, schoolCountry);
      case RequirementRegion.italy:
        return _italyDefaults(schoolName, schoolCountry);
      case RequirementRegion.spain:
        return _spainDefaults(schoolName, schoolCountry);
      case RequirementRegion.norway:
        return _norwayDefaults(schoolName, schoolCountry);
      case RequirementRegion.southKorea:
        return _southKoreaDefaults(schoolName, schoolCountry);
      case RequirementRegion.generic:
        return _internationalDefaults(schoolName, schoolCountry);
    }
  }

  List<AdmissionRequirementModel> _nigeriaDefaults(
    String schoolName,
    String schoolCountry,
  ) {
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
  }

  List<AdmissionRequirementModel> _ukDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_uk_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (UCAS)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'A-Level BBB / IB 30+',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Completed secondary education with 5 WAEC/NECO credit passes (C6 or better), or A-Level/IB equivalent (typically BBB–ABB).',
            'Competitive courses may require an International Foundation Year or higher A-Level/IB grades.',
          ]),
          RequirementCategory(key: 'english', items: [
            'IELTS Academic (UKVI) 6.0–6.5 overall with no band below 5.5–6.0, or TOEFL iBT 80+, or an approved SELT.',
            'English requirement may be waived where secondary education was taught in English.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official academic transcripts and certificates.',
            'Personal statement and one academic reference via UCAS.',
            'Valid passport; Student Route (Tier 4) visa CAS and ATAS clearance where required.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_uk_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'UK 2:1 or equivalent',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree with a minimum UK 2:1 classification (or 2:2 with relevant experience) from a recognised institution.',
          ]),
          RequirementCategory(key: 'english', items: [
            'IELTS Academic 6.5 (no band below 6.0) or TOEFL iBT 90+, depending on institution and programme.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate, CV and 1–2 academic/professional references.',
            'Statement of purpose; portfolio or interview for selected programmes.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _usDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_us_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'GPA 3.0 / 4.0',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'High school diploma or WAEC/NECO with strong grades; a US GPA of 3.0+ on a 4.0 scale is typically expected.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'SAT or ACT scores (many institutions are currently test-optional — confirm with each school).',
          ]),
          RequirementCategory(key: 'english', items: [
            'TOEFL iBT 80+ or IELTS Academic 6.5+, or Duolingo English Test where accepted.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Common App or university application, official transcripts, 1–2 recommendation letters and a personal essay.',
            'Financial statement/proof of funds for the I-20 and F-1 student visa.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_us_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Graduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'GPA 3.0 / 4.0',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Accredited Bachelor\'s degree with a minimum GPA of 3.0 on a 4.0 scale (or equivalent B average).',
          ]),
          RequirementCategory(key: 'tests', items: [
            'GRE or GMAT may be required (waivers common); programme-specific subject tests where applicable.',
          ]),
          RequirementCategory(key: 'english', items: [
            'TOEFL iBT 80–100 or IELTS Academic 6.5–7.0.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, statement of purpose, 2–3 letters of recommendation and CV/resume.',
            'Financial documentation for the F-1 student visa.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _canadaDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_ca_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'B average / 70%+',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Completion of secondary school equivalent to a Canadian high school diploma; competitive programmes may require specific Grade 12 subjects with minimum percentages.',
          ]),
          RequirementCategory(key: 'english', items: [
            'IELTS Academic 6.5 (no band below 6.0) or TOEFL iBT 80–90 for English-medium institutions; DELF/DALF for French-medium institutions.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts and WAEC/provincial certificate equivalency.',
            'Study permit application with proof of funds.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'Some programmes require the SAT/ACT or additional subject prerequisites.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_ca_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Graduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'GPA 3.0 / 4.0 (B)',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree with a minimum B average (GPA 3.0/4.0 or 70%+) from a recognised institution.',
          ]),
          RequirementCategory(key: 'english', items: [
            'IELTS Academic 6.5–7.0 or TOEFL iBT 90+ for English-medium institutions.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'GRE/GMAT may be required for some programmes.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts; an Educational Credential Assessment (ECA/WES) may be required.',
            'CV, 2 references and a statement of purpose.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _internationalDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_intl_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'International Undergraduate Admission',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'Standard Entry',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Recognised High School Diploma or secondary school leaving certificate equivalent.',
            'Official high school transcripts and, where required, a credential evaluation report.',
          ]),
          RequirementCategory(key: 'english', items: [
            'Proof of English proficiency (IELTS/TOEFL/PTE/Duolingo) if the medium of instruction was not English.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Application form, personal statement and recommendation letters.',
            'Valid international passport and/or national ID.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_intl_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'International Graduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'GPA 3.0 / 4.0',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Accredited Bachelor\'s degree or international equivalent with a minimum GPA of 3.0 on a 4.0 scale (or equivalent B grade).',
            'Official transcripts and degree certificate.',
          ]),
          RequirementCategory(key: 'english', items: [
            'Proof of English proficiency (IELTS 6.5+ or TOEFL 80+) if non-native.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Statement of Purpose and Letters of Recommendation.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _ghanaDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_gh_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (WASSCE/SSSCE)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'WASSCE Aggregate 6–30',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'WASSCE/SSSCE with credits in 6 subjects: 3 core (English, Core Mathematics and Integrated Science or Social Studies) and 3 electives relevant to the programme.',
            'Competitive programmes require an aggregate of roughly 6–24, determined by the university and programme.',
          ]),
          RequirementCategory(key: 'english', items: [
            'Credit pass in English Language at WASSCE/SSSCE; instruction is in English.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'WASSCE/SSSCE results slip and certificate.',
            'Ghana Card or valid passport, and proof of application fee payment.',
            'Mature-entry candidates (25+) may be required to sit an entrance examination.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_gh_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Second Class (Lower)',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree from a recognised university with at least Second Class Lower Division.',
            'A relevant first degree; some programmes require a postgraduate diploma or a qualifying examination.',
          ]),
          RequirementCategory(key: 'english', items: [
            'English language proficiency for instruction; no separate test where the prior degree was taught in English.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate, two academic referees and a statement of purpose.',
            'Research proposal and evidence of supervisor availability for research/PhD programmes.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _kenyaDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_ke_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (KCSE)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'KCSE Mean Grade C+',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'KCSE with a minimum mean grade of C+ (plus) and the cluster subject requirements for the chosen programme.',
            'Apply through KUCCPS (government-sponsored placement) or as a self/private-sponsored student.',
          ]),
          RequirementCategory(key: 'english', items: [
            'Credit pass in English (and Kiswahili) at KCSE; instruction is in English.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'KCSE result slip/certificate and KCSE index number.',
            'Birth certificate or national ID, and proof of application fee payment.',
            'Diploma holders may qualify for credit transfer or entry into later years of study.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_ke_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Second Class Honours',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree from a recognised university with at least Second Class Honours (Lower Division); some programmes require Upper Division.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'MBA and some professional programmes require relevant work experience and may require GMAT/GRE.',
          ]),
          RequirementCategory(key: 'english', items: [
            'English language proficiency (instruction is in English).',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate, two referees and a statement of purpose.',
            'Research proposal for PhD/research programmes.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _australiaDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_au_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'ATAR 70+',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Completion of Year 12 (or equivalent) with an ATAR meeting the programme threshold.',
            'Foundation Studies or a diploma pathway is available where direct entry requirements are not met.',
          ]),
          RequirementCategory(key: 'english', items: [
            'IELTS Academic 6.5 (no band below 6.0) or TOEFL iBT 79+, or equivalent.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official secondary transcripts and certificate.',
            'Valid passport and a Genuine Student (GS) statement for the student visa.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_au_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Bachelor\'s / Credit average',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree in a relevant discipline; a minimum GPA or credit average is typically required.',
          ]),
          RequirementCategory(key: 'english', items: [
            'IELTS Academic 6.5–7.0 or TOEFL iBT 79–94, depending on the programme.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'Some programmes (e.g. MBA) require GMAT/GRE and/or relevant work experience.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, CV and statement of purpose; references for some programmes.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _swedenDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_se_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (Bachelor\'s)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'Upper Secondary Diploma',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Completed upper secondary education providing general eligibility (grundläggande behörighet); programme-specific courses may also be required.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'English 6 (IELTS 6.5 / TOEFL 90+) for English-taught programmes; Swedish for Swedish-taught programmes.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official secondary transcripts and certificates; apply via universityadmissions.se.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'Some programmes require a portfolio, interview or specific subject tests.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_se_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Bachelor\'s (180 ECTS)',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree (180 ECTS) in a relevant field; specific course credits may be required.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'English 6 (IELTS 6.5 / TOEFL 90+) for English-taught programmes.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate, CV and statement of purpose for some programmes.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _germanyDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_de_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (Bachelor\'s)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'Abitur / Feststellungsprüfung',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Recognised secondary qualification equivalent to the German Abitur (Hochschulzugangsberechtigung).',
            'Applicants without direct recognition may need a Studienkolleg and the Feststellungsprüfung.',
            'Subjects such as medicine and psychology are subject to Numerus Clausus (NC) selection.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'German (TestDaF/DSH) for German-taught programmes; IELTS 6.5 / TOEFL 90 for English-taught programmes.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Recognised certificates and application via uni-assist.',
            'APS certificate where required (e.g. for applicants from certain countries).',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_de_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Bachelor\'s (aptitude)',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree in a relevant field; many programmes use an aptitude assessment (Eignungsverfahren) instead of a fixed cut-off.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'German (TestDaF/DSH) or English (IELTS 6.5 / TOEFL 90), depending on the programme.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate, CV and letter of motivation.',
            'APS certificate where required.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _belgiumDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_be_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (Bachelor\'s)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'Secondary Diploma',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Recognised secondary school diploma; applicants from non-EU countries may need an equivalence certificate (NARIC).',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'French (DELF B2/TCF) or Dutch (ITNA/CNaVT) depending on the institution; some programmes are English-taught.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'Medicine/dentistry and arts admissions are subject to an entrance examination and/or lottery.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Secondary diploma, equivalence certificate where required, and proof of language proficiency.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_be_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Bachelor\'s',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree in a relevant field; some programmes require an aptitude test or interview.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'French/Dutch (B2) or English (IELTS 6.5), depending on the programme.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate, CV, letter of motivation and equivalence where required.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _franceDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_fr_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (Licence)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'Baccalauréat',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Recognised secondary diploma equivalent to the French Baccalauréat.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'French (DELF B2/DALF/TCF) for French-taught programmes; English tests for English-taught programmes.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Application via Parcoursup (domestic) or the "Études en France"/DAP procedure via Campus France (international).',
            'Transcripts and a motivation letter.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_fr_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master / Doctorat)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Licence / Bachelor\'s',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s (Licence) or equivalent in a relevant field; selective programmes may require a competitive entrance exam or interview.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'French (DELF B2/C1) or English (IELTS 6.5), depending on the programme.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Campus France "Études en France" application, transcripts, degree certificate, CV and statement of purpose.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _netherlandsDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_nl_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (Bachelor\'s)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'VWO Diploma',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Secondary diploma equivalent to the Dutch VWO; HAVO plus a propaedeutic year may qualify for some universities of applied sciences.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'English (IELTS 6.5 / TOEFL 90) for English-taught programmes; Dutch (NT2) for Dutch-taught programmes.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'Numerus fixus programmes (e.g. medicine) use a selection procedure; apply via Studielink.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Secondary transcripts, diploma and, for some programmes, a motivation letter or entrance exam.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_nl_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Bachelor\'s / GPA',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree in a relevant field; a minimum GPA/grade average is required.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'English (IELTS 6.5 / TOEFL 90) for English-taught programmes.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'Some programmes require GRE/GMAT or work experience (e.g. MBA).',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate, CV and a motivation letter.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _denmarkDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_dk_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (Bachelor\'s)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'Upper Secondary (quota)',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Recognised upper secondary qualification equivalent to the Danish STX/HF; admission is often quota-based on grade point average.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'Danish (Studieprøven) for Danish-taught programmes; English (IELTS 6.5) for English-taught programmes.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Secondary transcripts and diploma; some programmes require supplementary subject levels.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_dk_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Bachelor\'s',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Relevant Bachelor\'s degree; admission may be limited and competitive.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'English (IELTS 6.5 / TOEFL 90) for English-taught programmes.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate, CV and motivation letter.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _finlandDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_fi_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (Bachelor\'s)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'Upper Secondary Certificate',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Completed upper secondary education (ylioppilastutkinto or equivalent) giving eligibility.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'English (IELTS 6.5 / TOEFL 92) for English-taught programmes; Finnish/Swedish for domestic programmes.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'Most programmes require an entrance examination; apply via Studyinfo (Opintopolku).',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Secondary certificates/transcripts and, where required, an official translation.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_fi_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Bachelor\'s (exam)',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Relevant Bachelor\'s degree; some programmes require an entrance examination.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'English (IELTS 6.5 / TOEFL 92) or Finnish/Swedish, depending on the programme.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate, CV and motivation letter.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _italyDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_it_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (Laurea)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'Maturità',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Recognised secondary diploma equivalent to the Italian Maturità; a "declaration of value" or CIMEA statement may be required.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'Italian (B2) for Italian-taught programmes; English (IELTS 6.0–6.5) for English-taught programmes.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'Medicine, surgery and architecture require the IMAT/entrance exam; some programmes are capped (programmato).',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Pre-enrolment via Universitaly, secondary transcript and diploma.',
            'Translation/legalisation of documents and declaration of value/CIMEA statement.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_it_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Laurea Magistrale)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Laurea / Bachelor\'s',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree (Laurea) in a relevant field; some programmes have admission exams or a limited number of places.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'Italian (B2) or English (IELTS 6.5), depending on the programme.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate and declaration of value/CIMEA statement.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _spainDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_es_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (Grado)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'Bachillerato / PCE',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Recognised secondary diploma equivalent to the Spanish Bachillerato; credential homologation may be required.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'Spanish (DELE B2) for Spanish-taught programmes; English for English-taught programmes.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'Foreign applicants may need to sit the UNEDasiss PCE exams; competitive grades set the "nota de corte".',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Secondary transcript, diploma and credit recognition/homologation documentation.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_es_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Máster / Doctorado)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Grado / Bachelor\'s',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree (Grado) in a relevant field; some programmes require an entrance test or interview.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'Spanish (DELE B2) or English (IELTS 6.5), depending on the programme.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate, CV and motivation letter.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _norwayDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_no_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (Bachelor\'s)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'Generell Studiekompetanse',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Completed upper secondary education providing generell studiekompetanse; additional subject requirements may apply.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'Norwegian (B2) for Norwegian-taught programmes; English (IELTS 6.5 / TOEFL 90) for English-taught programmes.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Secondary transcripts and diploma; apply via Samordna Opptak (or directly for some international programmes).',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_no_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Bachelor\'s',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Relevant Bachelor\'s degree; some programmes require specific coursework or work experience.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'English (IELTS 6.5 / TOEFL 90) for English-taught programmes.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate and CV/statement of purpose.',
          ]),
        ],
      ),
    ];
  }

  List<AdmissionRequirementModel> _southKoreaDefaults(
    String schoolName,
    String schoolCountry,
  ) {
    return [
      AdmissionRequirementModel(
        id: 'gen_kr_ug',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Undergraduate Admission (International)',
        degreeLevel: 'Undergraduate',
        cutOffScore: 'High School Diploma',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'High school graduation (or equivalent); international applicants are usually assessed on transcripts and, for competitive universities, SAT/AP/A-Level results.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'TOPIK (Korean) for Korean-taught programmes; IELTS 6.5 / TOEFL 90 for English-taught programmes.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'Domestic applicants take the CSAT (Suneung); international applicants typically submit documents and may attend an interview.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'High school transcript, graduation certificate, passport, financial statement and recommendation letters.',
          ]),
        ],
      ),
      AdmissionRequirementModel(
        id: 'gen_kr_pg',
        schoolName: schoolName,
        schoolCountry: schoolCountry,
        program: 'Postgraduate Admission (Master\'s / PhD)',
        degreeLevel: 'Postgraduate',
        cutOffScore: 'Bachelor\'s',
        categories: [
          RequirementCategory(key: 'academic', items: [
            'Bachelor\'s degree in a relevant field; research programmes require contact with a prospective supervisor.',
          ]),
          RequirementCategory(key: 'language', title: 'Language Proficiency', items: [
            'TOPIK or English (IELTS 6.5 / TOEFL 90), depending on the programme.',
          ]),
          RequirementCategory(key: 'tests', items: [
            'Some programmes require GRE/GMAT; an interview is common.',
          ]),
          RequirementCategory(key: 'documents', items: [
            'Official transcripts, degree certificate, study/research plan, CV and 1–2 recommendation letters.',
          ]),
        ],
      ),
    ];
  }

  RequirementRegion _regionForCountry(String country) {
    final c = country.toLowerCase().trim();
    if (c.isEmpty) return RequirementRegion.generic;

    if (c.contains('nigeria') || c == 'ng') return RequirementRegion.nigeria;

    const ukMarkers = [
      'united kingdom',
      'england',
      'scotland',
      'wales',
      'northern ireland',
      'great britain',
    ];
    if (c == 'uk' || c == 'gb' || ukMarkers.any(c.contains)) {
      return RequirementRegion.uk;
    }

    if (c == 'us' ||
        c == 'usa' ||
        c.contains('united states') ||
        c.contains('america')) {
      return RequirementRegion.us;
    }

    if (c.contains('canada') || c == 'ca') return RequirementRegion.canada;
    if (c.contains('ghana') || c == 'gh') return RequirementRegion.ghana;
    if (c.contains('kenya') || c == 'ke') return RequirementRegion.kenya;
    if (c.contains('australia') || c == 'au') return RequirementRegion.australia;
    if (c.contains('sweden') || c == 'se') return RequirementRegion.sweden;
    if (c.contains('germany') || c.contains('deutschland') || c == 'de') {
      return RequirementRegion.germany;
    }
    if (c.contains('belgium') || c == 'be') return RequirementRegion.belgium;
    if (c.contains('france') || c == 'fr') return RequirementRegion.france;
    if (c.contains('netherlands') || c.contains('holland') || c == 'nl') {
      return RequirementRegion.netherlands;
    }
    if (c.contains('denmark') || c == 'dk') return RequirementRegion.denmark;
    if (c.contains('finland') || c == 'fi') return RequirementRegion.finland;
    if (c.contains('italy') || c == 'it') return RequirementRegion.italy;
    if (c.contains('spain') || c == 'es') return RequirementRegion.spain;
    if (c.contains('norway') || c == 'no') return RequirementRegion.norway;
    if (c.contains('korea') || c == 'kr') return RequirementRegion.southKorea;

    return RequirementRegion.generic;
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