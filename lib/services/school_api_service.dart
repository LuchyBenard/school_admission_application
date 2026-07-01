import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school_model.dart';

class SchoolApiService {
final Dio _dio = Dio();
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Base URL for Hipolabs API
static const String _baseURL = 'http://Universities.hipolabs.com/search';

// Ftech from Hipolabs API
Future<List<SchoolModel>> fetchSchoolsFromApi({
String country = 'Nigeria',
}) async {
try {
final response = await _dio.get(
_baseURL,
queryParameters: {'country': country},
options: Options(
receiveTimeout: Duration(seconds: 10),
sendtimeout: Duration(seconds: 10),
),
);

if (response.statusCode == 200) {
final List data = response.data;
return data
.map((json) => SchoolModel.froAPI(json))
.toList();
}
return [];
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
Future<Lis<SchoolModel>> fetchSchoolsFromFirestore() async {
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
Future<void> saveSchoolsToFirestore(List<SchoolModel> schools) async {
final batch = _firestore.batch();

for (final school in schools) {
final doc = _firestore.collection('schools').doc();
batch.set(doc, school.toMap());
}

await batch.commit();
}
}
