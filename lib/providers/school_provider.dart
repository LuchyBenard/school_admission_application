import 'package:flutter/material.dart';
import '../models/school_model.dart';
import '../services/school_api_service.dart';

enum SchoolStatus { initial, loading, loaded, error }

class SchoolProvider extends ChangeNotifier {
final SchoolApiService _schoolApiService = SchoolApiService();

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

try {
// Fetch from API
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

// Extract available countries for filter chips
_availableCountries = [
'Nigeria',
'United States',
'United Kingdom',
'Ghana',
'Canada',
'Australia',
];

_applyFilters();
_status = SchoolStatus.loaded;

} catch (e) {
_errorMessage = 'Failed to load schools. Please try again.';
_status = SchoolStatus.error;
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