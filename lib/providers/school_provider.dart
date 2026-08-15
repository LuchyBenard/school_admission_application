import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../models/school_model.dart';
import '../services/school_api_service.dart';

enum SchoolStatus { initial, loading, loaded, error }

class SchoolProvider extends ChangeNotifier {
final SchoolApiService _schoolApiService = SchoolApiService();

static const List<String> _countries = [
  'Nigeria',
  'United States',
  'United Kingdom',
  'Ghana',
  'Canada',
  'Australia',
  'Sweden',
  'Belgium',
  'Kenya',
  'Germany',
  'France',
  'Netherlands',
  'Denmark',
  'Finland',
  'Italy',
  'Spain',
  'Norway',
];

// State
SchoolStatus _status = SchoolStatus.initial;
List<SchoolModel> _schools = [];
List<SchoolModel> _filteredSchools = [];
List<String> _availableCountries = [];
String _selectedCountry = 'Nigeria';
String _searchQuery = '';
String? _errorMessage;

// Getters
SchoolStatus get status => _status;
List<SchoolModel> get schools => _filteredSchools;
List<String> get availableCountries => _availableCountries;
String get selectedCountry => _selectedCountry;
String get searchQuery => _searchQuery;
String? get errorMessage => _errorMessage;
bool get isLoading => _status == SchoolStatus.loading;

// Load schools
Future<void> loadSchools({String country = 'Nigeria'}) async {
_status = SchoolStatus.loading;
_selectedCountry = country;
notifyListeners();

final box = GetStorage();
final cacheKey = 'cached_schools_$country';

// Show cached data immediately so the screen isn't blank while the
// network request runs (or fails) in the background.
final cached = box.read<List<dynamic>>(cacheKey);
final hasCache = cached != null && cached.isNotEmpty;
if (hasCache) {
_schools = cached
.whereType<Map<String, dynamic>>()
.map(SchoolModel.fromFirestore)
.toList();
_availableCountries = _countries;
_applyFilters();
_status = SchoolStatus.loaded;
notifyListeners();
}

try {
// Fetch from API (with built-in retry)
final apiSchools = await _schoolApiService
.fetchSchoolsFromApi(country: country);

// Fetch featured from Firestore
final featuredSchools = await _schoolApiService
.fetchFeaturedSchools();

// Merge - featured schools first
final merged = [...featuredSchools, ...apiSchools];

// Remove duplicates by name
final seen = <String>{};
_schools = merged.where((s) => seen.add(s.name)).toList();

_availableCountries = _countries;

_applyFilters();
_status = SchoolStatus.loaded;

// Cache API results so the list still works offline
try {
await box.write(
cacheKey,
apiSchools.map((s) => s.toMap()).toList(),
);
} catch (e) {
// Cache failure is non-fatal
}

// Seed Firestore with the API results (once) so there is a durable
// fallback even when Hipolabs is down and the device cache is cleared.
try {
final firestoreSchools = await _schoolApiService
.fetchSchoolsFromFirestore();
if (firestoreSchools.isEmpty && apiSchools.isNotEmpty) {
await _schoolApiService.saveSchoolsToFirestore(apiSchools);
}
} catch (e) {
// Seeding failure is non-fatal
}
} catch (e) {
// API failed. If we couldn't show the cache above, fall back to
// Firestore schools before giving up.
if (!hasCache) {
final firestoreSchools = await _schoolApiService
.fetchSchoolsFromFirestore();
if (firestoreSchools.isNotEmpty) {
_schools = firestoreSchools;
_availableCountries = _countries;
_applyFilters();
_status = SchoolStatus.loaded;
} else {
_errorMessage = 'Failed to load schools. Check your internet connection and try again.';
_status = SchoolStatus.error;
}
}
}

notifyListeners();
}

// Search
void search(String query) {
_searchQuery = query;
_applyFilters();
notifyListeners();
}

// Filter by country
void filterByCountry(String country) {
_selectedCountry = country;
loadSchools(country: country);
}
// Apply Filters
void _applyFilters() {
_filteredSchools = _schools.where((school) {
final matchesSearch = _searchQuery.isEmpty ||
school.name.toLowerCase().contains(
_searchQuery.toLowerCase(),
);
return matchesSearch;
}).toList();
}

// Clear search
void clearSearch() {
_searchQuery = '';
_applyFilters();
notifyListeners();
}
}