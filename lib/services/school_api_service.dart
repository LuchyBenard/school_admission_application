import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school_model.dart';

class SchoolApiService {
final Dio _dio = Dio();
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Primary: GitHub mirror of the university dataset. Hosted on
// GitHub's CDN — far more reliable than Hipolabs. Returns ALL
// universities in one JSON file; we filter by country in Dart.
static const String _mirrorURL = 'https://raw.githubusercontent.com/Hipo/university-domains-list/master/world_universities_and_domains.json';

// Fallback: Hipolabs API (same dataset, but the server is flaky).
static const String _hipolabsURL = 'https://universities.hipolabs.com/search';

// Fetch schools — tries GitHub mirror first, then Hipolabs as backup.
Future<List<SchoolModel>> fetchSchoolsFromApi({
String country = 'Nigeria',
}) async {
try {
return await _fetchFromMirror(country);
} catch (_) {
// Mirror failed — try Hipolabs as a last resort.
return _fetchFromHipolabs(country);
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

// Fetch from the GitHub mirror and filter for the requested country.
Future<List<SchoolModel>> _fetchFromMirror(String country) async {
final response = await _dio.get(
_mirrorURL,
options: Options(
connectTimeout: const Duration(seconds: 20),
receiveTimeout: const Duration(seconds: 30),
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
