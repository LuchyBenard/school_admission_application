import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school_model.dart';

class SchoolApiService {
final Dio _dio = Dio();
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Primary mirrors of the university dataset. jsDelivr serves the
// Hipo repo from a global CDN (fast in most regions); GitHub raw is
// the same file as a second try. Both return ALL universities in one
// JSON file; we filter by country in Dart.
static const String _mirrorURL = 'https://cdn.jsdelivr.net/gh/Hipo/university-domains-list@master/world_universities_and_domains.json';
static const String _mirrorBackupURL = 'https://raw.githubusercontent.com/Hipo/university-domains-list/master/world_universities_and_domains.json';

// Fallback: Hipolabs API (same dataset, but the server is flaky).
static const String _hipolabsURL = 'https://universities.hipolabs.com/search';

// Fetch schools — tries the fast CDN mirror first, then GitHub raw,
// then Hipolabs as a last resort.
Future<List<SchoolModel>> fetchSchoolsFromApi({
String country = 'Nigeria',
}) async {
try {
return await _fetchFromMirror(country, _mirrorURL);
} catch (_) {
try {
return await _fetchFromMirror(country, _mirrorBackupURL);
} catch (_) {
// All mirrors failed — try Hipolabs as a last resort.
return _fetchFromHipolabs(country);
}
}
}

// Fallback: fetch from Hipolabs API. Retries once with a short
// backoff before giving up.
Future<List<SchoolModel>> _fetchFromHipolabs(String country) async {
const timeout = Duration(seconds: 15);
DioException? lastError;

for (var attempt = 0; attempt < 2; attempt++) {
try {
final response = await _dio.get(
_hipolabsURL,
queryParameters: {'country': country},
options: Options(
connectTimeout: timeout,
receiveTimeout: timeout,
sendTimeout: timeout,
),
);

if (response.statusCode == 200) {
final List data = response.data;
return data
.map((json) => SchoolModel.fromApi(json))
.toList();
}
throw Exception('Failed to fetch schools (${response.statusCode})');
} on DioException catch (e) {
lastError = e;
if (attempt == 0) {
// Small pause before the retry so a flaky connection can recover.
await Future.delayed(const Duration(seconds: 1));
}
}
}

throw lastError ?? Exception('Failed to fetch schools');
}

// Fetch from a mirror and filter for the requested country.
Future<List<SchoolModel>> _fetchFromMirror(
  String country,
  String url,
) async {
final response = await _dio.get(
url,
options: Options(
connectTimeout: const Duration(seconds: 20),
receiveTimeout: const Duration(seconds: 45),
sendTimeout: const Duration(seconds: 20),
),
);

if (response.statusCode != 200) {
throw Exception('Failed to fetch schools (${response.statusCode})');
}

final List data = response.data;
final lowerCountry = country.toLowerCase();
return data
.where((e) =>
e is Map &&
(e['country'] ?? '').toString().toLowerCase() == lowerCountry)
.map((json) => SchoolModel.fromApi(json))
.toList();
}

// Load the bundled Nigerian school list shipped with the app.
// Used as a guaranteed last resort when every API source and
// Firestore are unreachable/slow, so the user never sees an
// empty school list.
Future<List<SchoolModel>> fetchBundledSchools() async {
  try {
    final raw = await rootBundle.loadString(
      'assets/data/nigerian_schools.json',
    );
    final list = (jsonDecode(raw) as List)
        .whereType<Map<String, dynamic>>()
        .map(SchoolModel.fromFirestore)
        .toList();
    return list;
  } catch (e) {
    return [];
  }
}

// Fetch Featured schools from Firestore
Future<List<SchoolModel>> fetchFeaturedSchools() async {
try {
final snapshot = await _firestore
.collection('schools')
.where('isFeatured', isEqualTo: true)
.get();

return snapshot.docs
.map((doc) => SchoolModel.fromFirestore(doc.data()))
.toList();
} catch (e) {
return[];
}
}

// Fetch from all schools from firestore
Future<List<SchoolModel>> fetchSchoolsFromFirestore() async {
try {
final snapshot = await _firestore
.collection('schools')
.orderBy('name')
.get();

return snapshot.docs
.map((doc) => SchoolModel.fromFirestore(doc.data()))
.toList();
} catch (e) {
return[];
}
}

// Save schools to Firestore
// call this once to seed your firestore with API data
// Batches are chunked to stay under Firestore's 500-writes-per-batch
// limit, and capped at 800 schools to keep seeding reasonable.
Future<void> saveSchoolsToFirestore(List<SchoolModel> schools) async {
const maxPerBatch = 400;
const maxSchools = 800;

final capped = schools.take(maxSchools).toList();
for (var start = 0; start < capped.length; start += maxPerBatch) {
final batch = _firestore.batch();
final end = (start + maxPerBatch < capped.length)
    ? start + maxPerBatch
    : capped.length;

for (var i = start; i < end; i++) {
final doc = _firestore.collection('schools').doc();
batch.set(doc, capped[i].toMap());
}

await batch.commit();
}
}
}
